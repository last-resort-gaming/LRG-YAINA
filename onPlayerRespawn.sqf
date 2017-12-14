/*
	author: MartinCo
	description: none
	returns: nothing
*/

player enableFatigue false;

[] execVM "scripts\YAINA\earplugs.sqf";

// Re-add repack mag actiong
player addAction [
    "Repack Magazines",
    { call outlw_MR_createDialog; },
    "",-99
];

// readd players to zeus
[[player], false] call YAINA_fnc_addEditableObjects;

// Update their respawn pos if not set, else move them there

if (isNil { player getVariable "YAINA_RespawnPos"; } ) then {
    // save respawn position
    player setVariable ["YAINA_RespawnPos", getPosATL player];
    player setVariable ["YAINA_RespawnDir", getDir player];
} else {
    // move them there, else default respawn pos
    _defaultRP = getMarkerPos "respawn";
    _defaultRP set [2,0];
    player setPosATL (player getVariable ["YAINA_RespawnPos", _defaultRP]);
    player setDir (player getVariable ["YAINA_RespawnDir", 0]);
};