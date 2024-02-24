pragma solidity ^0.8.16;





contract AIBF is ERC721, Ownable {
    using Address for address;
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    
    uint256 public constant MAX_PUBLIC_MINT = 3;
    uint256 public totalSupply;
    uint256 public price = 0.01 ether;
    uint256 public reserveSupply = 6;
    uint256 public maxPerWallet = 3;
    uint256 public constant MAX_SUPPLY = 306;
    bool public saleActive; // public sale flag (false on deploy)
    

    constructor() ERC721("AI Best Friend", "AIBF") {}

    //mint settings
    modifier mintParameters(uint256 numberToMint) {

        uint256 currentTokens = balanceOf(msg.sender);

        require(currentTokens + numberToMint <= maxPerWallet, "Exceeds maximum number of tokens per wallet");

        require(saleActive, "Sale not live");
        _;
        require(numberToMint < MAX_PUBLIC_MINT, "Save some for the rest of us!");

        require(msg.value == price * numberToMint, "Not enough to adopt a K9");

        require(numberToMint > 0, "Zero mint");

        require(totalSupply.add(numberToMint) <= MAX_SUPPLY, "Exceeds max supply");

    
    }

     function _mintTokens(address to, uint256 numberToMint) internal {
        require(numberToMint > 0, "Zero mint");
        uint256 currentSupply_ = totalSupply; // memory variable
        for (uint256 i; i < numberToMint; ++i) {
            _safeMint(to, currentSupply_++); // mint then increment
        }
        totalSupply = currentSupply_; // update storage
    }


    //Function to set sale active

    function setSaleActive(bool state) external onlyOwner {
        saleActive = state;
    }

    // Mint for the Dog Groomer

    function dogGroomer(address to, uint256 numberToMint) external onlyOwner {
        uint256 _reserveSupply = reserveSupply;
        require(numberToMint <= _reserveSupply, "Exceeds reserve limit");
        reserveSupply = _reserveSupply - numberToMint;

        _mintTokens(to, numberToMint);
    }

    //Public Mint

    function mint(uint256 numberToMint) external payable mintParameters(numberToMint) {
        _mintTokens(msg.sender, numberToMint);
    }


    // Take out ETH
      function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }



   // Set the Metadata

    string private baseURI;

      function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setMetadata(string memory metadata) public onlyOwner {
        baseURI = metadata;
    }

    //Token Tracking
    Counters.Counter private tokens;

        function getTokensFromAddress(address wallet) public view returns(uint256[] memory) {
        uint256 tokensHeld = balanceOf(wallet);
        uint256 currentTokens = tokens.current();
        uint256 x = 0;

        uint256[] memory _tokens = new uint256[](tokensHeld);
        
        for (uint256 i;i < currentTokens;i++) {
            if (ownerOf(i) == wallet) {
                _tokens[x] = i;
                x++;
            }
        }

        return _tokens;
    }

    function maxSupply() external view returns(uint256) {
        return tokens.current();
    }
}
