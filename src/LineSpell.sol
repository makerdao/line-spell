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

contract MomLike {
    function execute(address, bytes memory) public;
}

contract LineSpell {
    MomLike mom;
    address momLib;
    address vat;
    bytes32 ilk;
    uint256 line;
    bool    done;

    constructor(address _mom, address _momLib, address _vat, bytes32 _ilk, uint256 _line) public {
        mom    = MomLike(_mom);
        momLib = _momLib;
        vat    = _vat;
        ilk    = _ilk;
        line   = _line;
    }

    function cast() public {
        require(!done, "spell-already-cast");

        bytes memory sig =
            abi.encodeWithSignature(
                "file(address,bytes32,bytes32,uint256)",
                vat,
                ilk,
                bytes32("line"),
                line
        );
        mom.execute(momLib, sig);

        done = true;
    }
}

contract MultiLineSpell {
    MomLike   mom;
    address   momLib;
    address   vat;
    bytes32[] ilks;
    uint256[] lines;
    bool      done;

    constructor(address _mom, address _momLib, address _vat, bytes32[] memory _ilks, uint256[] memory _lines) public {
        require(_ilks.length == _lines.length, "mismatched lengths of ilks, lines");
        require(_ilks.length > 0, "no ilks");

        mom    = MomLike(_mom);
        momLib = _momLib;
        vat    = _vat;
        ilks   = _ilks;
        lines  = _lines;
    }

    function cast() public {
        require(!done, "spell already cast");

        for (uint256 i = 0; i < ilks.length; i++) {
            bytes memory sig =
                abi.encodeWithSignature(
                    "file(address,bytes32,bytes32,uint256)",
                    vat,
                    ilks[i],
                    bytes32("line"),
                    lines[i]
            );
            mom.execute(momLib, sig);
        }

        done = true;
    }
}
