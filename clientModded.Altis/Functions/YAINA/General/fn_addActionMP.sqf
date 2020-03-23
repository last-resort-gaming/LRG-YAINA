/*
Function: YAINA_fnc_addActionMP

Description:
	Add given action to all clients incl. JIP.

Parameters:
	The action to be added to all players.

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if (!isServer) exitWith {
    _this remoteExec [QYFNC(addActionMP), 2];
};

// Add it for JIP clients
YVAR(addActionMPList) pushBack _this;

// This is duplicated in onPlayerConnected
[_this,     {
    _obj  = _this deleteAt 0;
    _code = _this deleteAt 0;
    _evt  = _obj addAction _this;
    [_obj, _evt] call _code;
}] remoteExec ["call"];