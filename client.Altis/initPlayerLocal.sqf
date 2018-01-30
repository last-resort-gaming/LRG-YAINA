/*
	author: MartinCo
	description: none
	returns: nothing
*/

if (!isDedicated) then {

    enableSentences false;

    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

    [] execVM "scripts\QS\QS_icons.sqf";

    // Repack
    [] execVM "scripts\outlawled\magRepack\MagRepack_init_sv.sqf";
};