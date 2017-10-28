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

        // And set it as a filtered box
        _x setVariable [QVAR(filtered), true, true];

        true
    } count _arsenals;
};

if (isDedicated) exitWith {};

///////////////////////////////////////////////////////////
// Weapons
// Groups:
//      MineDetector, Binocular, Rangefinder, Laserdesignator,
//      rocket, missile srifle, mg, hgun, arifle, arifle_gl, smg
///////////////////////////////////////////////////////////

GVAR(unitWeapons) = call {

    _permitGroups    = ["Binocular","Rangefinder", "arifle", "hgun", "smg"];
    _blacklistItems  = [];

    if (["AT"] call YFNC(testTraits)) then {
        _permitGroups append ["missile", "rocket"];
    };

    if (["AR", "HG"] call YFNC(testTraits)) then {
        _permitGroups pushBack "mg";
    };

    if(["ENG"] call YFNC(testTraits)) then {
        _permitGroups pushBack "MineDetector";
    };

    if (["SL"] call YFNC(testTraits)) then {
        _permitGroups pushBack "Laserdesignator";
    };

    if (["Marksman", "Sniper"] call YFNC(testTraits)) then {

        _permitGroups append ["Laserdesignator", "srifle"];

        if (["Marksman"] call YFNC(testTraits)) then {
            // Deny the Lynx and 403 main sniper weapons
            _blacklistItems append ["srifle_GM6_F", "srifle_LRR_F", "srifle_LRR_camo_F"];
        };
    };

    _retval = [];
    {
        _idx = (GVAR(weaponCargo) select 0) find _x;
        if !(_idx isEqualTo -1) then { _retval append ((GVAR(weaponCargo) select 1) select _idx); };
        true;
    } count _permitGroups;

    _retval - _blacklistItems;
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
                        "H_HelmetB", "H_HelmetSpecB", "H_Beret", "V_ALL", "G_ALL", "U_B",
                        "optic_ALL"];

    _permitItems     = [];

    // These items are included by the permit groups, but by default aren't permitted by everyone and will be added
    // where required, faster than either whitelisting, or blacklisting only

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

    if(["PILOT"] call YFNC(testTraits)) then {
        _permitItems append  ["H_PilotHelmetHeli_B", "H_PilotHelmetFighter_B", "H_CrewHelmetHeli_B", "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls"];
    };

    // Squad Spotters/Snipers also get NATO Ghillies
    if(["SNIPER", "SPOTTER"] call YFNC(testTraits)) then {
        _permitItems append ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard"];
    };

    if(["SNIPER", "MARKSMAN"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_AMS", "optic_SOS", "optic_DMS", "optic_KHS"];
    };

    if(["SNIPER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_LRPS", "optic_Nightstalker"];
    };

    if(["HQ"] call YFNC(testTraits)) then {
        _permitItems append ["H_Beret_Colonel"];
    };

    if(["UAV", "MERT_UAV"] call YFNC(testTraits)) then {
        _permitItems append ["B_UavTerminal"];
    };

    if(["MEDIC"] call YFNC(testTraits)) then {
        _permitItems pushBack "Medikit";
    };

    if(["ENG"] call YFNC(testTraits)) then {
        _permitItems pushBack "ToolKit";
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
    { if ((_retval find _x) isEqualTo -1) then { _retval pushBack _x; }; true } count _items;
    _retval;
};

///////////////////////////////////////////////////////////
// Backpacks
///////////////////////////////////////////////////////////

GVAR(unitBackpacks) = call {

    _maxSize = 320; // Carryall, excluding Bergen
    _minSize = 140; // Remove Messenger bags and msuh

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
// Mags
// Groups:
//      Bullet, Rocket, Missile, Shell, SmokeShell, Grenade,
//      Flare, Laserbatteries, B_IR_Grenade, O_IR_Grenade,
//      I_IR_Grenade, Mine, MineLocal, MineBounding,
//      MineDirectional, Artillery, Mags_ALL
///////////////////////////////////////////////////////////

GVAR(unitMags) = call {

    // By defeault, we allow everything except arty (which is really starter pistol flares) and mines
    _permitGroups    = (GVAR(magazineCargo) select 0);
    _blacklistGroups = ["Artillery", "Mine"];

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

    _items;
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