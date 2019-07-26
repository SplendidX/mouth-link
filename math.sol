pragma solidity 0.4.24;

library Math {
    function abs(int a) internal pure returns (int result) {
        return (a < 0 ? -a : a);
    }
}
