// * arithmetic operations revert on underflow and overflow
// * custom errors
// * functions outside contract
// * import {symbol1 as alias, symbol2} from "filename";
// * Salted contract creations / create2
// * SMTChecker

// SPDX-License-Identifier: MIT
pragma solidity 0.8;

// safe math
contract SafeMath {
    function testUnderflow() public pure returns (uint256) {
        uint256 x = 0;
        x--;
        return x;
    }

    function testUncheckedUnderflow() public pure returns (uint256) {
        uint256 x = 0;
        unchecked {
            x--;
        }
        return x;
    }
}

// custom error

error Unauthorized();

contract VendingMachine {
    address payable owner = payable(msg.sender);

    function withdraw() public {
        if (msg.sender != owner) revert Unauthorized();

        owner.transfer(address(this).balance);
    }
    // ...
}

error InsufficientBalance(uint256 available, uint256 required);

contract TestToken {
    mapping(address => uint256) balance;

    function transfer(address to, uint256 amount) public {
        if (amount > balance[msg.sender])
            revert InsufficientBalance({
                available: balance[msg.sender],
                required: amount
            });
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }
}

// functions outside contract

function helper(uint256 x) pure returns (uint256) {
    return x * 2;
}

contract SimpleAuction {
    function bid() public payable {
        // Function
        // ...
    }
}

contract TestHelper {
    function test() external pure returns (uint256) {
        return helper(123);
    }
}

// * import {symbol1 as alias, symbol2} from "filename";
import {Unauthorized, helper1 as h1} from "./NewFeatures.sol";

function helper1(uint256 x) view returns (uint256) {}

contract Import {}

// Salted contract creations / create2
contract D {
    uint256 public x;

    constructor(uint256 a) {
        x = a;
    }
}

contract Create2 {
    function getBytes32(uint256 salt) external pure returns (bytes32) {
        return bytes32(salt);
    }

    function getAddress(bytes32 salt, uint256 arg)
        external
        view
        returns (address)
    {
        address addr = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(
                                abi.encodePacked(type(D).creationCode, arg)
                            )
                        )
                    )
                )
            )
        );

        return addr;
    }

    address public deployedAddr;

    function createDSalted(bytes32 salt, uint256 arg) public {
        D d = new D{salt: salt}(arg);
        deployedAddr = address(d);
    }
}

// SMT
contract Overflow {
    uint256 immutable x;
    uint256 immutable y;

    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        return _x + _y;
    }

    constructor(uint256 _x, uint256 _y) {
        (x, y) = (_x, _y);
    }

    function stateAdd() public view returns (uint256) {
        return add(x, y);
    }
}
