// SPDX-License-Identifier: MIT

/*
Welcome to the DOGHOUSE 8===8

              _
            ,/A\,
          .//`_`\\,
        ,//`____-`\\,
      ,//`[_ROVER_]`\\,
    ,//`=  ==  __-  _`\\,
   //|__=  __- == _  __|\\
   ` |  __ .-----.  _  | `
     | - _/       \-   |
     |__  | .-"-. | __=|
     |  _=|/)   (\|    |
     |-__ (/ a a \) -__|
     |___ /`\_Y_/`\____|
          \)8===8(/

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TheDogHouse is AccessControlEnumerable, IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    IERC721 public nft;
    IERC20 public rewardToken;

    uint256 public timeUnit;
    uint256 public rewardsPerUnitTime;

    struct Stake {
        address owner;
        uint256 stakedAt;
    }

    mapping(uint256 => Stake) public vault;
    EnumerableSet.UintSet private stakedTokens;

    uint256 public rewardTokenBalance;

    // Events remain the same

    constructor(address _nftAddress, address _rewardTokenAddress, uint256 _timeUnit, uint256 _rewardsPerUnitTime) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        nft = IERC721(_nftAddress);
        rewardToken = IERC20(_rewardTokenAddress);
        timeUnit = _timeUnit;
        rewardsPerUnitTime = _rewardsPerUnitTime;
    }

    // Modifier for role checking
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Caller is not an admin");
        _;
    }

    // Staking, unstaking, and reward token management functions remain similar, with added role checks where necessary

    function calculateReward(uint256 tokenId) public view returns (uint256 reward) {
        Stake memory stakeData = vault[tokenId];
        uint256 stakingDuration = block.timestamp - stakeData.stakedAt;
        uint256 timeUnitsStaked = stakingDuration / timeUnit;
        reward = timeUnitsStaked * rewardsPerUnitTime;
    }

    // Admin functions for updating contract parameters like NFT address, reward token address, etc.

    function setNFTAddress(address _nftAddress) external onlyAdmin {
        nft = IERC721(_nftAddress);
    }

    function setRewardTokenAddress(address _rewardTokenAddress) external onlyAdmin {
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function setTimeUnit(uint256 _timeUnit) external onlyAdmin {
        timeUnit = _timeUnit;
    }

    function setRewardsPerUnitTime(uint256 _rewardsPerUnitTime) external onlyAdmin {
        rewardsPerUnitTime = _rewardsPerUnitTime;
    }

    // Helper and view functions remain similar

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
