// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract NFTRoyalty is ERC721, ERC721Enumerable, ERC721Royalty, ERC721Burnable, ERC721URIStorage, ERC721Pausable, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    constructor () ERC721("Ebattti", "EBT") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, 1000);
    }

    function safeMint(address to, string memory uri) public onlyOwner returns (uint) {
        _tokenIdCounter.increment();
        uint tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    function safeMintRoyalty(address to, string memory uri, address receiver, uint96 feeNumerator) public onlyOwner returns (uint) {
        uint tokenId = safeMint(to, uri);
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
        return tokenId;
    }

    function _increaseBalance(address account, uint128 value) internal override (ERC721,  ERC721Enumerable) {
        return super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721,  ERC721Enumerable, ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Pausable,  ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override (ERC721 ,ERC721URIStorage) returns (string memory) {
        _requireMinted(tokenId);
        return super.tokenURI(tokenId);
    }

    function _requireMinted(uint tokenId) internal view  {
        require(_requireOwned(tokenId) != address(0), "invalid tokenId");
    }

    function _baseURI() internal pure override (ERC721) returns (string memory) {
        return "https://nftstorage.link/ipfs/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function getBytes1() public pure returns (bytes4) {
        return IERC721.ownerOf.selector;
    }

    function getBytes2() public pure returns (bytes4) {
        return bytes4(keccak256(bytes("ownerOf(uint256)")));
    }
    
    function checkBytes(bytes4 _owner) public pure returns (bool) {
        return _owner == IERC721.ownerOf.selector;
    }

    function _feeDenominator() internal pure override returns (uint96) {
        return 10000;
    }

    function contractURI() public pure returns (string memory) {
        return "https://bafybeicsoo2tpt67j4kr7cj7tj52o6upr2txfp6sp2u3iyu2uyggwxjdba.ipfs.dweb.link?filename=Opensea-721-contract-metadata.json";
    }
}