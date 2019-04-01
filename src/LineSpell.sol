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

contract PauseLike {
    function plan(address, bytes memory, uint256) public;
    function exec(address, bytes memory, uint256) public;
}

contract LineSpell {
    PauseLike pause;
    address   plan;
    uint256   eta;
    bytes     sig;
    address   vat;
    bytes32   ilk;
    uint256   line;
    bool      done;

    constructor(address _pause, address _plan, address _vat, bytes32 _ilk, uint256 _line) public {
        pause = PauseLike(_pause);
        plan  = _plan;
        vat   = _vat;
        ilk   = _ilk;
        line  = _line;
        sig   = abi.encodeWithSignature(
                "file(address,bytes32,bytes32,uint256)",
                vat,
                ilk,
                bytes32("line"),
                line
        );

    }

    function schedule(uint256 wait) public {
        require(eta == 0, "spell-already-scheduled");
        eta = now + wait;

        pause.plan(plan, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");

        pause.exec(plan, sig, eta);

        done = true;
    }
}

contract MultiLineSpell {
    PauseLike pause;
    address   plan;
    uint256   eta;
    address   vat;
    bytes32[] ilks;
    uint256[] lines;
    bool      done;

    constructor(address _pause, address _plan, address _vat, bytes32[] memory _ilks, uint256[] memory _lines) public {
        require(_ilks.length == _lines.length, "mismatched lengths of ilks, lines");
        require(_ilks.length > 0, "no ilks");

        pause = PauseLike(_pause);
        plan  = _plan;
        vat   = _vat;
        ilks  = _ilks;
        lines = _lines;
    }

    function schedule(uint256 wait) public {
        require(eta == 0, "spell-already-scheduled");
        eta = now + wait;

        for (uint256 i = 0; i < ilks.length; i++) {
            bytes memory sig =
                abi.encodeWithSignature(
                    "file(address,bytes32,bytes32,uint256)",
                    vat,
                    ilks[i],
                    bytes32("line"),
                    lines[i]
            );
            pause.plan(plan, sig, eta);
        }
    }

    function cast() public {
        require(!done, "spell-already-cast");

        for (uint256 i = 0; i < ilks.length; i++) {
            bytes memory sig =
                abi.encodeWithSignature(
                    "file(address,bytes32,bytes32,uint256)",
                    vat,
                    ilks[i],
                    bytes32("line"),
                    lines[i]
            );
            pause.exec(plan, sig, eta);
        }

        done = true;
    }
}
