/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if(isServer) then {

    // we dispatch a list of server commands to clients
    GVAR(commands) = [
        ["help", "credits", "addcredits", "mmpause", "mmstart", "mmlist", "mmstop", "report", "setadmin", "settrait", "revive","zeuslist", "zeusadd", "zeusdel", "abusemsg", "ffmsg", "helimsg", "hqmsg", "lwmsg", "mertmsg", "pilotmsg", "uavmsg", "ugmsg", "vehmsg", "30mban", "24hban", "72hban"],
        [0, 0, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3,3,3, 1,1,1,1,1,1,1,1,1,1,3,3,3]
    ];

    GVAR(becCommands) = ["30mban", "24hban", "72hban"];

    publicVariable QVAR(commands);
    publicVariable QVAR(becCommands);

    _cmdMax = 0;
    { if (_x > _cmdMax) then { _cmdMax = _x; }; true } count ((GVAR(commands) select 0) apply { count _x; });
    GVAR(cmdMax) = _cmdMax;

};

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

                        if (_command in (GVAR(commands) select 0)) then {
                            if !(_command in GVAR(becCommands)) then {
                                systemChat _message;
                                [_command, _argument] remoteExecCall [QFNC(exec), 2];
                                _r = true;
                            };
                        } else {
                            systemChat format["Invalid Command: %1", _command];
                            _r = true;
                        };

                        if(_r) then {
                            _display closeDisplay 2;
                        };
                    };
                };
                _r
            }];
            waitUntil {isNull (findDisplay 24)};
        };
    };
};