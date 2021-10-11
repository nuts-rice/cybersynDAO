pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "./ExampleExternalContract";


contract Staker {

  //event SetPurpose(address sender, string purpose);

  ExampleExternalContract public exampleExternalContract;


  //Balance of users funds
  mapping(address => uint256) public balances;

  //threshold for staking
  uint256 public constant threashold = 1 ether;

  event Stake(address indexed sender, uint256 amount)

  // @param exampleExternalContractAddress is contract that will hold staked funds
  constructor(address exampleExternalContractAddress) public{
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake public payable {
    balances[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }
}
