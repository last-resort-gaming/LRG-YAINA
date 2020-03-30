/*
	author: MartinCo
	description: none
	returns: nothing
*/

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

enableSentences false;

if !(isNull _oldUnit) then {
    [_oldUnit, 5] remoteExec ["YAINA_fnc_deleteVehicleIn", 2];
};

// readd players to zeus
[[player], false] call YAINA_fnc_addEditableObjects;


// Turn off bloody auto-voice for all players, uses JIP but these are
// auto-cleaned up when players leave due to being assigned to an object
player disableConversation true;
[player ,"NoVoice"] remoteExec ["setSpeaker",0,true];


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