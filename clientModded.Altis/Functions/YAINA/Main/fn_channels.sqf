/*
Function: YAINA_fnc_channels

Description:
    Handle our channel setup in preInit to see if it sorts
    out the perma-transmitting on group upon join
    when this was in initPlayerLocal.
    Differs between TFAR and Vanilla radio setups.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

private _tfar = isClass(configFile >> "CfgPatches" >> "task_force_radio");

// Global channel management
if (_tfar) then {
    2 enableChannel false;          // Command
    3 enableChannel [true, false];  // Group
    4 enableChannel false;          // Vehicle
} else {
    3 enableChannel true;
    4 enableChannel true;
};

// Main Channel Management
[{
    _settings = [];

    // Command Channel Management
    _settings pushBack [1, ["HQ", "side-channel-talk"] call YAINA_fnc_testTraits, true];

    // Manage Command if we aren't TFAR
    if !(isClass(configFile >> "CfgPatches" >> "task_force_radio")) then {
        _settings pushBack [2, leader (group player) isEqualTo player];
    };

    {
        _x params ["_chan", "_destVoice", "_destChat"];
        if (isNil "_destChat") then { _destChat = _destVoice; };

        _destState = [_destChat, _destVoice];
        _chanState = channelEnabled _chan;

        if !(_destState isEqualTo _chanState) then {
            _chan enableChannel _destState;
        };
        nil
    } count _settings;

}, 1, []] call CBAP_fnc_addPerFrameHandler;