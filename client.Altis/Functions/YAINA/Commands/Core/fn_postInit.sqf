/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if(isServer) then {

    // we dispatch a list of server commands to clients
    GVAR(commands) = [
        ["help", "credits", "addcredits", "ugmsg", "mmpause", "mmstart", "mmlist", "mmstop", "report", "setadmin", "settrait", "revive","zeuslist", "zeusadd", "zeusdel", "abusemsg", "ffmsg", "helimsg", "hqmsg", "lwmsg", "mertmsg", "pilotmsg", "uavmsg", "ugmsg", "vehmsg"],
        [0, 0, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3,3,3, 1,1,1,1,1,1,1,1,1,1]
    ];
    
    publicVariable QVAR(commands);

    _cmdMax = 0;
    { if (_x > _cmdMax) then { _cmdMax = _x; }; true } count ((GVAR(commands) select 0) apply { count _x; });
    GVAR(cmdMax) = _cmdMax;

};

if (hasInterface) then {

    diag_log "Adding listener for CBAP_events_chatMessageSent";

    // Client side, we just check if the command is defined, if it is, send it to the server for processing
    ["CBAP_events_chatMessageSent", {
        params ["_message"];

        if (((_message select [0,1]) isEqualTo "#") && {!isNil QVAR(commands)}) then {
            private _index = _message find " ";

            // no argument
            if (_index isEqualTo -1) then {
                _index = count _message;
            };

            private _command = _message select [1, _index - 1];
            private _argument = _message select [_index + 1];

            if (_command in (GVAR(commands) select 0)) then {
                [_command, _argument] remoteExecCall [QFNC(exec), 2];
            };
        };

    }] call CBAP_fnc_addEventHandler;
};