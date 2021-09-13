pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract NFTDemo is ERC721, VRFConsumerBase {

    //bytes32 public keyHash;
    uint256 public vrfCoordinator;
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;


    struct Character{
        uint256 colour;
        uint256 popularity;
        string name;
    }

    Character[] public characters;

    //mapping
    mapping(bytes32 => string) requestToCharacterName;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;



    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
    public
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("NFTDemo", "NFTD"){
        //vrfCoordinator = _VRFCoordinator;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    function requestNewRandomDemo (uint256 userProvidedSeed,
    string memory name
    ) public returns (bytes32){
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToCharacterName[requestId] = name;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
    internal override{
        //define the creation of the NFT
        uint256 newId = characters.length;
        uint256 colour = (randomNumber % 1000);
        uint256 popularity = (randomNumber % 100 );

        characters.push(
            Character(
                colour,
                popularity,
                requestToCharacterName[requestId]
            )
        );

        _safeMint(requestToSender[requestId], newId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public{
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721:transfer caller is not the owner or not approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }


}