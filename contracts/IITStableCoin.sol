// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./priceOracle.sol";

contract IITStableCoin {
    string public constant name = "IIT Stablecoin";
    string public constant symbol = "IIT";
    uint256 public totalSupply;

    PriceOracle priceOracle =
        PriceOracle(0x4B3C2d0d9D5Fbd6B4130bEC84c273EdCa72fc2c0);

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public filLocked;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    uint256 public priceOfFIL = priceOracle.getPriceFIL();

    function mint(uint _wad) external payable {
        uint256 value = msg.value;
        uint256 wad = _wad * 10 ** 18;
        require(
            (value * priceOfFIL * 8) / 10 >= wad,
            "Insufficient FIL provided"
        );
        filLocked[msg.sender] += value;
        balanceOf[msg.sender] += wad;
        totalSupply += wad;
        emit Transfer(address(0), msg.sender, wad);
    }

    function burn(address usr, uint _wad) external {
        uint256 wad = _wad * 10 ** 18;
        require(balanceOf[usr] >= wad, "Dai/insufficient-balance");
        balanceOf[msg.sender] -= wad;
        filLocked[msg.sender] -= (wad * 5) / (4 * priceOfFIL);
        totalSupply = totalSupply - wad;
        if ((filLocked[usr] * priceOfFIL * 8) / 10 >= balanceOf[usr]) {
            require(usr == msg.sender, "User is overcollateralised");
        } else {
            require(usr != msg.sender, "User is undercollateralised");
        }
        (bool sent, ) = msg.sender.call{value: (wad * 5) / (4 * priceOfFIL)}(
            ""
        );
        require(sent, "Transaction failed!");
        emit Transfer(usr, address(0), wad);
    }

    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad, "Dai/insufficient-balance");
        if (src != msg.sender) {
            require(
                allowance[src][msg.sender] >= wad,
                "Dai/insufficient-allowance"
            );
            allowance[src][msg.sender] = allowance[src][msg.sender] - wad;
        }
        balanceOf[src] -= wad;
        filLocked[src] -= (wad * 5) / 4;
        balanceOf[dst] += wad;
        filLocked[dst] += (wad * 5) / 4;

        emit Transfer(src, dst, wad);
        return true;
    }

    function approve(address usr, uint wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }
}
