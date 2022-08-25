// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BridgeCustody is IERC721Receiver, ReentrancyGuard, Ownable {
  struct Custody {
    uint256 tokenId;
    address holder;
  }

  /* ========== events ========== */
  event NFTCustody(uint256 indexed tokenId, address holder);

  /* ========== STATE VARIABLES ========== */
  uint256 public constant FEE = 0.001 ether;
  mapping(uint256 => Custody) public holdCustody;
  ERC721Enumerable public nft;

  /* ========== Functions ========== */
  constructor(ERC721Enumerable _nft) {
    nft = _nft;
  }

  function retainNFT(uint256 tokenId) public payable nonReentrant {
    require(msg.value == FEE, "Not enough balance to complete transaction.");
    require(nft.ownerOf(tokenId) == msg.sender, "NFT not yours");
    require(holdCustody[tokenId].tokenId == 0, "NFT already stored");
    holdCustody[tokenId] = Custody(tokenId, msg.sender);
    nft.transferFrom(msg.sender, address(this), tokenId);
    emit NFTCustody(tokenId, msg.sender);
  }

  function retainNew(uint256 tokenId) public nonReentrant onlyOwner {
    require(holdCustody[tokenId].tokenId == 0, "NFT already stored");
    holdCustody[tokenId] = Custody(tokenId, msg.sender);
    nft.transferFrom(msg.sender, address(this), tokenId);
    emit NFTCustody(tokenId, msg.sender);
  }

  function updateOwner(uint256 tokenId, address newHolder) public nonReentrant onlyOwner {
    holdCustody[tokenId] = Custody(tokenId, newHolder);
    emit NFTCustody(tokenId, newHolder);
  }

  function releaseNFT(uint256 tokenId, address wallet) public nonReentrant onlyOwner {
    nft.transferFrom(address(this), wallet, tokenId);
    delete holdCustody[tokenId];
    emit NFTCustody(tokenId, address(0));
  }

  function emergencyDelete(uint256 tokenId) public nonReentrant onlyOwner {
    delete holdCustody[tokenId];
    emit NFTCustody(tokenId, address(0));
  }

  function onERC721Received(
    address,
    address from,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    require(from == address(0x0), "Cannot Receive NFTs Directly");
    return IERC721Receiver.onERC721Received.selector;
  }

  function withdrawETH() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }
}
