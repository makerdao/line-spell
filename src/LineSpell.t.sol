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
    bytes32 ilk = "foobar";
    uint256 constant ONE = 10 ** 18;
    uint256 constant line = 10 * ONE;

    function setUp() public {
        super.setUp();
        deploy();
    }

    function testLine() public {
        spell = new LineSpell(address(mom), address(momLib), address(pit), ilk, line);
        DSRoles role = DSRoles(address(mom.authority()));
        role.setRootUser(address(spell), true);
        spell.cast();
        (, uint256 l) = pit.ilks(ilk);
        assertEq(line, l);
    }
}
