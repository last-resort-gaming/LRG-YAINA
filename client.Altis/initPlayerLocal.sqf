/*
	author: MartinCo
	description: none
	returns: nothing
*/

if (!hasInterface) exitWith {};
if (side player isEqualTo sidelogic) exitWith {
    1 enableChannel true;
};

["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

// QS Icons
[] execVM "scripts\QS\QS_icons.sqf";

// Repack
[] execVM "scripts\outlawled\magRepack\MagRepack_init_sv.sqf";

// Comms, von/chat on global, disable von on side except HQ
0 enableChannel [false, false];
1 enableChannel [true, "HQ" call YAINA_fnc_testTraits];

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

        [intro_base, "Welcome to Last Resort Gaming", 10, 80, 140, 1] call BIS_fnc_establishingShot;

        sleep 10;
        5 fadeMusic 0;

        [] execVM "scripts\lrg\intro_msg.sqf";
    };
}];

