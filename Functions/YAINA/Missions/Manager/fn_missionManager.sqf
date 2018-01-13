/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// very simple job, make sure X main AOs are running, X Infantry Objectives, and make sure
// we add priority missions from time to time...

// If not a server, we shouldn't be here
if (!isServer) exitWith {};

[{
    params ["_args", "_pfhID"];

    // If we're paused, pause
    if (GVAR(paused)) exitWith {};

    private _maxAOs = 2;
    private _maxIOs = 1;
    private _maxSMs = 2;

    private _nAO = 0;
    private _nIO = 0;
    private _nSM = 0;

    private _PMMinTime = 300; // Min time between two pressure missions
    private _PMSplay   = 600; // Random splay to add onto that

    {
        _c  = _x select 2;
        if (_c isEqualTo "AO") then { INCR(_nAO); };
        if (_c isEqualTo "IO") then { INCR(_nIO); };
        if (_c isEqualTo "SM") then { INCR(_nSM); };
    } count GVAR(hcDCH);

    // We create only one each time this is called, this is so we can simply pick
    // the right HC without having to guesstimate how many missions/subobjectives
    // etc will be created on a given HC

    // The only real negative is that it'll take longer to spool up the server, but
    // for 5 objectives thats 2.5 minutes...no biggie

    // What should I create?

    private _start    = nil;
    private _startFnc = nil;

    if (_nAO < _maxAOs) then {
        _start = QOFNC(mainAO);
    };

    if !(isNil "_start") then {
        [_start] call FNC(startMission);
    };

}, 30, []] call CBA_fnc_addPerFrameHandler;

