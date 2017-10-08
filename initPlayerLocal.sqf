/*
	author: MartinCo
	description: none
	returns: nothing
*/

if !(isServer or hasInterface) then {

} else {

    enableSentences false;
    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

    [] execVM "scripts\QS\QS_icons.sqf";

};