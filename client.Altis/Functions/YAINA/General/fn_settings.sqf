/*
Function: YAINA_fnc_settings

Description:
    A bit crude, but simple for adding zeusdays
    with an easier configuration of globals for
    the server to sort its stuff out and what
    should be running without playing too much
    roulette with initialization ordering

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

// Bring in external settings file
call compileFinal preprocessFile "settings.sqf";