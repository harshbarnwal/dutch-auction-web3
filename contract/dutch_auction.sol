// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
    A Dutch auction refers to a type of auction in which an auctioneer starts with a very high price,
    incrementally lowering the price until someone places a bid.
    That first bid wins the auction (assuming the price is above the reserve price), avoiding any bidding wars.
*/
contract DutchAuction {

    // Defines NFT's current bid state
    enum BidState {
        notStarted,
        secretBid,
        openBid,
        endedBid
    }

    /* A struct which contains NFT related data
       here name, imageUrl is shown in ui to the user
       other params are used in FE for calculations/decision making
    */
    struct NFT {
        string name;
        string imageUrl;
        uint256 id;
        address payable owner;
        bool isOwner;
        BidState bidState;
        bool addedSecretBid;
    }

    /* A struct which contains state of an NFT
       here highestBid is the highest bid for that NFT, initially its equal to reserve price,
       reservePrice is the min base price at which owner wants to sell the NFT,
       maxBidMultiplier is the multiple of reserve price at which owner wants to start the bid
    */
    struct NFTBidData {
        uint256 highestBid;
        uint8 maxBidMultiplier;
        uint256 reservePrice;
        uint256 bidStartTime;
    }

    // a mapping of unique nft id to its nft bid state data
    mapping(uint256 => NFTBidData) nftBidData;

    // a mapping of unique nft id to the secret bid participants
    mapping(uint256 => mapping(address => bool)) participants;

    // list of nfts with unique id mapped
    mapping(uint256 => NFT) nftList;

    // count of all NFTs available
    uint256 public nftItemCount = 0;

    // discount per second that we are providing in final bid
    uint8 constant discountPerSec = 50;

    // an event which fires when owner starts a secret bid
    event SecretBidStarted(uint256 nftId);

    // an event which fires when user adds a NFT
    event NewNFTAdded(NFT newNft);

    // an event which fires when owner starts a open bid
    event StartOpenBid(uint256 nftId, uint256 startTime, uint256 startAmount);

    // an event which fires when owner ends a open bid
    event AuctionCompleted(uint256 nftId, string msg);


    /* this function is used to add new NFT item for biding
       default bid state is not started
    */
    function addItem(
        string memory name,
        string memory url,
        uint256 _reservePrice,
        uint8 maxMultiplier
    ) public {
        NFT memory newNFT = NFT(
            name,
            url,
            nftItemCount,
            payable(msg.sender),
            true,
            BidState.notStarted,
            false
        );
        nftList[nftItemCount] = newNFT;
        nftBidData[nftItemCount].highestBid = _reservePrice;
        nftBidData[nftItemCount].maxBidMultiplier = maxMultiplier;
        nftBidData[nftItemCount].reservePrice = _reservePrice;
        nftItemCount++;
        emit NewNFTAdded(newNFT);
    }

    /* this function is used to start a secret bid
       only owner can use this and start the secret bid
    */
    function startSecretBid(uint256 id) public {
        require(id < nftItemCount, "Item doesn't exists");
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.notStarted,
            "Secret Bid has not started yet"
        );
        require(
            nftData.owner == payable(msg.sender),
            "Only owner can start the bid"
        );
        nftList[id].bidState = BidState.secretBid;
        emit SecretBidStarted(id);
    }

    /* this function is used to place a secret bid
       all users can use this function except the owner
    */
    function addSecretBid(uint256 id, uint256 bidAmount) public {
        require(id < nftItemCount, "Item doesn't exists");
        NFTBidData memory bidingData = nftBidData[id];
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.secretBid,
            "Secret Bid has not started yet"
        );
        require(
            nftData.owner != payable(msg.sender),
            "Owner can't place the bid"
        );
        if (bidingData.highestBid < bidAmount) {
            nftBidData[id].highestBid = bidAmount;
        }
        participants[id][msg.sender] = true;
    }

    /* this function is used to start a open bid
       only owner can use this and start the open bid
    */
    function startOpenBid(uint256 id) public {
        require(id < nftItemCount, "Item doesn't exists");
        NFTBidData memory bidingData = nftBidData[id];
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.secretBid,
            "Secret Bid has not started yet"
        );
        require(
            nftData.owner == payable(msg.sender),
            "Only owner can start the bid"
        );
        nftBidData[id].bidStartTime = block.timestamp;
        nftList[id].bidState = BidState.openBid;
        uint256 startAmount = bidingData.highestBid *
            bidingData.maxBidMultiplier;
        emit StartOpenBid(id, nftBidData[id].bidStartTime, startAmount);
    }

    /* this function is used to end a open bid
       only owner can use this and end the open bid
    */
    function endOpenBid(uint256 id) public {
        require(id < nftItemCount, "Item doesn't exists");
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.openBid,
            "Bid has not started yet"
        );
        nftList[id].bidState = BidState.endedBid;
        emit AuctionCompleted(id, "Bid Ended");
    }

    // this function returns bid data of a particular NFT
    function getNFTBidData(uint256 id) public view returns (NFTBidData memory ) {
        require(id < nftItemCount, "Item doesn't exists");
        return (nftBidData[id]);
    }

    // this function returns NFT data based on unqiue NFT id
    function getNFTByID(uint256 id) public view returns (NFT memory nft) {
        require(id < nftItemCount, "Item doesn't exists");
        nft = nftList[id];
        nft.isOwner = msg.sender == nft.owner;
        nft.addedSecretBid = participants[id][msg.sender];
        return nft;
    }

    // this function returns current price of a NFT based on elapsed time and discount percentage
    function getItemCurrentPrice(uint256 id) public view returns (uint256) {
        require(id < nftItemCount, "Item doesn't exists");
        NFTBidData memory bidingData = nftBidData[id];
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.openBid,
            "Open Bid has not started yet"
        );
        uint256 elapsedTime = block.timestamp - bidingData.bidStartTime;
        uint256 discountPercentage = elapsedTime * (discountPerSec / 100);
        uint256 startAmount = (bidingData.highestBid *
            bidingData.maxBidMultiplier);
        uint256 discountAmout = (startAmount * discountPercentage) / 100;
        if (discountAmout > startAmount) {
            return 0;
        }
        return startAmount - discountAmout;
    }

    /* this function places a bid
       it also closes bid for that particular NFT and transfer owenship to the user who placed the bid
       only users who have paricipated in secret bid can place final bid
       onwer can't call this function
    */
    function placeBid(uint256 id, uint256 amount) public payable {
        require(id < nftItemCount, "Item doesn't exists");
        NFTBidData memory bidingData = nftBidData[id];
        NFT memory nftData = nftList[id];
        require(
            nftData.owner != payable(msg.sender),
            "Owner can't place the bid"
        );
        require(
            nftData.bidState == BidState.openBid,
            "Open bid has not started yet"
        );
        require(
            amount > bidingData.reservePrice,
            "Bid price should not be less than reserve price"
        );
        require(
            participants[id][msg.sender],
            "Only Secret bid participants can place open bid"
        );
        require(msg.value >= amount, "Insuficient balance");
        nftList[id].owner.transfer(msg.value);
        nftList[id].owner = payable(msg.sender);
        nftList[id].bidState = BidState.endedBid;
        emit AuctionCompleted(id, "Owner changed");
    }

    /* it returns all available NFT
       it also contains whether current user is owner or not
       also it says whether current user has placed secret bid or not
    */
    function getNFT() public view returns (NFT[] memory) {
        NFT[] memory ownerData = new NFT[](nftItemCount);
        for (uint8 i = 0; i < nftItemCount; i++) {
            ownerData[i] = nftList[i];
            ownerData[i].isOwner = msg.sender == ownerData[i].owner;
            ownerData[i].addedSecretBid = participants[i][msg.sender];
        }
        return ownerData;
    }
}
