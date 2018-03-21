/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_owner", "_caller", "_argStr"];


{
    [[], {
        format["fps: %1: %2", profileName, diag_fps] remoteExec ["diag_log", 2];
    }] remoteExec ["call", _x];
    nil;
} count allPlayers;

_msg = "you will find players FPS on the server's rpt file";
_msg remoteExecCall ["systemChat", _owner];

_msg