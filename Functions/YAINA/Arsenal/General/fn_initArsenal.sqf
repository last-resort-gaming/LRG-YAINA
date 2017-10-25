/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_arsenals"];

// Setup the arsenal on the given object
if (isServer) then {
    {
        ["AmmoboxInit", [_x, true]] call BIS_fnc_arsenal;

        // Remove all items
        clearWeaponCargoGlobal _x;
        clearMagazineCargoGlobal _x;
        clearItemCargoGlobal _x;
        clearBackpackCargoGlobal _x;

        // Ensure no rope attachments
        _x enableRopeAttach false;

        true
    } count _arsenals;
};

if (isDedicated) exitWith {};

///////////////////////////////////////////////////////////
// WEAPONS / Scopes / Attachments
///////////////////////////////////////////////////////////

GVAR(unitWeapons) = call {

    // By default we allow all arifiles + smgs + hguns
    _permitGroups     = ["arifle", "smg", "hgun"];
    _blacklistGroups  = [];
    _blacklistItems   = [];
    _permitItems      = [];

    // Remove any blacklist groups before adding specifics, and reset blacklistGroups
    _permitGroups    = _permitGroups - _blacklistGroups;
    _blacklistGroups = [];

    // If we are marksman/sniper we allow srifiles
    // If we are marksman/sniper we allow srifiles
    if (["Marksman", "Sniper"] call YFNC(testTraits)) then {

        if (["Marksman"] call YFNC(testTraits)) then {
            // Deny the Lynx and 403 main sniper weapons
            _blacklistItems append ["srifle_GM6_F", "srifle_LRR_F", "srifle_LRR_camo_F"];

        };
    };

    // If we are MGs then we allow MGs
    if (["MG"] call YFNC(testTraits)) then {
        _permitGroups pushBack "mg";
    };

    // And AT may have missiles / rockets
    if (["AT"] call YFNC(testTraits)) then {
        _permitGroups pushBack "missile";
        _permitGroups pushBack "rocket";
    };

    // ReRemove any additional blacklistGroups based on unit traits
    _permitGroups = _permitGroups - _blacklistGroups;

    // Merge the weapon list
    _retval = [];

    {
        _idx = (GVAR(allWeapons) select 0) find _x;
        if !(_idx isEqualTo -1) then { _retval append ((GVAR(allWeapons) select 1) select _idx); };
        true;
    } count _permitGroups;

    // Remove blacklisted items that aren't explicitly allowed, then add the rest of the allowed items
    _retval = _retval - (_blacklistItems - _permitItems) + _permitItems;

    _retval
};

///////////////////////////////////////////////////////////
// BackPacks
///////////////////////////////////////////////////////////

GVAR(unitBackpacks) = call {

    _maxSize = 320; // Carryall, excluding Bergen
    _minSize = 140; // Remove Messenger bags and

    _retval = [];
    {
        if (_x > _minSize && _x <= _maxSize) then {
            _retval append ((GVAR(carryPacks) select 1) select _forEachIndex);
        };
    } forEach (GVAR(carryPacks) select 0);

    // By default we allow parachutes, and BLUFOR static weapons
    _permit = ["basic", "B_StaticWeapon"];

    if (["UAV"] call YFNC(testTraits)) then {
        _permit pushBack "B_UAV";
    };

    if (["MERT_UAV"] call YFNC(testTraits)) then {
        _permit pushBackUnique "B_MedicalUAV";
    };

    {
        _idx = (GVAR(specialPacks) select 0) find _x;
        if !(_idx isEqualTo -1) then { _retval append ((GVAR(specialPacks) select 1) select _idx) };
        true;
    } count _permit;

    _retval
};

///////////////////////////////////////////////////////////
// Items
///////////////////////////////////////////////////////////

