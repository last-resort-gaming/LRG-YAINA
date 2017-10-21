/*
	author: MartinCo
	description: none
	returns: nothing
*/

if (isDedicated) then {

    _lightViewDistance = 2 * worldSize * sqrt 2;
    { _x allowDamage false; } forEach nearestObjects[getMarkerPos "LightMarker", ["Land_NavigLight"], 500];

} else {

    enableSentences false;

    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

    [] execVM "scripts\QS\QS_icons.sqf";

    // Ensure the airstrip lights are visible from afar (whole world)
    _lightViewDistance = 2 * worldSize * sqrt 2;
    _navLights         = getMarkerPos "Base_Area" nearObjects ["Land_NavigLight", 500];

    { _x setLightFlareMaxDistance _lightViewDistance; } forEach _navLights;

    // And disable damage on them
    if(isServer) then { { _x allowDamage false; } forEach _navLights; };

    call YAINA_fnc_baseProtection;
};