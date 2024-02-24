// SPDX-License-Identifier: MIT


/*

           __.                                              
        .-".'                      .--.            _..._    
      .' .'                     .'    \       .-""  __ ""-. 
     /  /                     .'       : --..:__.-""  ""-. \
    :  :                     /         ;.d$$    sbp_.-""-:_:
    ;  :                    : ._       :P .-.   ,"TP        
    :   \                    \  T--...-; : d$b  :d$b        
     \   `.                   \  `..'    ; $ $  ;$ $        
      `.   "-.                 ).        : T$P  :T$P        
        \..---^..             /           `-'    `._`._     
       .'        "-.       .-"                     T$$$b    
      /             "-._.-"               ._        '^' ;   
     :                                    \.`.         /    
     ;                                -.   \`."-._.-'-'     
    :                                 .'\   \ \ \ \         
    ;  ;                             /:  \   \ \ . ;        
   :   :                            ,  ;  `.  `.;  :        
   ;    \        ;                     ;    "-._:  ;        
  :      `.      :                     :         \/         
  ;       /"-.    ;                    :                    
 :       /    "-. :                  : ;                    
 :     .'        T-;                 ; ;        
 ;    :          ; ;                /  :        
 ;    ;          : :              .'    ;       
:    :            ;:         _..-"\     :       
:     \           : ;       /      \     ;      
;    . '.         '-;      /        ;    :      
;  \  ; :           :     :         :    '-.      
'.._L.:-'           :     ;  aibf   ;    . `. 
                     ;    :          :  \  ; :  
                     :    '-..       '.._L.:-'  
                      ;     , `.                
                      :   \  ; :                
                      '..__L.:-'



*/


pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AIBF is ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 150; // Total supply
    string private baseURI;

     constructor() ERC721("AI Best Friend", "AIBF") Ownable(msg.sender){
        totalSupply = 0; // Initialize total supply to 0
    }

    // Owner-only function to mint tokens up to the maximum supply to a specified address
    function mintTokens(address to, uint256 numberToMint) external onlyOwner {
        require(totalSupply.add(numberToMint) <= MAX_SUPPLY, "Exceeds max supply");
        require(numberToMint > 0, "Zero mint");

        uint256 currentSupply_ = totalSupply.add(1); // Start from token ID 1
        for (uint256 i = 0; i < numberToMint; ++i) {
            _safeMint(to, currentSupply_++); // Mint to the specified address
        }
        totalSupply = currentSupply_.sub(1); // Update totalSupply
    }

    // Withdraw ETH from contract with reentrancy guard
    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // Set the Metadata URI
    function setMetadata(string memory metadata) public onlyOwner {
        baseURI = metadata;
    }

    // Override baseURI function
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // Token Tracking with IDs starting at 1
    function getTokensFromAddress(address wallet) public view returns(uint256[] memory) {
        uint256 tokensHeld = balanceOf(wallet);
        uint256[] memory _tokens = new uint256[](tokensHeld);
        uint256 x = 0;

        for (uint256 i = 1; i <= totalSupply; i++) { // Start from 1
            if (ownerOf(i) == wallet) {
                _tokens[x] = i;
                x++;
            }
        }

        return _tokens;
    }

    // Returns the current max supply
   function maxSupply() external pure returns(uint256) {
    return MAX_SUPPLY;
    }
}
