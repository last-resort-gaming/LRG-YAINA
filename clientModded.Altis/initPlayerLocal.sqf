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

        [player, "Welcome to Last Resort Gaming", 50, 80, 140, 1] call BIS_fnc_establishingShot;

        5 fadeMusic 0;
        [] execVM "scripts\lrg\intro_msg.sqf";

        // let server know we're completed our preload
        [player] remoteExecCall ["YAINA_fnc_playerIntroComplete", 2];
    };
}];

