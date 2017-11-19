/*
	author: MartinCo
	description: none
	returns: nothing
*/

if (isServer) then {

    // Ensure the airstrip lights are visible from afar (whole world)
    _lightViewDistance = 2 * worldSize * sqrt 2;
    _navLights         = getMarkerPos "Base_Area" nearObjects ["Land_NavigLight", 500];

    { _x setLightFlareMaxDistance _lightViewDistance; } forEach _navLights;

    // And disable damage on them
    { _x allowDamage false; } forEach _navLights;

};

if (isDedicated) then {
    // Pass
} else {

    enableSentences false;

    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

    [] execVM "scripts\QS\QS_icons.sqf";

    // Repack
    [] execVM "scripts\outlawled\magRepack\MagRepack_init_sv.sqf";
};