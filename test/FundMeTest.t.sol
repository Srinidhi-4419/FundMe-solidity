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

    function testMinimumUsd() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundUpdatesFundedDataStructure() public {
        address user = address(1);
        vm.deal(user, 10e18);
        vm.prank(user);

        fundMe.fund{value: 6e18}();

        uint256 amountFunded =
            fundMe.getaddresstoamountfunded(user);

        assertEq(amountFunded, 6e18);
    }

    function testFundersToArray() public {
        address user = address(1);
        vm.deal(user, 10e18);
        vm.prank(user);

        fundMe.fund{value: 6e18}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, user);
    }

    modifier funded() {
        address user = address(1);
        vm.deal(user, 10e18);
        vm.prank(user);
        fundMe.fund{value: 6e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        address user = address(1);
        vm.prank(user);
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance =
            address(fundMe).balance;
        uint256 startingOwnerBalance = address(this).balance;

        // Act
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = address(this).balance;

        assertEq(endingFundMeBalance, 0);
        // because of gas costs, can't assert equality
        assertGt(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint256 fundAmount = 6e18;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            vm.deal(funder, 10e18);
            vm.prank(funder);
            fundMe.fund{value: fundAmount}();
        }

        uint256 startingFundMeBalance =
            address(fundMe).balance;
        uint256 startingOwnerBalance = address(this).balance;

        // Act
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = address(this).balance;

        assertEq(endingFundMeBalance, 0);
        // because of gas costs, can't assert equality
        assertGt(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );

        // Make sure the funders are reset properly
        vm.expectRevert();
        fundMe.getFunder(0);
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            uint256 amountFunded =
                fundMe.getaddresstoamountfunded(funder);
            assertEq(amountFunded, 0);
        }
    }
}
