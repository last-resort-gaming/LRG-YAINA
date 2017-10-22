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
