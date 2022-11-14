// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        // check if fund is at least 50 usd
        require(
            msg.value.getConversionRate() >= minimumUsd,
            "Didn't send enough!"
        );
        // save record of funder
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            // reset all funds to 0
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the funders array
        funders = new address[](0);
        // transfer funds to wallet
        (bool callSuccess, ) = /* bytes memory dataReturned */
        payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner!");
        // proceed with the rest of the code flow
        _;
    }
}
