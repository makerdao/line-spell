pragma solidity ^0.5.4;

import "ds-test/test.sol";

import "./LineSpell.sol";

contract LineSpellTest is DSTest {
    LineSpell spell;

    function setUp() public {
        spell = new LineSpell();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
