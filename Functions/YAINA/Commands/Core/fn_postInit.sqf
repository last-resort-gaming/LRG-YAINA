/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if(isServer) then {

    // we dispatch a list of server commands to clients
    GVAR(commandList) = ("true" configClasses (missionconfigfile >> "CfgFunctions" >> "YAINA_CMD" >> "Commands")) apply { configName _x };
    publicVariable QVAR(commandList);

};

if (hasInterface) then {

    diag_log "Adding listener for CBA_events_chatMessageSent";

    // Client side, we just check if the command is defined, if it is, send it to the server for processing
    ["CBA_events_chatMessageSent", {
        params ["_message"];

        if (((_message select [0,1]) isEqualTo "#") && {!isNil QVAR(commandList)}) then {
            private _index = _message find " ";

            // no argument
            if (_index isEqualTo -1) then {
                _index = count _message;
            };

            private _command = _message select [1, _index - 1];
            private _argument = _message select [_index + 1];

            if (_command in GVAR(commandList)) then {
                _argument call (missionNamespace getVariable [format["YAINA_CMD_fnc_%1", _command], {}]);
            };
        };

    }] call CBA_fnc_addEventHandler;
};