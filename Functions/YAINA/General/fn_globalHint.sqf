/*
	author: Martin
	description: none
	returns: nothing
*/

// Simple, just send a global hint

params ["_msg"];

[_msg] remoteExecCall ["hint", 0];