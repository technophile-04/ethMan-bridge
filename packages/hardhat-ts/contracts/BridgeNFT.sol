// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract BridgeNFT is ERC721Enumerable, Ownable {
  /* ========== STATE VARIABLES ========== */
  uint16 private constant MAX_SUPPLY = 1000;
  mapping(uint256 => string) private tokenIdToURI;

  /* ========== Functions ========== */
  constructor() ERC721("ETH Man", "EMAN") {}

  /**
   * @dev onlyOwner and can mint any tokenId
   */
  function bridgeMint(
    address to,
    uint256 tokenId,
    string memory tokenURI
  ) public virtual onlyOwner {
    _mint(to, tokenId);
    tokenIdToURI[tokenId] = tokenURI;
  }

  /**
   * @notice returns all the tokenIds held by address
   */
  function walletOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  /**
   * @dev returns the tokenURI mapped to tokenID
   */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    return tokenIdToURI[tokenId];
  }
}
