/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Curious case, we must log here, due to the impending restart
[_caller, "restart", true, "restarting"] call FNC(log);
SERVER_COMMAND_PASSWORD serverCommand "#restart";