/**
* @dev StakingRewardsFactory v1.0.1
* @author Sparkle Loyalty Team ♥♥♥ SPRKL
*/


pragma solidity ^0.5.16;

import "../../openzeppelin-contracts/contracts/math/Math.sol";
import "../../openzeppelin-contracts/contracts/math/SafeMath.sol";
import "../../openzeppelin-contracts/contracts/token/ERC20/ERC20Detailed.sol";
import "../../openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol";
import "../../openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

// Inheritance
import "./interfaces/IStakingRewards.sol";
import "./RewardsDistributionRecipient.sol";

contract StakingRewards is IStakingRewards, RewardsDistributionRecipient, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 60 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
    ) public {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function lastTimeRewardApplicable() public view returns (uint256) {
            uint256 timeApp = Math.min(block.timestamp, periodFinish);
        return timeApp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            uint256 perTokenRate = rewardPerTokenStored;
        return perTokenRate;
      }
            uint256 perTokenRate = rewardPerTokenStored.add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply));
        return perTokenRate;
    }

    function earned(address account) public view returns (uint256) {
            uint256 tokensEarned = _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
        return tokensEarned;
    }

    function getRewardForDuration() external view returns (uint256) {
            uint256 rate = rewardRate.mul(rewardsDuration);
        return rate;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external payable nonReentrant updateReward(msg.sender) {
        uint256 collectionAddfee = 0.075 ether;  
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        // permit
        IUniswapV2ERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);      
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
        
    }

    function stake(uint256 amount) external payable nonReentrant updateReward(msg.sender) {
        uint256 collectionAddfee = 0.075 ether;  
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
       
    }
    
    
 

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    

        // Sparkle Loyalty Team - Fuction is always failing *Removed Require* Better solution is needed
        // Changes uint to uint256 to help prevent overflow and ensure the funtion uses safeMath
        // Remove Unessicary loops to save gas 
        // uniswap - Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        //
        // uint balance = rewardsToken.balanceOf(address(this));
        // require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution setReward(address(0)) {
        if (block.timestamp >= periodFinish) {
             rewardRate = reward.div(rewardsDuration);
        // base instructions 
             lastUpdateTime = block.timestamp;
             periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
        } 
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
             rewardRate = reward.add(leftover).div(rewardsDuration);
        // base instructions 
             lastUpdateTime = block.timestamp;
             periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }
    
    
    function updateRewardAmount(uint256 newRate) external onlyRewardsDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
             rewardRate = newRate.div(rewardsDuration);
       // base instructions     
             lastUpdateTime = block.timestamp;
             periodFinish = block.timestamp.add(rewardsDuration);
       emit RewardUpdated(newRate);
        } 
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
              rewardRate = newRate.add(leftover).div(rewardsDuration);
        // base instructions     
             lastUpdateTime = block.timestamp;
             periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardUpdated(newRate);
    
    }

    /* ========== MODIFIERS ========== */
    
    // Modifier Set Reward modifier
    
     modifier setReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

     // Modifier *Update Reward modifier*
     
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */
    
    event RewardUpdated(uint256 reward);
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    
}

interface IUniswapV2ERC20 {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}