GVAR(unitItems) = call {

    // Standard Items
    _retval = ["Binocular", "RangeFinder", "Map", "GPS", "Radio", "Compass", "Watch", "FirstAidKit"];

    // Default allowed items for all classes
    _permitGroups     = ["H_HelmetB", "H_HelmetSpecB", "H_Beret",
                         "V_ALL", "G_ALL", "U_B",
                         "NVGoggles",
                         "silencers", "optic_ALL", "acc", "bipods"];

    _permitItems      = [];

    _blacklistGroups  = ["V_Rangemaster", "V_I_G_resistanceLeader","V_Press",
                         "V_DeckCrew", "V_Plain", "V_Safety", "V_EOD", "V_EOD_IDAP",
                         "V_PlateCarrier", "V_RebreatherIR", "V_RebreatherIA", "G_Respirator", "G_Lady", "G_EyeProtectors",
                         "optic_LRPS", "optic_AMS", "optic_SOS", "optic_KHS", "optic_DMS", "optic_tws", "optic_Nightstalker"];

    _blacklistItems   = ["H_Beret_gen_F", "H_Beret_Colonel",
                         "U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard", "U_B_T_FullGhillie_tna_F", "U_B_T_Sniper_F",
                         "U_B_GEN_Soldier_F", "U_B_GEN_Commander_F", "U_B_Protagonist_VR",
                         "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls",
                         "V_TacVest_gen_F",
                         "G_I_Diving", "G_O_Diving", "G_WirelessEarpiece_F", "G_Goggles_VR"];


    // if it's V_ALL add in all vests
    if ("V_ALL" in _permitGroups) then {
        _permitGroups append ((GVAR(items) select 0) select { (_x select [0,2]) isEqualTo "V_"; });
    };

    // G_ALL for glasses
    if ("G_ALL" in _permitGroups) then {
        _permitGroups append ((GVAR(items) select 0) select { (_x select [0,2]) isEqualTo "G_"; });
    };

    // expand optic all
    if ("optic_ALL" in _permitGroups) then {
        _permitGroups append ((GVAR(items) select 0) select { (_x select [0,6]) isEqualTo "optic_"; });
    };

    // Remove any blacklist groups before adding specifics
    _permitGroups = _permitGroups - _blacklistGroups;

    // Reset blacklist Gorups so we can add specific blacklists
    _blacklistGroups = [];

    // Add any specifics
    if(["PILOT"] call YFNC(testTraits)) then {
        _permitGroups append ["H_PilotHelmetHeli_B", "H_PilotHelmetFighter_B", "H_CrewHelmetHeli_B"];
        _permitItems append  ["U_B_PilotCoveralls", "U_B_HeliPilotCoveralls"];
    };

    // Squad Spotters/Snipers also get Laser Designators and NATO Ghillies
    if(["SNIPER", "SPOTTER"] call YFNC(testTraits)) then {
        _permitGroups append ["Laserdesignator", "U_B_FullGhillie"];
        _permitItems  append ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard"];
    };

    if(["SNIPER", "MARKSMAN"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_AMS", "optic_SOS", "optic_DMS", "optic_KHS"];
    };

    if(["SNIPER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_LRPS", "optic_Nightstalker"];
    };

    if(["SL"] call YFNC(testTraits)) then {
        _permitGroups append ["Laserdesignator"];
    };

    if(["HQ"] call YFNC(testTraits)) then {
        _permitItems append ["H_Beret_Colonel"];
    };

    if(["UAV", "MERT_UAV"] call YFNC(testTraits)) then {
        _permitItems append ["B_UavTerminal"];
    };

    if(["MEDIC"] call YFNC(testTraits)) then {
        _permitItems append ["Medikit"];
    };

    if(["ENG"] call YFNC(testTraits)) then {
        _permitItems append ["Toolkit", "MineDetector"];
    };


    {
        _idx = (GVAR(items) select 0) find _x;
        if !(_idx isEqualTo -1) then { _retval append ((GVAR(items) select 1) select _idx) };
        true;
    } count _permitGroups;

    // Remove blacklisted items that aren't explicitly allowed, then add the rest of the allowed items
    _retval = _retval - (_blacklistItems - _permitItems) + _permitItems;

    _retval;
};


///////////////////////////////////////////////////////////
// Populate
///////////////////////////////////////////////////////////

{
    // Remove all items, to add what we want
    [_x, [true], false] call BIS_fnc_removeVirtualItemCargo;
    [_x, [true], false] call BIS_fnc_removeVirtualWeaponCargo;
    [_x, [true], false] call BIS_fnc_removeVirtualBackpackCargo;
    // [_obj, [true], false] call BIS_fnc_removeVirtualMagazineCargo;

    [_x, GVAR(unitItems),     false] call BIS_fnc_addVirtualItemCargo;
    [_x, GVAR(unitWeapons),   false] call BIS_fnc_addVirtualWeaponCargo;
    [_x, GVAR(unitBackpacks), false] call BIS_fnc_addVirtualBackpackCargo;

    // Fix the action
     _x removeAction (_x getVariable "bis_fnc_arsenal_action");
    _action = _x addaction [
        localize "STR_A3_Arsenal",
        {
            params ["_box", "_unit"];
            ["Open", [nil, _box, _unit]] call bis_fnc_arsenal;

            [_unit] spawn {
                params ["_unit"];

                uiSleep 2;
                (uinamespace getvariable "bis_fnc_arsenal_display") displayAddEventHandler ["Unload", {
                    [player] call FNC(enforceGear);
                }];
            };

        },
        [],
        6,
        true,
        false,
        "",
        "
        _cargo = _target getvariable ['bis_addVirtualWeaponCargo_cargo',[[],[],[],[]]];
        if ({count _x > 0} count _cargo == 0) then {
            _target removeaction (_target getvariable ['bis_fnc_arsenal_action',-1]);
            _target setvariable ['bis_fnc_arsenal_action',nil];
        };
        _condition = _target getvariable ['bis_fnc_arsenal_condition',{true}];
        alive _target && {_target distance _this < 5} && {call _condition}
        "
    ];
    _x setvariable ["bis_fnc_arsenal_action", _action];

    true
} count _arsenals;

true;