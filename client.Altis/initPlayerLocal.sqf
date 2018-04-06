/*
	author: MartinCo
	description: none
	returns: nothing
*/

if (!hasInterface) exitWith {};

////////////////////////////////////////////////////////////////////////////
// RADIO MANAGEMENT
////////////////////////////////////////////////////////////////////////////

// Zeus is a little special, so we just exit here with initialize dynamic
// groups and allow the zeusConnected handler to sort out the rest
if (typeOf player isEqualTo "VirtualCurator_F") exitWith {
    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

    // let server know we're completed our preload
    [player] remoteExecCall ["YAINA_fnc_playerIntroComplete", 2];
};

// When we have TFAR enabled, we only allow admins on side + direct chat
// and disable the others
if (isClass(configFile >> "CfgPatches" >> "task_force_radio")) then {

    2 enableChannel false; // Command
    3 enableChannel [true, false]; // Group
    4 enableChannel false; // Vehicle

    [
        { !(isNil { "YAINA_GLOBAL_TRAITS" }) },
        { 1 enableChannel (['HQ', 'side-channel-talk'] call YAINA_fnc_testTraits) },
        []
    ] call CBAP_fnc_waitUntilAndExecute;

} else {

    // Always enable group/vehicle
    3 enableChannel true;
    4 enableChannel true;

    // Main Channel Management
    [{
        _settings = [];

        // Command Channel Management
        _settings pushBack [1, ["HQ", "side-channel-talk"] call YAINA_fnc_testTraits, true];
        _settings pushBack [2, leader (group player) isEqualTo player];

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
};

////////////////////////////////////////////////////////////////////////////
// DISABLE NEGATIVE RATINGS
////////////////////////////////////////////////////////////////////////////
player addEventHandler ["HandleRating", {
    (_this select 1) max 0
}];

////////////////////////////////////////////////////////////////////////////
// GENERAL GROUPS / ADDONS
////////////////////////////////////////////////////////////////////////////

["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

// QS Icons
[] execVM "scripts\QS\QS_icons.sqf";

// Repack
[] execVM "scripts\outlawled\magRepack\MagRepack_init_sv.sqf";


////////////////////////////////////////////////////////////////////////////
// GROUPS
////////////////////////////////////////////////////////////////////////////

// Intro Music / Shot
INTRO_HANDLE =  addMissionEventHandler ["PreloadFinished", {

    removeMissionEventHandler ["PreloadFinished", INTRO_HANDLE];

    [] spawn {
        playMusic [selectRandom [
            "LeadTrack03_F_Tacops",
            "LeadTrack01_F",
            "LeadTrack01a_F",
            "LeadTrack01b_F",
            "LeadTrack01_F_EPA",
            "LeadTrack01_F_EPB",
            "LeadTrack03_F_EPB",
            "LeadTrack02_F_EPC",
            "LeadTrack04_F_EPC",
            "Defcon",
            "LeadTrack02_F_Bootcamp",
            "LeadTrack01_F_Mark",
            "LeadTrack02_F_Mark",
            "AmbientTrack02b_F_EXP",
            "AmbientTrack02c_F_EXP",
            "EventTrack01_F_Jets",
            "LeadTrack01_F_Malden",
            "LeadTrack01_F_Tacops",
            "LeadTrack02_F_Tacops",
            "LeadTrack03_F_Tacops",
            "LeadTrack04_F_Tacops",
            "EventTrack01a_F_Tacops",
            "EventTrack02a_F_Tacops",
            "EventTrack02b_F_Tacops",
            "EventTrack03a_F_Tacops"
        ], -5];

        [[9175.96,21684,2.13609], "Welcome to Last Resort Gaming", 10, 80, 140, 1] call BIS_fnc_establishingShot;

        5 fadeMusic 0;

        // We have to re-apply earplugs here as establishingShot sets sound to 1
        [] execVM "scripts\YAINA\earplugs.sqf";
        [] execVM "scripts\lrg\intro_msg.sqf";

        // let server know we're completed our preload
        [player] remoteExecCall ["YAINA_fnc_playerIntroComplete", 2];
    };
}];

