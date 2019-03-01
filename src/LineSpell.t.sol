// Copyright (C) 2019 Lorenzo Manacorda <lorenzo@mailbox.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.5.4;

import "ds-test/test.sol";
import "dss-deploy/DssDeploy.t.base.sol";

import "./LineSpell.sol";

contract LineSpellTest is DssDeployTestBase {
    LineSpell spell;
    bytes32 ilk = "GOLD";
    uint256 constant ONE  = 10 ** 18;
    uint256 constant line = 10 * ONE;

    function setUp() public {
        super.setUp();
        deploy();
    }

    function testCast() public {
        spell = new LineSpell(address(mom), address(momLib), address(pit), ilk, line);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);
        spell.cast();
        (, uint256 l) = pit.ilks(ilk);
        assertEq(line, l);
    }

    function testFailRepeatedCast() public {
        spell = new LineSpell(address(mom), address(momLib), address(pit), ilk, line);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);
        spell.cast();
        spell.cast();
    }
}

contract MultiLineSpellTest is DssDeployTestBase {
    MultiLineSpell spell;
    bytes32[] ilks;
    uint256[] lines;

    function setUp() public {
        super.setUp();
        deploy();
    }

    function testFailCastEmptyIlks() public {
        lines = [ 1 ];
        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);

        spell.cast();
    }

    function testFailCastEmptyLines() public {
        ilks = [ bytes32("GOLD") ];
        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);

        spell.cast();
    }

    function testFailCastBothEmpty() public {
        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);

        spell.cast();
    }

    function testFailCastMismatchedLengths() public {
        ilks = new bytes32[](1);
        lines = new uint256[](2);
        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);

        spell.cast();
    }

    function testCast() public {
        ilks  = [ bytes32("GOLD"), bytes32("GELD") ];
        lines = [ 100, 200 ];

        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);
        spell.cast();

        for (uint8 i = 0; i < ilks.length; i++) {
            (, uint256 l) = pit.ilks(ilks[i]);
            assertEq(lines[i], l);
        }
    }

    function testFailRepeatedCast() public {
        ilks  = [ bytes32("GOLD"), bytes32("GELD") ];
        lines = [ 100, 200 ];

        spell = new MultiLineSpell(address(mom), address(momLib), address(pit), ilks, lines);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);
        spell.cast();

        spell.cast();
    }
}
