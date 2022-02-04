// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


interface IDescriptors {
    function tokenURI(uint256 tokenId, OtterColoringBook animalColoringBook) external view returns(string memory);
}

interface IMintableBurnable {
    function mint(address mintTo) external;
    function burn(uint256 tokenId) external;
}

interface IGTAP1 {
    function copyOf(uint256 tokenId) external returns(uint256);
}

struct Animal {
    uint8 animalType;
    uint8 mood;
}

contract OtterColoringBook is ERC721Enumerable, Ownable {
    IDescriptors public immutable descriptors;
    address public eraserContract;
    uint256 private _nonce;

    mapping(uint256 => Animal) public animalInfo;
    mapping(uint256 => address[]) private _transferHistory;

    constructor(address _owner, IDescriptors _descriptors) 
        ERC721("Otter Coloring Book", "OCB") 
    {
        transferOwnership(_owner);
        descriptors = _descriptors;
    }

    function transferHistory(uint256 tokenId) external view returns (address[] memory){
        return _transferHistory[tokenId];
    }

    function mint(address mintTo, bool mintEraser) payable external {
        _safeMint(mintTo, ++_nonce, "");

        uint256 randomNumber = _randomishIntLessThan("animal", 101);
        
        animalInfo[_nonce].animalType = 1;

        if(mintEraser){
            IMintableBurnable(eraserContract).mint(mintTo);
        }

        _transferHistory[_nonce].push(mintTo);
    }

    function erase(uint256 tokenId, uint256 eraserTokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(msg.sender == IERC721(eraserContract).getApproved(eraserTokenId) || msg.sender == IERC721(eraserContract).ownerOf(eraserTokenId), "Caller must be approved or owner for token id");

        IMintableBurnable(eraserContract).burn(eraserTokenId);
        address[] memory fresh;
        _transferHistory[tokenId] = fresh;
        animalInfo[tokenId].mood = 0;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        super.transferFrom(from, to, tokenId);
         if(_transferHistory[tokenId].length < 4) {
            _transferHistory[tokenId].push(to);
            if(_transferHistory[tokenId].length == 4){
                uint8 random = _randomishIntLessThan("mood", 10) + 1;
                animalInfo[tokenId].mood = random > 6  ? 1 : random;
            }
        }
    }
    
    function tokenURI(uint256 tokenId) public override view returns(string memory) {
        return descriptors.tokenURI(tokenId, this);
    }

    function setEraser(address _eraserContract) external {
        require(address(eraserContract) == address(0), 'set');
        eraserContract = _eraserContract;
    }

    function _randomishIntLessThan(bytes32 salt, uint8 n) private view returns (uint8) {
        if (n == 0)
            return 0;
        return uint8(keccak256(abi.encodePacked(block.timestamp, _nonce, msg.sender, salt))[0]) % n;
    }

    function payOwner(address to, uint256 amount) public onlyOwner() {
        require(amount <= address(this).balance, "amount too high");
        payable(to).transfer(amount);
    }
}









