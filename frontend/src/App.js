import "./App.css";
import { useEffect, useState } from "react";
import auction from "./auction";
import {
  getNFTOwners,
  addNFT,
  addSecretBid,
  startSecretBid,
  stopSecretStartOpenBid,
  endOpenBid,
  setNewOwnerByPlacingOpenBid,
} from "./services";

const NEW_NFT_ADDED = "NewNFTAdded";
const SECRET_BID_STARTED = "SecretBidStarted";
const START_OPEN_BID = "StartOpenBid";
const AUCTION_COMPLETED = "AuctionCompleted";

const NOT_STARTED = "notStarted";
const SECRET_BID = "secretBid";
const OPEN_BID = "openBid";
const ENDED_BID = "endedBid";

const BID_STATES = {
  [NOT_STARTED]: 0,
  [SECRET_BID]: 1,
  [OPEN_BID]: 2,
  [ENDED_BID]: 3,
};

const OwnerSwitch = ({ value, NFT }) => {
  switch (value) {
    case BID_STATES[NOT_STARTED]:
      return (
        <div>
          <button
            className="nftAddItemButton nftOwnersItemSecretBidButton"
            onClick={() => {
              startSecretBid(NFT?.id);
            }}
          >
            Start Secret Bid
          </button>
        </div>
      );
    case BID_STATES[SECRET_BID]:
      return (
        <div>
          <button
            className="nftAddItemButton nftOwnersItemSecretBidButton"
            onClick={() => {
              stopSecretStartOpenBid(NFT?.id);
            }}
          >
            Start Open Bid
          </button>
        </div>
      );
    case BID_STATES[OPEN_BID]:
      return (
        <div>
          <button
            className="nftAddItemButton nftOwnersItemSecretBidButton"
            onClick={() => {
              endOpenBid(NFT?.id);
            }}
          >
            End Open Bid
          </button>
        </div>
      );
  }
};

const UserSwitch = ({ value, NFT, postSecertBid }) => {
  const [secretBidAmount, setSecretBidAmount] = useState(0);

  switch (value) {
    case BID_STATES[NOT_STARTED]:
      return <div className="bidNotStartedHeaderUser">Bid Not Started Yet</div>;
    case BID_STATES[SECRET_BID]:
      return (
        <div className="nftOwnersItemSecretBidInputParent">
          {!NFT?.addedSecretBid && (
            <input
              disabled={NFT?.addedSecretBid}
              className="nftAddItemInput nftOwnersItemSecretBidInput"
              type="number"
              value={secretBidAmount}
              onChange={({ target: { value = "" } = {} } = {}) =>
                setSecretBidAmount(value)
              }
            />
          )}
          <button
            disabled={NFT?.addedSecretBid}
            className="nftAddItemButton nftOwnersItemSecretBidButton"
            onClick={() => {
              addSecretBid(NFT?.id, secretBidAmount, () => {
                postSecertBid(NFT?.id);
              });
            }}
          >
            {NFT?.addedSecretBid
              ? "Secret Bid Placed (DO NOT CLICK)"
              : "Place Secret Bid"}
          </button>
        </div>
      );
    case BID_STATES[OPEN_BID]:
      return NFT?.addedSecretBid ?
        (<div>
          <button
            className="nftAddItemButton nftOwnersItemSecretBidButton"
            onClick={() => {
              setNewOwnerByPlacingOpenBid(NFT?.id, 1500);
            }}
          >
            Place Final Bid on Current Price
          </button>
        </div>
      ) : <div className="bidNotStartedHeaderUser">You Are not Eligible For Open bid</div>;
  }
};

const SingleNFTItem = ({ NFT, index, postSecertBid }) => {
  return (
    <div className="nftOwnersItem" onClick={() => {}}>
      <div className="nftOwnersItemFirst">
        <div className="nftOwnersItemIndex">
          NFT Details (Serial No. {index})
        </div>
        <div className="nftOwnersItemSecretBid">
          {NFT?.isOwner && <OwnerSwitch NFT={NFT} value={NFT?.bidState} />}
          {!NFT?.isOwner && (
            <UserSwitch
              NFT={NFT}
              value={NFT?.bidState}
              postSecertBid={postSecertBid}
            />
          )}
        </div>
      </div>

      {/* <div className="nftOwnersItemValue">
        <span>ID: </span>
        {NFT?.id}
      </div> */}
      <div className="nftOwnersItemValue">
        <span>URL: </span>
        {NFT?.imageUrl}
      </div>
      <div className="nftOwnersItemValue">
        <span>Name: </span>
        {NFT?.name}
      </div>
      <div className="nftOwnersItemValue">
        <span>Owner: </span>
        {NFT?.owner}
      </div>
    </div>
  );
};

