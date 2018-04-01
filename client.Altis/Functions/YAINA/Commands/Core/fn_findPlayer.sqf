/*
	author: Martin
	description: none
	returns: player, null, or
*/

params ["_prefix"];

_pl = count _prefix;

_r = allPlayers select { ((name _x) select [0, _pl]) isEqualTo _prefix };

// However a direct match wins
_d = _r select { (name _x) isEqualTo _prefix };

if !(_d isEqualTo []) exitWith { _d };

// If r is empty, lookup based on guid
if (_r isEqualTo []) then {

    {
        if (getPlayerUID _x isEqualTo _prefix) exitWith {
            _r = [_x];
        };
        nil;
    } count allPlayers;
};

_r