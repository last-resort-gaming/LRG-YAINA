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
        _start    = QFNC(spawnMainAO);
        _startFnc = FNC(spawnMainAO);
    };

    if !(isNil "_start") then {

        // Pick an HC to run on base on min number of non CLEANUP missions currently running
        _hcList = [[], []];
        {
            if !(_x select 0 isEqualTo profileName) then {
                if !(_x select 2 isEqualTo "CLEANUP") then {
                    _hc = _x select 0;
                    _id = _hcList find _hc;
                    if(_id isEqualTo -1) then {
                        (_hcList select 0) pushBack _hc;
                        (_hcList select 1) pushBack 1;
                    } else {
                        (_hcList select 1) set [_id, ((_hcList select 1) select _id) + 1];
                    };
                };
            };
        } forEach GVAR(hcDCH);

        // Add any HCs that don't have any PFHs currently on them
        {
            // Just don't pick ourselves
            if !(_x isEqualTo profileName) then {
                _id = (_hcList select 0) find _x;
                if (_id isEqualTo -1) then {
                    (_hcList select 0) pushBack _x;
                    (_hcList select 1) pushBack 0;
                };
            };
        } forEach GVAR(hcList);

        // sort the list based on the number of PFHs
        _sortedHCs = [_hcList select 1, [],{_x}, "ASCEND"] call BIS_fnc_sortBy;
        _dispatched = false;

        // Now find a suitable, online HC
        while { !(_sortedHCs isEqualTo []) and !_dispatched } do {

            _id = (_hcList select 1) find (_sortedHCs select 0);
            _sortedHCs deleteAt 0;

            if !(_id isEqualTo -1) then {

                _hc = missionNamespace getVariable ((_hcList select 0) select _id);

                // We delete from the hcList to avoid getting the same one twice if
                // they have the same score
                (_hcList select 0) deleteAt _id;
                (_hcList select 1) deleteAt _id;

                if !((GVAR(hcList) find (name _hc)) isEqualTo -1) then {
                    diag_log format ["missionManager: dispatching mission %1 to %2", _start, _hc];
                    remoteExec [_start, _hc];
                    _dispatched = true;
                };
            };
        };

        // No suitable HC found, start on server here
        if !(_dispatched) then {
            diag_log format ["missionManager: starting %1 on server", _start];
            call _startFnc;
        };
    };

}, 30, []] call CBA_fnc_addPerFrameHandler;

