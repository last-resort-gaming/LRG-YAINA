/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_module", "_player"];

// Params
private _window    = 5;   // Tiemout
private _threshold  = 3;  // Max pings in given Timeout before action

// Update the var on the player [first_ping, count, warned]
private _data = _player getVariable QVAR(ping);
private _now  = time;

// If nil, it's the first time
if (isNil "_data") exitWith {
    _player setVariable [QVAR(ping), [_now, 1, False]];
};

// If not, we either, increment / reset the timer if it' been over 5 seconds
_data params ["_first", "_count", "_warned"];

// Reset if > _window
if ((_now - _first) > _window) exitWith {
    _player setVariable [QVAR(ping), [_now, 1, _warned]];
};

// Else increment count, if count is > 5 we action
_count = _count + 1;

if (_count > _threshold) exitWith {
    if (_warned) then {
        // Kick Time, We have to execute it on the player though
        [[], {
            // We schedule a kick in 7 seconds so they have enough time to read it, in case they're not
            // actually closing the dialog and go on a rager
            [{
                ["!kick timedout"] remoteExecCall ["YAINA_fnc_kickSelf", 2];
            }, [], 7] call CBAP_fnc_waitAndExecute;

            _result = ["You have failed to heed the warning regarding pinging zeus, as such you are being removed from the server", "You're getting kicked", "OK", false] call BIS_fnc_guiMessage;
            ["Accepted their zeus kick"] remoteExecCall ["YAINA_fnc_kickSelf", 2];
        }] remoteExec ["spawn", _player];
    } else {
        // Else Warn, and reset with warning state
        [[], {
            _bind    = actionKeysNames ["curatorInterface", 1];
            _title   = "Stop pinging zeus";
            _content = format["Please stop pinging zeus with %1, if you continue, you will be removed from the server.<br/><br/>", _bind];

            if (_bind isEqualTo '"Y"') then {
                _content = _content + "We recommend rebinding this key to 2xY (double Y) to avoid accidental pings.<br/><br/>";
            };
            _content = _content + "do you agree to stop?";

            _result = [_content, _title, "YES", "NO"] call BIS_fnc_guiMessage;
            if !(_result) then {
                [format["Disagreed to %1", toLower _title]] remoteExecCall ["YAINA_fnc_kickSelf", 2];
            };
        }] remoteExec ["spawn", _player];

        _player setVariable [QVAR(ping), [_now, 1, True]];
    };
};

// Just Set update
_data set[1, _count];
_player setVariable [QVAR(ping), _data];
