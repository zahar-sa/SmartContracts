// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract SimpleStore{
    uint storeddata;

    function set(uint x) public {
        storeddata = x;

    }

    function get() public view returns(uint){
        return storeddata;
    }


}