const App = () => {
  const [localNftOwners, setLocalNftOwners] = useState([]);

  const [nftName, setNftName] = useState("");
  const [nftUrl, setNftUrl] = useState("");
  const [nftReservePrice, setNftReservePrice] = useState("");
  const [nftMaxMulti, setNftMaxMulti] = useState("");

  const postSecertBid = (nftId) => {
    const updatedNFT = localNftOwners.map((item) => {
      if (item?.id === nftId) {
        return {
          ...item,
          addedSecretBid: true,
        };
      }
      return item;
    });
    setLocalNftOwners(updatedNFT);
  };

  const listenEvents = () => {
    auction.on(NEW_NFT_ADDED, (response) => {
      console.log("NEW_NFT_ADDED Listened =>", response);
      setLocalNftOwners([response, ...localNftOwners]);
    });
    auction.on(SECRET_BID_STARTED, (response) => {
      console.log("SECRET_BID_STARTED Listened =>", response);
      const requiredNftId = parseInt(response?._hex, 16);
      const updatedNFT = localNftOwners.map((item) => {
        if (item?.id === requiredNftId) {
          return {
            ...item,
            bidState: 1,
          };
        }
        return item;
      });
      setLocalNftOwners(updatedNFT);
    });
    auction.on(START_OPEN_BID, (response) => {
      console.log("START_OPEN_BID Listened =>", response);
      const requiredNftId = parseInt(response?._hex, 16);
      const updatedNFT = localNftOwners.map((item) => {
        if (item?.id === requiredNftId) {
          return {
            ...item,
            bidState: 2,
          };
        }
        return item;
      });
      setLocalNftOwners(updatedNFT);
    });
    auction.on(AUCTION_COMPLETED, (response) => {
      console.log("AUCTION_COMPLETED Listened =>", response);
    });
  };

  const callFunc = async () => {
    const nftOwners = await getNFTOwners();
    if (nftOwners.length > 0) {
      const updatedData = nftOwners.map((item) => {
        return {
          ...item,
          id: parseInt(item?.id?._hex, 16),
        };
      });
      setLocalNftOwners(updatedData);
    }
  };

  useEffect(() => {
    callFunc();
    listenEvents();
  }, []);

  return (
    <div className="App">
      <div className="AppHeader">Welcome To Dutch Auction</div>
      <div className="container">
        <div className="nftOwners">
          <div className="commonTitle">NFT Owners (Click to place bid)</div>
          {localNftOwners.length > 0 ? (
            localNftOwners.map((item, index) => (
              <SingleNFTItem
                NFT={item}
                key={index}
                index={index}
                postSecertBid={(nftId) => postSecertBid(nftId)}
              />
            ))
          ) : (
            <div>None Found</div>
          )}
        </div>
        <div className="nftAddItemSection">
          <div className="commonTitle">Add NFT</div>
          <div className="nftAddItem">
            <input
              placeholder="Enter NFT Name"
              className="nftAddItemInput"
              type="text"
              value={nftName}
              onChange={({ target: { value = "" } = {} } = {}) =>
                setNftName(value)
              }
            />
            <input
              placeholder="Enter NFT URL"
              className="nftAddItemInput"
              type="text"
              value={nftUrl}
              onChange={({ target: { value = "" } = {} } = {}) =>
                setNftUrl(value)
              }
            />
            <input
              placeholder="Enter Reserve price"
              className="nftAddItemInput"
              type="number"
              value={nftReservePrice}
              onChange={({ target: { value = "" } = {} } = {}) =>
                setNftReservePrice(value)
              }
            />
            <input
              placeholder="Enter Multipler Factor"
              className="nftAddItemInput"
              type="number"
              value={nftMaxMulti}
              onChange={({ target: { value = "" } = {} } = {}) =>
                setNftMaxMulti(value)
              }
            />
            <button
              className="nftAddItemButton"
              onClick={() => {
                addNFT({
                  nftName,
                  nftUrl,
                  nftReservePrice,
                  nftMaxMulti,
                });
              }}
            >
              +Add Item
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;
