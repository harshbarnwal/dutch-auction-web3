// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

 // add logs using evvent listeners
 // add function for ending 2 levels of bidding --> end auction if no has bidded in level 1?
 // add bid start, stop time + x,y value 
 // can add currency checks ether,wei,gwei type prices and bidvalues?
 // bidder account balance before placing bid?

contract DutchAuction {

     struct Item {
        string name;
        uint256 reservePrice;
        address owner;
        uint256 highestBid;
        address winner ;
        bool auctionEnded;
    }
    struct impDate{
       uint256 secretHighestBid;
       uint256 extraAmount;
    }
    mapping(uint256 => Item) public items;
    mapping (uint256 =>  mapping(address => uint256)) private secretBids;
    mapping(uint256 => impDate) private itemsImpData; 
    uint256 public itemCount=0;
    
 // add params validations for all functions
 // add hasBidded condition to restrict re-bidding and moving them to bid in next level
 // reservePrice check before declaring user as a secret bidder ??
 // reorganise requires to modifiers

    function addItem(string memory name,uint256  reservePrice, uint256 extraValue) public {
        itemCount++;
        items[itemCount].name = name;
        items[itemCount].reservePrice = reservePrice;
        items[itemCount].owner = msg.sender;
        itemsImpData[itemCount].extraAmount = extraValue;
        itemsImpData[itemCount].secretHighestBid = reservePrice; // 0?
    }

    function secretBidItem(uint256 itemID,uint256 bidvalue) public {
        require(itemID!=0,"please enter a valid itemID");
        require(bidvalue!=0,"please enter a valid bidvalue");
        require(!items[itemID].auctionEnded,"auction has ended");
        require(items[itemID].owner!=msg.sender,"owner cannot participate in auction");
        require(secretBids[itemID][msg.sender]==uint256(0),"participant has already placed the bid"); 


        secretBids[itemID][msg.sender] = bidvalue;
        if(bidvalue>itemsImpData[itemID].secretHighestBid){
           itemsImpData[itemID].secretHighestBid=bidvalue;
        }
    }

    //check 2nd level auction started
    function BidItem(uint256 itemID,uint256 bidvalue) public {
        require(itemID!=0,"please enter a valid itemID");
        require(bidvalue!=0,"please enter a valid bidvalue");
        require(!items[itemID].auctionEnded,"auction has ended");
        require(items[itemID].owner!=msg.sender,"owner cannot participate in auction");
        require(secretBids[itemID][msg.sender]!=uint256(0),"auction has ended");
        if(items[itemID].reservePrice < bidvalue){
            items[itemID].winner = msg.sender;
            items[itemID].highestBid= bidvalue;
            // send money to owner address
            items[itemID].auctionEnded = true;

        }
    }

    function getItems()public view returns(Item[] memory){
        Item[] memory allItems = new Item[](itemCount); 
        for(uint256 i=0;i<itemCount;i++){
            allItems[i]=items[i];
        }
        return allItems;
    }

    function finalBidStartPrice(uint256 itemID)public view returns (uint256){
            return itemsImpData[itemID].secretHighestBid+itemsImpData[itemID].extraAmount;
    }

}
