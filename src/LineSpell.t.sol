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
    uint256 constant line = 10 * 10**18;
    uint256 wait;

    function elect() private {
        DSRoles role = DSRoles(address(pause.authority()));
        role.setRootUser(address(spell), true);
    }

    function setUp() public {
        super.setUp();
        deploy();
        wait = pause.delay();
    }

    function testConstructor() public {
        spell = new LineSpell(address(pause), address(govActions), address(vat), ilk, line);

        bytes memory expectedSig = abi.encodeWithSignature(
            "file(address,bytes32,bytes32,uint256)",
            vat, ilk, bytes32("line"), line
        );
        assertEq0(spell.sig(), expectedSig);

        assertEq(address(spell.pause()), address(pause));
        assertEq(address(spell.plan()),  address(govActions));
        assertEq(address(spell.vat()),   address(vat));

        assertEq(spell.line(), line);
        assertEq(spell.ilk(),  ilk);
        assertEq(spell.eta(), 0);

        assertTrue(!spell.done());
    }

    function testCast() public {
        spell = new LineSpell(address(pause), address(govActions), address(vat), ilk, line);
        elect();
        spell.schedule();
        hevm.warp(now + wait);

        spell.cast();
        (,,, uint256 l,) = vat.ilks(ilk);
        assertEq(line, l);
    }

    function testFailRepeatedCast() public {
        spell = new LineSpell(address(pause), address(govActions), address(vat), ilk, line);
        elect();
        spell.schedule();
        hevm.warp(now + wait);

        spell.cast();
        spell.cast();
    }
}
