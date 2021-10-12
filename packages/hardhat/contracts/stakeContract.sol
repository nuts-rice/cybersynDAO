pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "./ExampleExternalContract.sol";


contract Greeter{

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balance;
  uint256 public constant threshold = 1 ether;
  bool public isActive = false;
  uint256 public deadline = block.timestamp + 30 seconds;

  event Stake (address indexed sender, uint256 amount);

  //@notice modifier to contract that requires deadline to be reached or not
  modifier deadlineReached (bool requireReached){
    uint256 timeRemaining = timeLeft();
    if (requireReached){
      require (timeRemaining == 0, "deadline is not reached yet");
    } else {
      require (timeRemaining > 0, "Deadline not reached yet");
    }
    _;
  }

  //@notice modifier that requires external contract to not be completed
  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require (!completed, "staking process already completed");
    _;
  }

  constructor(address exampleExternalContractAddress) {
    // what should we do on deploy?
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function execute() public stakeNotCompleted deadlineReached(false){
    uint256 contractBalance = address(this).balance;

    require (contractBalance >= threshold, "threshold not reached");

    (bool sent,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));
    require (sent, "exampleExternalContract.complete failed");
  }

  function stake() public payable deadlineReached(false) stakeNotCompleted {
    balance[msg.sender]  += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  function withdraw() public deadlineReached(true) stakeNotCompleted{
    uint256 userBalance = balance[msg.sender];

    require(userBalance > 0, "you dont have the balance to withdraw");

    balance[msg.sender] = 0;

    (bool sent, ) = msg.sender.call{value: userBalance}("");
    require (sent, "Failed to send user balance back to user");
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline -  block.timestamp;
    }
  }
}
