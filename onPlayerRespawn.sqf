/*
	author: MartinCo
	description: none
	returns: nothing
*/

player enableFatigue false;

[] execVM "scripts\YAINA\earplugs.sqf";

player setUnitLoadout (player getVariable["LastLoadout",[]]);