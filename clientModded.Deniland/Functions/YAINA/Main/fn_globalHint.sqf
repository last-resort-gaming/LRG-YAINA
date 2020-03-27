/*
Function: YAINA_fnc_globalHint

Description:
	Send a global hint to all players containing given message.

Parameters:
	_msg - The message that shall be shown using the hint

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

// Simple, just send a global hint

params ["_msg"];

[_msg] remoteExecCall ["hint", 0];