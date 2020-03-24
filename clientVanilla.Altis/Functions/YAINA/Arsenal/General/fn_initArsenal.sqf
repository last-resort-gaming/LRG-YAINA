/*
Function: YAINA_ARSENAL_fnc_initArsenal

Description:
	Inititalizes the given list of containers with the (restricted) arsenal.

Parameters:
	_arsenals - Array containing all the boxes which shall be initialized with the arsenal [Array]

Return Values:
	true - if successfully initialized the arsenals

Examples:
    Nothing to see here

Author:
	Martin
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

        // And set it as a filtered box
        _x setVariable [QVAR(filtered), true, true];

        true
    } count _arsenals;
};

if (isDedicated) exitWith {};

private _hasACE  = isClass(configFile >> "CfgPatches" >> "ace_main");
private _hasTFAR = isClass(configFile >> "CfgPatches" >> "task_force_radio");

///////////////////////////////////////////////////////////
// Weapons
// Groups:
//      MineDetector, Binocular, Rangefinder, Laserdesignator,
//      rocket, missile srifle, mg, hgun, arifle, arifle_gl, smg
///////////////////////////////////////////////////////////

GVAR(unitWeapons) = call {

    _permitGroups    = ["Binocular","Rangefinder", "arifle", "hgun", "smg"];
    _permitItems     = [];
    _blacklistItems  = [
        "arifle_ARX_blk_F", "arifle_ARX_ghex_F", "arifle_ARX_hex_F" // Type 115
    ];

    if (["AT"] call YFNC(testTraits)) then {
        _permitGroups append ["missile", "rocket"];
    };

    if (["AR", "HG"] call YFNC(testTraits)) then {
        _permitGroups pushBack "mg";
    };

    if (["SL"] call YFNC(testTraits)) then {
        _permitGroups append ["Laserdesignator", "arifle_gl"];
    };

    if (["MEDIC"] call YFNC(testTraits)) then {
       _permitItems append ["srifle_DMR_06_olive_F", "srifle_DMR_06_camo_F"];
    };

    if (["Marksman", "Sniper", "SPOTTER"] call YFNC(testTraits)) then {

        _permitGroups append ["Laserdesignator", "srifle"];

        if (["Marksman", "SPOTTER"] call YFNC(testTraits)) then {
            // Deny the Lynx and 403 main sniper weapons
            _blacklistItems append ["srifle_GM6_F", "srifle_GM6_camo_F", "srifle_GM6_ghex_F", "srifle_LRR_F", "srifle_LRR_camo_F", "srifle_LRR_tna_F"];
        };
    };

    _retval = [];
    {
        _idx = (GVAR(weaponCargo) select 0) find _x;
        if !(_idx isEqualTo -1) then { _retval append ((GVAR(weaponCargo) select 1) select _idx); };
        true;
    } count _permitGroups;

    // Bring in the permitItems
    { _retval pushBackUnique _x; nil } count _permitItems;

    _retval - _blacklistItems - GVAR(globalBlacklist);
};

///////////////////////////////////////////////////////////
// Items
// Groups:
//  General Items:
//      ItemWatch ItemCompass ItemGPS ItemRadio ItemMap FirstAidKit
//  Class Items:
//      MediKit ToolKit UAVTerm
//  Uniform Groups:
//      U_B U_O U_C U_Rangemaster U_OrestesBody U_I U_Competitor U_BG U_Marshal
//  Vest Groups:
//      V_Rangemaster, V_BandollierB, V_PlateCarrier1, V_PlateCarrier2, V_PlateCarrierGL,
//      V_PlateCarrierSpec, V_Chestrig, V_TacVest, V_TacVestIR, V_HarnessO, V_HarnessOGL,
//      V_PlateCarrierIA1, V_PlateCarrierIA2, V_PlateCarrierIAGL, V_RebreatherB,
//      V_RebreatherIR, V_RebreatherIA, V_PlateCarrier, V_PlateCarrierL, V_PlateCarrierH,
//      V_I_G_resistanceLeader_F, V_Press, V_TacChestrig, V_DeckCrew, V_Plain, V_Pocketed,
//      V_Safety, V_LegStrapBag, V_EOD, V_EOD_IDAP_blue_F
//  Helmet Groups:
//      H_HelmetB, H_Booniehat, H_HelmetSpecB, H_HelmetIA, H_Cap, H_HelmetCrew_B,
//      H_HelmetCrew_O, H_HelmetCrew_I, H_PilotHelmetFighter_B, H_PilotHelmetFighter_O,
//      H_PilotHelmetFighter_I, H_PilotHelmetHeli_B, H_PilotHelmetHeli_O, H_PilotHelmetHeli_I,
//      H_CrewHelmetHeli_B, H_CrewHelmetHeli_O, H_CrewHelmetHeli_I, H_HelmetO, H_HelmetLeaderO
//      H_MilCap, H_HelmetSpecO, H_Bandanna, H_Shemag, H_ShemagOpen, H_Beret, H_Watchcap,
//      H_StrawHat, H_Hat, H_RacingHelmet ,H_Helmet, H_HelmetCrew, H_Construction,
//      H_EarProtectors, H_HeadSet, H_PASGT, H_HeadBandage, H_WirelessEarpiece
//  Weapon Accessories Groups:
//      acc_muzzle, acc_pointer, acc_bipod
//      optic_Arco, optic_Hamr, optic_Aco, optic_ACO, optic_Holosight, optic_SOS
//      optic_MRCO, optic_NVS, optic_Nightstalker, optic_tws, optic_DMS,
//      optic_Yorris, optic_MRD, optic_LRPS, optic_AMS, optic_KHS, optic_ERCO, optic_PGO7
//  NVG Groups:
//      NVGoggles O_NVGoggles, NVGogglesB
//  Glasses Groups:
//      G_Spectacles, G_Combat, G_Lowprofile, G_Shades, G_Squares, G_Sport, G_Tactical,
//      G_Aviator, G_Lady, G_Diving, G_B_Diving, G_O_Diving, G_I_Diving, G_Goggles,
//      G_Balaclava, G_Bandanna, G_Respirator, G_EyeProtectors, G_WirelessEarpiece

///////////////////////////////////////////////////////////


GVAR(unitItems) = call {

    // Default Permitted Items
    _permitGroups    = ["ItemWatch", "ItemCompass", "ItemGPS", "ItemRadio", "ItemMap",
                        "FirstAidKit", "NVGoggles", "acc_muzzle", "acc_pointer", "acc_bipod",
                        "H_HelmetB", "H_HelmetSpecB", "H_Shemag", "H_Booniehat", "H_ShemagOpen", "V_ALL", "G_ALL", "U_B",
                        "optic_ALL"];

    _permitItems     = ["U_I_G_Story_Protagonist_F", "H_Cap_khaki_specops_UK", "H_Cap_tan_specops_US", "H_Cap_usblack"];

    // These items are included by the permit groups, but by default aren't permitted by everyone and will be added
    // where required, faster than either whitelisting, or blacklisting only

    _blacklistGroups  = ["V_Rangemaster", "V_I_G_resistanceLeader","V_Press",
                         "V_DeckCrew", "V_Plain", "V_Safety", "V_EOD", "V_EOD_IDAP",
                         "V_PlateCarrier", "V_RebreatherIR", "V_RebreatherIA", "G_Respirator", "G_Lady", "G_EyeProtectors",
                         "optic_LRPS", "optic_AMS", "optic_SOS", "optic_KHS", "optic_DMS", "optic_tws", "optic_Nightstalker"];

    _blacklistItems   = ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard", "U_B_T_FullGhillie_tna_F", "U_B_T_Sniper_F",
                         "U_B_GEN_Soldier_F", "U_B_GEN_Commander_F", "U_B_Protagonist_VR",
                         "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls",
                         "V_TacVest_gen_F",
                         "G_I_Diving", "G_O_Diving", "G_WirelessEarpiece_F", "G_Goggles_VR"];

    // working list
    _items            = [];

    // handle "prefix_ALL"
    {
        _id     = format["%1_ALL", _x];
        _prefix = format ["%1_", _x];
        _len = count _prefix;
        if (_id in _permitGroups) then {
            _permitGroups append ((GVAR(itemCargo) select 0) select { (_x select [0,_len]) isEqualTo _prefix; });
        };
    } count ["G", "V", "H", "optic"];

    // Build the initial valid items list, as we'll need to process the permitGroups/Items and don't want a blacklist
    // above coming in to ruin it all
    {
        _idx = (GVAR(itemCargo) select 0) find _x;
        if !(_idx isEqualTo -1) then { _items append ((GVAR(itemCargo) select 1) select _idx); };
        true;
    } count _permitGroups;

    _items append _permitItems;

    {
        _idx = ((GVAR(itemCargo) select 0) find _x);
        if !(_idx isEqualTo -1) then {
            {
                _idx = (_items find _x);
                if !(_idx isEqualTo -1) then {
                    _items deleteAt _idx;
                };
                true;
            } count (GVAR(itemCargo) select 1 select _idx);
        };
        true
    } count _blacklistGroups;

    _items = _items - _blacklistItems;

    // Now we reset the blacklist/permit lists per-class
    _permitGroups    = [];
    _permitItems     = [];
    _blacklistGroups = [];
    _blacklistItems  = [];

    if(["PILOT", "MERT_PILOT"] call YFNC(testTraits)) then {
        _permitItems append  ["H_PilotHelmetHeli_B", "H_PilotHelmetHeli_O",
                              "H_PilotHelmetFighter_B", "H_PilotHelmetFighter_O",
                              "H_CrewHelmetHeli_B", "H_CrewHelmetHeli_O",
                              "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls"];
    };

    // MERT have heli helmets
    if(["MERT"] call YFNC(testTraits)) then {
        _permitItems append ["H_CrewHelmetHeli_B", "H_CrewHelmetHeli_O"];
    };

    // Squad Spotters/Snipers also get NATO Ghillies
    if(["SNIPER", "SPOTTER"] call YFNC(testTraits)) then {
        _permitItems append ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard"];
    };

    if(["SNIPER", "MARKSMAN", "SPOTTER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_AMS", "optic_SOS", "optic_DMS", "optic_KHS"];
    };

    if(["SNIPER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_LRPS", "optic_Nightstalker"];
    };

    if(["HQ"] call YFNC(testTraits)) then {
        _permitItems append ["H_Beret_02", "H_Beret_Colonel"];
    };

    if(["UAV", "MERT_UAV"] call YFNC(testTraits)) then {
        _permitItems append ["B_UavTerminal"];
    };

    if(["MEDIC"] call YFNC(testTraits)) then {
        _permitItems pushBack "Medikit";
    };

    if(["ENG"] call YFNC(testTraits)) then {
        _permitItems append ["ToolKit", "MineDetector"];
    };

    if (_hasTFAR) then {
        _permitItems append ["tf_microdagr", "tf_anprc152"];
    };

    if (_hasACE) then {
        _permitItems append ["ACE_NVG_Gen4", "ACE_NVG_Wide"];
    };

    // Now, add in our permits, and remove blacklists again
    {
        _idx = (GVAR(itemCargo) select 0) find _x;
        if !(_idx isEqualTo -1) then { _items append ((GVAR(itemCargo) select 1) select _idx); };
        true;
    } count _permitGroups;

    _items append _permitItems;

    {
        _idx = ((GVAR(itemCargo) select 0) find _x);
        if !(_idx isEqualTo -1) then {
            {
                _idx = (_items find _x);
                if !(_idx isEqualTo -1) then {
                    _items deleteAt _idx;
                };
                true;
            } count (GVAR(itemCargo) select 1 select _idx);
        };
        true
    } count _blacklistGroups;

    _items = _items - _blacklistItems;

    // DeDupe and return the list
    _retval = [];
    { _retval pushBackUnique _x; true } count _items;

    _retval - GVAR(globalBlacklist);
};

///////////////////////////////////////////////////////////
// Backpacks
///////////////////////////////////////////////////////////
//
// Groups: "B_AssaultPack","B_Kitbag","B_TacticalPack","B_FieldPack",
//         "B_Carryall","B_Parachute","B_Static","O_Static","I_Static",
//         "B_UAV","O_UAV","I_UAV","B_Bergen","B_ViperHarness",
//         "B_ViperLightHarness","B_Messenger","C_UAV",
//         "B_MedicalUAV","O_MedicalUAV","I_MedicalUAV"
//         "C_MedicalUAV","B_LegStrapBag"


GVAR(unitBackpacks) = call {

    _permitGroups = ["B_Parachute", "B_AssaultPack","B_Kitbag","B_TacticalPack","B_FieldPack",
                     "B_Carryall", "B_ViperHarness", "B_ViperLightHarness", "B_LegStrapBag", "B_Static"];

    _permitItems  = ["B_UAV_01_backpack_F"];

    if (["MERT_UAV"] call YFNC(testTraits)) then {
        _permitGroups pushBackUnique "B_MedicalUAV";
    };

    if (_hasTFAR) then {
        if (["HQ", "SL"] call YFNC(testTraits)) then {
             _permitGroups pushBack "tf_rt1523g";
        };
    };

    {
        _idx = (GVAR(carryPacks) select 0) find _x;
        if !(_idx isEqualTo -1) then { _permitItems append ((GVAR(carryPacks) select 1) select _idx) };
        true;
    } count _permitGroups;


    // DeDupe and return the list
    _retval = [];
    { _retval pushBackUnique _x; true } count _permitItems;
    _retval - GVAR(globalBlacklist);
};

///////////////////////////////////////////////////////////
// Mags
// Groups:
//      Bullet, Rocket, Missile, Shell, SmokeShell, Grenade,
//      Flare, Laserbatteries, B_IR_Grenade, O_IR_Grenade,
//      I_IR_Grenade, Mine, MineLocal, MineBounding,
//      MineDirectional, Artillery, Mags_ALL
///////////////////////////////////////////////////////////

GVAR(unitMags) = call {

    // By defeault, we allow except mines
    _permitGroups    = (GVAR(magazineCargo) select 0);
    _blacklistGroups = ["Mine"];

    // And we don't want Red Flares, UGLs
    _blacklistItems  = ["6Rnd_RedSignal_F"];

    _items           = [];

    {
        _idx = (GVAR(magazineCargo) select 0) find _x;
        if !(_idx isEqualTo -1) then {
            { _items pushBackUnique _x; true; } count ((GVAR(magazineCargo) select 1) select _idx);
        };
        true;
    } count _permitGroups;

    {
        _idx = ((GVAR(magazineCargo) select 0) find _x);
        if !(_idx isEqualTo -1) then {
            {
                _idx = (_items find _x);
                if !(_idx isEqualTo -1) then {
                    _items deleteAt _idx;
                };
                true;
            } count (GVAR(magazineCargo) select 1 select _idx);
        };
        true
    } count _blacklistGroups;

    if (["ENG"] call YFNC(testTraits)) then {
        _items append [ "ATMine_Range_Mag", "APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag",
                        "SLAMDirectionalMine_Wire_Mag", "APERSTripMine_Wire_Mag",
                        "ClaymoreDirectionalMine_Remote_Mag", "SatchelCharge_Remote_Mag",
                        "DemoCharge_Remote_Mag" ];
    };

    _items - _blacklistItems - GVAR(globalBlacklist)
};

///////////////////////////////////////////////////////////
// Populate
///////////////////////////////////////////////////////////

{
    // Remove all items, to add what we want
    [_x, [true], false] call BIS_fnc_removeVirtualItemCargo;
    [_x, [true], false] call BIS_fnc_removeVirtualWeaponCargo;
    [_x, [true], false] call BIS_fnc_removeVirtualBackpackCargo;
    [_x, [true], false] call BIS_fnc_removeVirtualMagazineCargo;

    //[_x, ("getNumber (_x >> 'scope') >= 2" configClasses (configFile >> "CfgWeapons") apply { configName _x }), false] call BIS_fnc_addVirtualItemCargo;
    [_x, GVAR(unitItems), false] call BIS_fnc_addVirtualItemCargo;
    [_x, GVAR(unitWeapons), false] call BIS_fnc_addVirtualWeaponCargo;
    [_x, GVAR(unitBackpacks), false] call BIS_fnc_addVirtualBackpackCargo;
    [_x, GVAR(unitMags), false] call BIS_fnc_addVirtualMagazineCargo;

    // Fix the action
     _x removeAction (_x getVariable "bis_fnc_arsenal_action");
    _action = _x addaction [
        localize "STR_A3_Arsenal",
        {
            params ["_box", "_unit"];
            ["Open", [nil, _box, _unit]] call bis_fnc_arsenal;

            [_unit] spawn {
                params ["_unit"];
                waitUntil { isNull ( uiNamespace getVariable [ "BIS_fnc_arsenal_cam", objNull ] )  };
                [player] call FNC(enforceGear);
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
