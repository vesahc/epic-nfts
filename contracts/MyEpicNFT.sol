// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    //Open Zepplin to keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We split the SVG at the part where it asks for the background color.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    
    //Three arrays with random words
    // Customize
    string[] firstWords = ["Heavy","Strong","Powerful","Immense","Gigantic","Extreme"];
    string[] secondWords = ["Epic","Rare","Selective","Effective","Unique","Unlimited"];
    string[] thirdWords = ["Enki","Enlil","Inanna","Utu","Gula","Ki"];

    string[] colors = ["red", "blue", "black", "yellow", "orange", "green"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // Pass the name of our NFTs token and its symbol
    constructor() ERC721 ("TeamForceNFT", "FORCE") {
        console.log("Let's get ready to rumble!!");
    }

    // function to randomly pick a word from each array
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to keep within uint256
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();

        // Randomly grab one word from each array
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Add the random color in.
        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

        // get all the JSON metadata in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // set the title of our NFT as the generated word
                        combinedWord,
                        '", "description": "Some pure epic action from the Gods.", "image": "data:image/svg+xml;base64,',
                        // we add date:image/svg+xml,base64 and then append and base64 encode our svg 
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                        )
                    )
                )
             );

    
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        
        console.log("\n-----------------");
        console.log(finalTokenUri);
        console.log("------------------\n");

        _safeMint(msg.sender, newItemId);

        //We'll be setting the tokenURI later!
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}