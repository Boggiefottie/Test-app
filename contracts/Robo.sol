// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Robo is ERC721, Ownable {
    uint256 public mintPrice; // price of mint
    uint256 public totalSupply; // current no. of mints that are minted
    uint256 public maxSupply; // max of nft that will be in collection
    uint256 public maxPerWallet; // max no. of nft a particular wallet can mint
    bool public isPublicMintEnabled; // will determine when users can mint owner can toggle this to be true or false
    string internal baseTokenUri; // url for where images are located
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints; // determine and keep track of all the mints that will be done

    constructor() payable ERC721("Bhavya", "BHA") {
        // 'Bhavya' , 'BHA' name and symbol
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
    }

    function setIsPublicMintEnabled(
        bool isPublicMintEnabled_
    ) external onlyOwner {
        // allows us to change when this (bool public isPublicMintEnabled;) happens
        isPublicMintEnabled = isPublicMintEnabled_; // if its true then someone can mint it will happen if false then no one can mint
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        //url where images are going to be located
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI(
        uint256 tokenId_
    ) public view override returns (string memory) {
        // called to grab the images , as string internal baseTokenUri; define , we have to override this function and be making sure that we are calling the correct variable so we opensea can call correct url
        require(_exists(tokenId_), "Token does not exist!"); // make sure token does exist
        return
            string(
                abi.encodePacked(
                    baseTokenUri,
                    Strings.toString(tokenId_),
                    ".json"
                )
            ); // taking url that we identified (baseTokenUri) we are grabing the id {Strings.toString(tokenId_)} and placing it brhind the url and attaching .json to the end of it this allows opensea to grab the url of every single images its gonna call tokenURI for each token and thats how image gets displayed on opensea
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}( //withdrawWallet.call{value: address(this).balance}( allows us to withdraw the funds to the address we specify with withdraw wallet
            ""
        ); // grabbing the wallet by (withdrawWallet) and calling it by (.call) and passing the value of address which is this contract and passing the balance and passing empty ('')
        require(success, "withdraw failed"); // if success keep going , if not then throw error "withdraw failed"
    }

    function mint(uint256 quantity_) public payable {
        require(isPublicMintEnabled, "minting not enabled"); //
        require(msg.value == quantity_ * mintPrice, "wrong mint value"); //user inputing the correct value
        require(totalSupply + quantity_ <= maxSupply, "sold"); //
        require(
            walletMints[msg.sender] + quantity_ <= maxPerWallet,
            "exceed max wallet"
        ); //walletMints[msg.sender] + quantity_ shows no. of mints our wallet can do

        for (uint256 i = 0; i < quantity_; i++) {
            uint256 newTokenId = totalSupply + 1; //keep track of token id and specify the latest the token id that we are going to mint
            totalSupply++; // increament the total supply to keep track of it correctly
            _safeMint(msg.sender, newTokenId); // passing address that is going to reiceve the nft by msg.sender and passing the latest newTokenId
        }
    }
}
