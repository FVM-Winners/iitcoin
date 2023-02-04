// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract PriceOracle {
    uint256 public s_priceFIL;
    address private immutable i_owner;

    constructor(address _owner) {
        i_owner = _owner;
    }

    function setPriceFIL(uint256 _price) external {
        require(msg.sender == i_owner);
        s_priceFIL = _price;
    }

    function getPriceFIL() public view returns (uint256) {
        return s_priceFIL;
    }
}
