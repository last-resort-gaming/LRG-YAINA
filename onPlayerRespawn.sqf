/*
	author: MartinCo
	description: none
	returns: nothing
*/

player enableFatigue false;

[] execVM "scripts\YAINA\earplugs.sqf";

player setUnitLoadout (player getVariable["LastLoadout",[]]);

// readd players to zeus
[[player], false] call YAINA_fnc_addEditableObjects;


// Update their respawn pos if not set, else move them there

if (isNil { player getVariable "YAINA_RespawnPos"; } ) then {
    // save respawn position
    player setVariable ["YAINA_RespawnPos", getPosATL player];
    player setVariable ["YAINA_RespawnDir", getDir player];
} else {
    // move them there
    player setPosATL (player getVariable ["YAINA_RespawnPos", _defaultRP]);
    player setDir (player getVariable ["YAINA_RespawnDir", 0]);
};