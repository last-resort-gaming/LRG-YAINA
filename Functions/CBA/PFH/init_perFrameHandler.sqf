#define DELAY_MONITOR_THRESHOLD 1 // Frames

CBA_perFrameHandlerArray = [];
CBA_lastTickTime = diag_tickTime;

CBA_waitAndExecArray = [];
CBA_waitAndExecArrayIsSorted = false;
CBA_nextFrameNo = diag_frameno + 1;
// PostInit can be 2 frames after preInit, need to manually set nextFrameNo, so new items get added to buffer B while processing A for the first time:
CBA_nextFrameBufferA = [[[], {CBA_nextFrameNo = diag_frameno;}]];
CBA_nextFrameBufferB = [];
CBA_waitUntilAndExecArray = [];

// per frame handler system
CBA_fnc_onFrame = {
    private _tickTime = diag_tickTime;
    call CBA_fnc_missionTimePFH;

    // Execute per frame handlers
    {
        _x params ["_function", "_delay", "_delta", "", "_args", "_handle"];

        if (diag_tickTime > _delta) then {
            _x set [2, _delta + _delay];
            [_args, _handle] call _function;
            false
        };
    } count CBA_perFrameHandlerArray;


    // Execute wait and execute functions
    // Sort the queue if necessary
    if (!CBA_waitAndExecArrayIsSorted) then {
        CBA_waitAndExecArray sort true;
        CBA_waitAndExecArrayIsSorted = true;
    };
    private _delete = false;
    {
        if (_x select 0 > CBA_missionTime) exitWith {};

        (_x select 2) call (_x select 1);

        // Mark the element for deletion so it's not executed ever again
        CBA_waitAndExecArray set [_forEachIndex, objNull];
        _delete = true;
    } forEach CBA_waitAndExecArray;
    if (_delete) then {
        CBA_waitAndExecArray = CBA_waitAndExecArray - [objNull];
    };


    // Execute the exec next frame functions
    {
        (_x select 0) call (_x select 1);
        false
    } count CBA_nextFrameBufferA;
    // Swap double-buffer:
    CBA_nextFrameBufferA = CBA_nextFrameBufferB;
    CBA_nextFrameBufferB = [];
    CBA_nextFrameNo = diag_frameno + 1;


    // Execute the waitUntilAndExec functions:
    _delete = false;
    {
        // if condition is satisfied call statement
        if ((_x select 2) call (_x select 0)) then {
            (_x select 2) call (_x select 1);

            // Mark the element for deletion so it's not executed ever again
            CBA_waitUntilAndExecArray set [_forEachIndex, objNull];
            _delete = true;
        };
    } forEach CBA_waitUntilAndExecArray;
    if (_delete) then {
        CBA_waitUntilAndExecArray = CBA_waitUntilAndExecArray - [objNull];
    };
};

// fix for save games. subtract last tickTime from ETA of all PFHs after mission was loaded
addMissionEventHandler ["Loaded", {
    private _tickTime = diag_tickTime;

    {
        _x set [2, (_x select 2) - CBA_lastTickTime + _tickTime];
    } forEach CBA_perFrameHandlerArray;

    CBA_lastTickTime = _tickTime;
}];

CBA_missionTime = 0;
CBA_lastTime = time;

// increase CBA_missionTime variable every frame
if (isMultiplayer) then {
    // multiplayer - no accTime in MP
    if (isServer) then {
        // multiplayer server
        CBA_fnc_missionTimePFH = {
            if (time != CBA_lastTime) then {
                CBA_missionTime = CBA_missionTime + (_tickTime - CBA_lastTickTime);
                CBA_lastTime = time; // used to detect paused game
            };

            CBA_lastTickTime = _tickTime;
        };

        addMissionEventHandler ["PlayerConnected", {
            (_this select 4) publicVariableClient "CBA_missionTime";
        }];
    } else {
        CBA_missionTime = -1;

        // multiplayer client
        0 spawn {
            "CBA_missionTime" addPublicVariableEventHandler {
                CBA_missionTime = _this select 1;

                CBA_lastTickTime = diag_tickTime; // prevent time skip on clients

                CBA_fnc_missionTimePFH = {
                    if (time != CBA_lastTime) then {
                        CBA_missionTime = CBA_missionTime + (_tickTime - CBA_lastTickTime);
                        CBA_lastTime = time; // used to detect paused game
                    };

                    CBA_lastTickTime = _tickTime;
                };
            };
        };
    };
} else {
    // single player
    CBA_fnc_missionTimePFH = {
        if (time != CBA_lastTime) then {
            CBA_missionTime = CBA_missionTime + (_tickTime - CBA_lastTickTime) * accTime;
            CBA_lastTime = time; // used to detect paused game
        };

        CBA_lastTickTime = _tickTime;
    };
};
