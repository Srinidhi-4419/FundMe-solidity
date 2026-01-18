// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
    }

    function testDemo() public {
        assertTrue(true);
    }

    // function testMinimumUsd() public {
    //     assertEq(fundMe.MINIMUM_USD(), 518);
    // }
    function testOwner() public{
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }
    // how to work with addresses in test which are outisde of our control
    // 1. fork mainnet / testnet- COMMAND-forge test --match-test testPriceFeedVersion --fork-url <RPC_URL>
    // 2.uNIT TESTING
    // 3. INTEGRATION TESTING
    // 4. STAGING TESTING

    function testPriceFeedVersion() public{
        assertEq(fundMe.getVersion(), 4);
    }
}
