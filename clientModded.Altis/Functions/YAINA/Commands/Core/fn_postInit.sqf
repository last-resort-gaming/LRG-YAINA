/*
Function: YAINA_CMD_fnc_postInit

Description:
	Handles initialization for the commands system.
    Setup is mainly concerned with handling post-ban messages 
    and display population.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

if (hasInterface) then {

    _h = [] spawn {
        while {true} do {
            waitUntil {!(isNull (findDisplay 24))};
            _keyDown = (findDisplay 24) displayAddEventHandler ["KeyDown", {

                private _r = false;
                if ((_this select 1) in [28,156]) then {

                    private _display = (_this select 0);
                    private _message = ctrlText (_display displayCtrl 101);

                    if ((_message select [0,1]) isEqualTo "!") then {

                        private _index = _message find " ";

                        if (_index isEqualTo -1) then {
                            _index = count _message;
                        };

                        private _command = _message select [1, _index - 1];
                        private _argument = _message select [_index + 1];

                        if !(_command in GVAR(becCommands)) then {
                            [_command, _argument] remoteExecCall [QFNC(exec), 2];
                            _r = true;
                        } else {
                            if !(_command isEqualTo "hrestart") then {
                                systemChat "BAN issued: remember to report !report";
                                [name player, _command, "BEC", _argument] remoteExecCall [QFNC(log), 2];
                            };
                        };

                        if(_r) then {
                            _display closeDisplay 24;
                        };
                    };
                };

                _r
            }];
            waitUntil {isNull (findDisplay 24)};
        };
    };
};