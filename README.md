# dutch-auction-web3
A web3 project for creating dutch auction DAPP.

DAPP - http://dutch-auction.surge.sh/

Contract Address - [0x7f4D8B09c54bcC9B0125F36FAea94D5daF7eae1b](https://goerli.etherscan.io/address/0x7f4D8B09c54bcC9B0125F36FAea94D5daF7eae1b)

ABI - 

```[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "url",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_reservePrice",
				"type": "uint256"
			},
			{
				"internalType": "uint8",
				"name": "maxMultiplier",
				"type": "uint8"
			}
		],
		"name": "addItem",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "bidAmount",
				"type": "uint256"
			}
		],
		"name": "addSecretBid",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "msg",
				"type": "string"
			}
		],
		"name": "AuctionCompleted",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "endOpenBid",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "imageUrl",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "address payable",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "isOwner",
						"type": "bool"
					},
					{
						"internalType": "enum DutchAuction.BidState",
						"name": "bidState",
						"type": "uint8"
					},
					{
						"internalType": "bool",
						"name": "addedSecretBid",
						"type": "bool"
					}
				],
				"indexed": false,
				"internalType": "struct DutchAuction.NFT",
				"name": "newNft",
				"type": "tuple"
			}
		],
		"name": "NewNFTAdded",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "placeBid",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftId",
				"type": "uint256"
			}
		],
		"name": "SecretBidStarted",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "startOpenBid",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startAmount",
				"type": "uint256"
			}
		],
		"name": "StartOpenBid",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "startSecretBid",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getItemCurrentPrice",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getNFT",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "imageUrl",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "address payable",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "isOwner",
						"type": "bool"
					},
					{
						"internalType": "enum DutchAuction.BidState",
						"name": "bidState",
						"type": "uint8"
					},
					{
						"internalType": "bool",
						"name": "addedSecretBid",
						"type": "bool"
					}
				],
				"internalType": "struct DutchAuction.NFT[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getNFTBidData",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "highestBid",
						"type": "uint256"
					},
					{
						"internalType": "uint8",
						"name": "maxBidMultiplier",
						"type": "uint8"
					},
					{
						"internalType": "uint256",
						"name": "reservePrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "bidStartTime",
						"type": "uint256"
					}
				],
				"internalType": "struct DutchAuction.NFTBidData",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getNFTByID",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "imageUrl",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "address payable",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "isOwner",
						"type": "bool"
					},
					{
						"internalType": "enum DutchAuction.BidState",
						"name": "bidState",
						"type": "uint8"
					},
					{
						"internalType": "bool",
						"name": "addedSecretBid",
						"type": "bool"
					}
				],
				"internalType": "struct DutchAuction.NFT",
				"name": "nft",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "nftItemCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]```
