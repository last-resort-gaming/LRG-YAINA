#include "script_component.hpp"

// execute JIP events after post init to guarantee execution of events added during postInit
[{
    {
        private _event = GVAR(eventNamespaceJIP) getVariable _x;
        if (_event isEqualType []) then {
            if ((_event select 0) isEqualTo EVENT_PVAR_STR) then {
                (_event select 1) call CBAP_fnc_localEvent;
            };
        };
    } forEach allVariables GVAR(eventNamespaceJIP);

    // allow new incoming jip events
    [QGVAR(eventJIP), CBAP_fnc_localEvent] call CBAP_fnc_addEventHandler;
}, []] call CBAP_fnc_execNextFrame;

if (isServer) then {
    CBAP_clientID = [0, 2] select isMultiplayer;
    addMissionEventHandler ["PlayerConnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner"];

        if (_owner != 2) then {
            CBAP_clientID = _owner;
            _owner publicVariableClient "CBAP_clientID";
            CBAP_clientID = [0, 2] select isMultiplayer;
        };
    }];
};

// custom chat command system
["CBAP_events_chatMessageSent", {
    params ["_message"];

    if (((_message select [0,1]) isEqualTo "#") && {!isNil QGVAR(customChatCommands)}) then {
        private _index = _message find " ";

        // no argument
        if (_index isEqualTo -1) then {
            _index = count _message;
        };

        private _command = _message select [1, _index - 1];
        private _argument = _message select [_index + 1];

        // check if command is available
        private _access = ["all"];

        if (IS_ADMIN || isServer) then {
            _access pushBack "admin";
        };

        if (IS_ADMIN_LOGGED || isServer) then {
            _access pushBack "adminlogged";
        };

        (GVAR(customChatCommands) getVariable _command) params ["_code", "_availableFor", "_thisArgs"];

        if (_availableFor in _access) then {
            [[_argument], _code] call {
                // prevent bad code from overwriting protected variables
                private ["_message", "_index", "_command", "_argument", "_access", "_code", "_availableFor"];
                (_this select 0) call (_this select 1);
            };
        };
    };
}] call CBAP_fnc_addEventHandler;

// And add the listener, manually setting the tag here due to the mod stealing it from our control
// and to keep it consistent without updating everything

_h = [] spawn {
    while {true} do {
        waitUntil {!(isNull (findDisplay 24))};
        _keyDown = (findDisplay 24) displayAddEventHandler ["KeyDown", {
            if ((_this select 1) in [28,156]) then {
                ["CBAP_events_chatMessageSent", [ctrlText ((_this select 0) displayCtrl 101), _this select 0]] call CBAP_fnc_localEvent;
            };
            false
        }];
        waitUntil {isNull (findDisplay 24)};
    };
};

nil;
