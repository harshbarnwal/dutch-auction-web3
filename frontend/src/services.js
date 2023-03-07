import auction from "./auction";

// OWNER ITEM SECTION

export const addNFT = async (nft) => {
  const response = await auction
    .addItem(nft?.nftName, nft?.nftUrl, nft?.nftReservePrice, nft?.nftMaxMulti);
    console.log("Add NFT API response =>", response);
};

// SECRET BID SECTION

export const startSecretBid = async (nftId) => {
    const response = await auction.startSecretBid(nftId);
    console.log("Start Secret Bid API response =>", response);
}

export const addSecretBid = async (nftId, bidAmount, cb) => {
    const response = await auction.addSecretBid(nftId, bidAmount);
    console.log("Add Secret Bid API response =>", response);
    cb();
}

export const stopSecretStartOpenBid = async (nftId) => {
    const response = await auction.startOpenBid(nftId);
    console.log("Stop Secret => Start Open Bid API response =>", response);
}


// OPEN BID SECTION

export const setNewOwnerByPlacingOpenBid = async (nftId, finalBidAmount) => {
    const response = await auction
      .placeBid(nftId, finalBidAmount);
      console.log("New Owner ByPlacing Open Bid API Response =>", response);
};

export const endOpenBid = async (nftId) => {
    const response = await auction.endOpenBid(nftId);
    console.log("End Open Bid API response =>", response);
}

// FETCH DETAILS SECTION

export const getItemCurrentPrice = async (nftId) => {
    return await auction.getItemCurrentPrice(nftId);
}

export const getCurrentBidState = async (nftId) => {
    return await auction.getBidState(nftId);
}

export const getNFTOwners = async () => {
    return await auction.getNFT();
}

