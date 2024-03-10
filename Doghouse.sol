// SPDX-License-Identifier: MIT

/*
Welcome to the DOGHOUSE 8===8

Created by @ITZMIZZLE
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


pragma solidity 0.8.20;

import "@openzeppelin/contracts@4.4.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.0/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.4.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC20/utils/SafeERC20.sol";


contract TheDogHouse is Ownable, IERC721Receiver, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public rewardToken;
    IERC721 public nftCollection;

    uint256 public dailyEmission;
    uint256 public totalRewardsDistributed;

    struct Stake {
        address owner;
        uint256 stakedAt;
    }

    mapping(uint256 => Stake) public vault;

    event ItemStaked(uint256 tokenId, address owner);
    event ItemUnstaked(uint256 tokenId, address owner);
    event RewardClaimed(address owner, uint256 amount);

    constructor() {}

    function setRewardToken(address _rewardTokenAddress) external onlyOwner {
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function setNftCollection(address _nftCollectionAddress) external onlyOwner {
        nftCollection = IERC721(_nftCollectionAddress);
    }

    function setDailyEmission(uint256 _dailyEmission) external onlyOwner {
        dailyEmission = _dailyEmission;
    }

    function stakeTokens(uint256[] calldata tokenIds) external whenNotPaused nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Not the token owner");
            nftCollection.transferFrom(msg.sender, address(this), tokenId);
            vault[tokenId] = Stake(msg.sender, block.timestamp);
            emit ItemStaked(tokenId, msg.sender);
        }
    }

    function unstakeTokens(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(vault[tokenId].owner == msg.sender, "Not the staker");
            delete vault[tokenId];
            nftCollection.transferFrom(address(this), msg.sender, tokenId);
            emit ItemUnstaked(tokenId, msg.sender);
        }
    }

    function claimRewards(uint256[] calldata tokenIds) external nonReentrant {
        uint256 totalReward = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            Stake memory stake = vault[tokenId];
            require(stake.owner == msg.sender, "Not the staker");

            uint256 reward = calculateReward(stake.stakedAt);
            totalReward += reward;

            // Update the staked time to now
            vault[tokenId].stakedAt = block.timestamp;
        }

        require(totalRewardsDistributed + totalReward <= rewardToken.balanceOf(address(this)), "Not enough rewards");
        totalRewardsDistributed += totalReward;
        rewardToken.safeTransfer(msg.sender, totalReward);

        emit RewardClaimed(msg.sender, totalReward);
    }

    function calculateReward(uint256 stakedAt) public view returns (uint256) {
        uint256 stakingDuration = block.timestamp - stakedAt;
        uint256 reward = (dailyEmission * stakingDuration) / 1 days;
        return reward;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

