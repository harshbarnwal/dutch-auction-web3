// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DutchAuction {
    enum BidState {
        notStarted,
        secretBid,
        openBid,
        endedBid
    }

    struct NFT {
        string name;
        string imageUrl;
        uint256 id;
        address payable owner;
        bool isOwner;
        BidState bidState;
    }

    struct NFTBidData {
        uint256 highestBid;
        uint8 maxBidMultiplier;
        uint256 reservePrice;
        uint256 bidStartTime;
    }

    mapping(uint256 => NFTBidData) nftBidData;
    mapping(uint256 => mapping(address => bool)) participants;

    mapping(uint256 => NFT) nftList;
    uint256 public nftItemCount = 0;
    uint8 constant discountPerSec = 100;
    event SecretBidStarted(uint256 nftId);
    event StartOpenBid(uint256 nftId, uint256 startTime, uint256 startAmount);
    event AuctionCompleted(uint256 nftId, string msg);

    function addItem(
        string memory name,
        string memory url,
        uint256 _reservePrice,
        uint8 maxMultiplier
    ) public returns (NFT memory) {
        NFT memory newNFT = NFT(
            name,
            url,
            nftItemCount,
            payable(msg.sender),
            true,
            BidState.notStarted
        );
        nftList[nftItemCount] = newNFT;
        nftBidData[nftItemCount].highestBid = _reservePrice;
        nftBidData[nftItemCount].maxBidMultiplier = maxMultiplier;
        nftBidData[nftItemCount].reservePrice = _reservePrice;
        nftItemCount++;
        return newNFT;
    }

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
        emit SecretBidStarted(id);
        nftList[id].bidState = BidState.secretBid;
    }

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

    function endOpenBid(uint256 id) public {
        require(id < nftItemCount, "Item doesn't exists");
        NFT memory nftData = nftList[id];
        require(
            nftData.bidState == BidState.openBid,
            "Bid has not started yet"
        );
        require(
            nftData.owner == payable(msg.sender),
            "Only owner can start the bid"
        );
        nftList[id].bidState = BidState.endedBid;
        emit AuctionCompleted(id, "Bid Ended");
    }

    function getBidState(uint256 id) public view returns (BidState) {
        require(id < nftItemCount, "Item doesn't exists");
        NFT memory nftData = nftList[id];
        return nftData.bidState;
    }

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
            participants[id][msg.sender] == true,
            "Only Secret bid participants can place open bid"
        );
        require(msg.value >= amount, "Insuficient balance");
        nftList[id].owner.transfer(msg.value);
        nftList[id].owner = payable(msg.sender);
        nftList[id].bidState = BidState.endedBid;
        emit AuctionCompleted(id, "Owner changed");
    }

    function getNFTOwners() public view returns (NFT[] memory) {
        NFT[] memory ownerData = new NFT[](nftItemCount);
        for (uint8 i = 0; i < nftItemCount; i++) {
            ownerData[i] = nftList[i];
            ownerData[i].isOwner = msg.sender == ownerData[i].owner;
        }
        return ownerData;
    }
}
