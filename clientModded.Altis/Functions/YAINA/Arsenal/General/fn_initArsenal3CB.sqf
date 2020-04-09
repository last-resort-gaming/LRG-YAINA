/*
Function: YAINA_ARSENAL_fnc_initArsenal3CB

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
	Matth
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
// Items:
//		Ace sniping stuff
///////////////////////////////////////////////////////////

GVAR(unitWeapons) = call {

    _permitGroups    = ["Binocular","Rangefinder", "arifle", "hgun", "smg","ACE_VMH3","ACE_VMM3","UK3CB_BAF_M6","UK3CB_BAF_Javelin_Slung_Tube",
						 "UK3CB_BAF_NLAW_Launcher","UK3CB_BAF_AT4_CS_AT_Launcher","UK3CB_BAF_Javelin_CLU"];
    _permitItems     = ["ACE_Vector", "ACE_VectorDay", "ACE_Yardage450", "ACE_MX2A", "ACE_Kestrel4500",
						"Binocular",		
						"UK3CB_BAF_L1A1",
						"UK3CB_BAF_L1A1_Wood",
						"UK3CB_BAF_L119A1",
						"UK3CB_BAF_L119A1_CQB",
						"UK3CB_BAF_L119A1_FG",
						"UK3CB_BAF_L22",
						"UK3CB_BAF_L22A2",
						"UK3CB_BAF_L85A2",
						"UK3CB_BAF_L85A2_RIS",
						"UK3CB_BAF_L85A2_RIS_Tan",
						"UK3CB_BAF_L85A2_RIS_Green",
						"UK3CB_BAF_L85A2_EMAG",
						"UK3CB_BAF_L85A2_RIS_AFG",
						"UK3CB_BAF_L85A2_RIS_AFG_Tan",
						"UK3CB_BAF_L85A2_RIS_AFG_Green",
						"UK3CB_BAF_L86A2",
						"UK3CB_BAF_L86A3",
						"UK3CB_BAF_L91A1",
						"UK3CB_BAF_L92A1",
						"UK3CB_BAF_L103A2",
						"UK3CB_BAF_L128A1",
						"UK3CB_BAF_L129A1",
						"UK3CB_BAF_L129A1_Grippod",
						"UK3CB_BAF_L129A1_AFG",
						"UK3CB_BAF_L129A1_FGrip",
						"UK3CB_BAF_L131A1",
						"UK3CB_BAF_L82A1",
						"UK3CB_BAF_AT4_Launcher_Used",
						"UK3CB_BAF_AT4_CS_Launcher_Used",
						"UK3CB_BAF_NLAW_Launcher_Used",
						"UK3CB_BAF_Tripod",
						"UK3CB_BAF_L16_Tripod",
						"UK3CB_BAF_L111A1",
						"UK3CB_BAF_L134A1",
						"UK3CB_BAF_L16",
						"UK3CB_BAF_M6",
						"UK3CB_BAF_Soflam_Laserdesignator",
						"ACE_VMH3",
						"ACE_VMM3",
						"ACE_VectorDay",
						"ACE_Vector",
						"ACE_Yardage450",
						"UK3CB_BAF_AT4_CS_AT_Launcher",
						"UK3CB_BAF_AT4_CS_AP_Launcher"];
						
    _blacklistItems  = ["arifle_ARX_blk_F", "arifle_ARX_ghex_F", "arifle_ARX_hex_F"
    ];

    if (["AT"] call YFNC(testTraits)) then {
        _permitGroups append ["missile", "rocket"];
		_permitItems append ["UK3CB_BAF_Javelin_Slung_Tube",
						"UK3CB_BAF_Javelin_CLU",
						"UK3CB_BAF_NLAW_Launcher"];
    };

    if (["AR", "HG"] call YFNC(testTraits)) then {
        _permitGroups pushBack "mg";
		_permitItems pushBack ["UK3CB_BAF_L110A1",
						"UK3CB_BAF_L110A2",
						"UK3CB_BAF_L110A2RIS",
						"UK3CB_BAF_L110A3",
						"UK3CB_BAF_L110_762",
						"UK3CB_BAF_L110A2_FIST",
						"UK3CB_BAF_L7A2",
						"UK3CB_BAF_L7A2_FIST"];
    };

    if (["SL"] call YFNC(testTraits)) then {
        _permitGroups append ["Laserdesignator", "arifle_gl"];
    };

    if (["SPOTTER"] call YFNC(testTraits)) then {
        _permitGroups pushBack "Laserdesignator";
    };

    if (["MEDIC"] call YFNC(testTraits)) then {
       _permitItems append ["srifle_DMR_06_olive_F", "srifle_DMR_06_camo_F"];
    };

    if (["Marksman", "Sniper"] call YFNC(testTraits)) then {

        _permitGroups append ["Laserdesignator", "srifle"];

        if (["Marksman"] call YFNC(testTraits)) then {
            // Deny the Lynx and 403 main sniper weapons
            _blacklistItems append ["srifle_GM6_F", "srifle_GM6_camo_F", "srifle_GM6_ghex_F", "srifle_LRR_F", "srifle_LRR_camo_F", "srifle_LRR_tna_F"];
        } else {
			_permitItems pushBack ["UK3CB_BAF_L115A3",
						"UK3CB_BAF_L115A3_BL",
						"UK3CB_BAF_L115A3_DE",
						"UK3CB_BAF_L115A3_Ghillie",
						"UK3CB_BAF_L115A3_DE_Ghillie",
						"UK3CB_BAF_L115A3_BL_Ghillie",
						"UK3CB_BAF_L118A1_Covert",
						"UK3CB_BAF_L118A1_Covert_BL",
						"UK3CB_BAF_L118A1_Covert_DE",
						"UK3CB_BAF_L135A1"];
		};
    };
	
    if (_hasACE) then {
        if (["ENG"] call YFNC(testTraits)) then {
            _permitItems append ["ACE_VMH3", "ACE_VMM3"];
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

    _permitItems     = ["U_I_G_Story_Protagonist_F", "H_Cap_khaki_specops_UK", "H_Cap_tan_specops_US", "H_Cap_usblack","ItemWatch","tf_anprc152","tf_microdagr","UK3CB_BAF_HMNVS",
						"UK3CB_BAF_H_Mk7_Camo_A",
						"UK3CB_BAF_H_Mk7_Camo_B",
						"UK3CB_BAF_H_Mk7_Camo_C",
						"UK3CB_BAF_H_Mk7_Camo_D",
						"UK3CB_BAF_H_Mk7_Camo_E",
						"UK3CB_BAF_H_Mk7_Camo_F",
						"UK3CB_BAF_H_Mk7_Camo_ESS_A",
						"UK3CB_BAF_H_Mk7_Camo_ESS_B",
						"UK3CB_BAF_H_Mk7_Camo_ESS_C",
						"UK3CB_BAF_H_Mk7_Camo_ESS_D",
						"UK3CB_BAF_H_Mk7_Camo_CESS_A",
						"UK3CB_BAF_H_Mk7_Camo_CESS_B",
						"UK3CB_BAF_H_Mk7_Camo_CESS_C",
						"UK3CB_BAF_H_Mk7_Camo_CESS_D",
						"UK3CB_BAF_H_Mk7_Net_A",
						"UK3CB_BAF_H_Mk7_Net_B",
						"UK3CB_BAF_H_Mk7_Net_C",
						"UK3CB_BAF_H_Mk7_Net_D",
						"UK3CB_BAF_H_Mk7_Net_ESS_A",
						"UK3CB_BAF_H_Mk7_Net_ESS_B",
						"UK3CB_BAF_H_Mk7_Net_ESS_C",
						"UK3CB_BAF_H_Mk7_Net_ESS_D",
						"UK3CB_BAF_H_Mk7_Net_CESS_A",
						"UK3CB_BAF_H_Mk7_Net_CESS_B",
						"UK3CB_BAF_H_Mk7_Net_CESS_C",
						"UK3CB_BAF_H_Mk7_Net_CESS_D",
						"UK3CB_BAF_H_Mk7_Scrim_A",
						"UK3CB_BAF_H_Mk7_Scrim_B",
						"UK3CB_BAF_H_Mk7_Scrim_C",
						"UK3CB_BAF_H_Mk7_Scrim_D",
						"UK3CB_BAF_H_Mk7_Scrim_E",
						"UK3CB_BAF_H_Mk7_Scrim_F",
						"UK3CB_BAF_H_Mk7_Scrim_ESS_A",
						"UK3CB_BAF_H_Mk7_Scrim_ESS_B",
						"UK3CB_BAF_H_Mk7_Scrim_ESS_C",
						"UK3CB_BAF_H_PilotHelmetHeli_A",
						"UK3CB_BAF_H_Mk7_Win_A",
						"UK3CB_BAF_H_Mk7_Win_ESS_A",
						"G_Combat",
						"G_Lowprofile",
						"G_Tactical_Black",
						"G_Tactical_Clear",
						"G_Aviator",
						"G_Spectacles",
						"G_Spectacles_Tinted",
						"G_Squares",
						"G_Squares_Tinted",
						"G_Shades_Black",
						"G_Shades_Blue",
						"G_Shades_Green",
						"G_Shades_Red",
						"G_Sport_Blackred",
						"G_Sport_BlackWhite",
						"G_Sport_Blackyellow",
						"G_Sport_Checkered",
						"G_Sport_Greenblack",
						"G_Sport_Red",
						"G_B_Diving",
						"G_Combat_Goggles_tna_F",
						"UK3CB_BAF_G_Tactical_Grey",
						"UK3CB_BAF_G_Tactical_Orange",
						"UK3CB_BAF_G_Tactical_Yellow",
						"UK3CB_BAF_G_Tactical_Clear",
						"UK3CB_BAF_G_Tactical_Black",
						"UK3CB_BAF_G_Balaclava_Win",
						"UK3CB_BAF_U_CombatUniform_Arctic_Ghillie_RM",
						"UK3CB_BAF_U_CombatUniform_MTP",
						"UK3CB_BAF_U_CombatUniform_MTP_Ghillie_RM",
						"UK3CB_BAF_U_CombatUniform_MTP_ShortSleeve",
						"UK3CB_BAF_U_CombatUniform_MTP_TShirt",
						"UK3CB_BAF_U_HeliPilotCoveralls_RAF",
						"UK3CB_BAF_U_JumperUniform_Plain",
						"UK3CB_BAF_U_JumperUniform_MTP",
						"UK3CB_BAF_U_Smock_MTP",
						"UK3CB_BAF_U_Smock_MTP_DPMW",
						"UK3CB_BAF_U_Smock_DPMW_OLI",
						"UK3CB_BAF_U_Smock_DPMW_MTP",
						"UK3CB_BAF_U_Smock_Arctic",
						"UK3CB_BAF_U_Smock_DPMW_Arctic",
						"UK3CB_BAF_U_Smock_MTP_Arctic",
						"UK3CB_BAF_U_RolledUniform_MTP",
						"UK3CB_BAF_V_Osprey",
						"UK3CB_BAF_V_Osprey_Belt_A",
						"UK3CB_BAF_V_Osprey_Holster",
						"UK3CB_BAF_V_Osprey_Grenadier_A",
						"UK3CB_BAF_V_Osprey_Grenadier_B",
						"UK3CB_BAF_V_Osprey_Marksman_A",
						"UK3CB_BAF_V_Osprey_Medic_A",
						"UK3CB_BAF_V_Osprey_Medic_B",
						"UK3CB_BAF_V_Osprey_Medic_C",
						"UK3CB_BAF_V_Osprey_Medic_D",
						"UK3CB_BAF_V_Osprey_MG_A",
						"UK3CB_BAF_V_Osprey_MG_B",
						"UK3CB_BAF_V_Osprey_Rifleman_A",
						"UK3CB_BAF_V_Osprey_Rifleman_B",
						"UK3CB_BAF_V_Osprey_Rifleman_C",
						"UK3CB_BAF_V_Osprey_Rifleman_D",
						"UK3CB_BAF_V_Osprey_Rifleman_E",
						"UK3CB_BAF_V_Osprey_Rifleman_F",
						"UK3CB_BAF_V_Osprey_SL_A",
						"UK3CB_BAF_V_Osprey_SL_B",
						"UK3CB_BAF_V_Osprey_SL_C",
						"UK3CB_BAF_V_Osprey_SL_D",
						"UK3CB_BAF_V_Osprey_Lite",
						"UK3CB_BAF_V_PLCE_Webbing_MTP",
						"UK3CB_BAF_V_PLCE_Webbing_Plate_MTP",
						"UK3CB_BAF_V_PLCE_Webbing_Plate_Winter",
						"UK3CB_BAF_V_PLCE_Webbing_Winter",
						"optic_NVS",
						"UK3CB_BAF_Eotech",
						"UK3CB_BAF_SpecterLDS",
						"UK3CB_BAF_SpecterLDS_3D",
						"UK3CB_BAF_SpecterLDS_Dot",
						"UK3CB_BAF_SpecterLDS_Dot_3D",
						"UK3CB_BAF_SUIT",
						"UK3CB_BAF_SUSAT",
						"UK3CB_BAF_TA31F",
						"UK3CB_BAF_TA31F_Hornbill",
						"UK3CB_BAF_TA648",
						"UK3CB_BAF_TA648_308",
						"UK3CB_BAF_LLM_IR_Tan",
						"UK3CB_BAF_LLM_IR_Black",
						"UK3CB_BAF_LLM_Flashlight_Tan",
						"UK3CB_BAF_LLM_Flashlight_Black",
						"UK3CB_BAF_Flashlight_L131A1",
						"UK3CB_BAF_SFFH",
						"UK3CB_BAF_Silencer_L85",
						"UK3CB_BAF_Silencer_L110",
						"UK3CB_BAF_Silencer_L115A3",
						"UK3CB_BAF_Silencer_L91A1",
						"RKSL_optic_LDS",
						"RKSL_optic_LDS_C",
						"UK3CB_BAF_H_Wool_Hat",
						"UK3CB_BAF_H_Boonie_DPMT",
						"UK3CB_BAF_H_Boonie_DPMW",
						"UK3CB_BAF_H_Boonie_DDPM",
						"UK3CB_BAF_H_Boonie_MTP",
						"UK3CB_BAF_H_Boonie_DPMT_PRR",
						"UK3CB_BAF_H_Boonie_DPMW_PRR",
						"UK3CB_BAF_H_Boonie_DDPM_PRR",
						"UK3CB_BAF_H_Boonie_MTP_PRR",
						"UK3CB_BAF_H_Earphone",
						"UK3CB_BAF_H_Headset_PRR",
						"UK3CB_BAF_H_Mk7_HiVis",
						"UK3CB_BAF_V_Osprey_HiVis",
						"UK3CB_BAF_V_HiVis",
						"UK3CB_underbarrel_acc_afg",
						"UK3CB_underbarrel_acc_afg_d",
						"UK3CB_underbarrel_acc_afg_g",
						"UK3CB_underbarrel_acc_afg_t",
						"UK3CB_underbarrel_acc_afg_w",
						"UK3CB_underbarrel_acc_grippod",
						"UK3CB_underbarrel_acc_grippod_d",
						"UK3CB_underbarrel_acc_grippod_g",
						"UK3CB_underbarrel_acc_grippod_t",
						"UK3CB_underbarrel_acc_grippod_w"					
				];

    // These items are included by the permit groups, but by default aren't permitted by everyone and will be added
    // where required, faster than either whitelisting, or blacklisting only

    _blacklistGroups  = ["V_Rangemaster", "V_I_G_resistanceLeader","V_Press",
                         "V_DeckCrew", "V_Plain", "V_Safety", "V_EOD", "V_EOD_IDAP",
                         "V_PlateCarrier", "V_RebreatherIR", "V_RebreatherIA", "G_Respirator", "G_Lady", "G_EyeProtectors",
                         "optic_LRPS", "optic_AMS", "optic_SOS", "optic_KHS", "optic_DMS", "optic_tws", "optic_Nightstalker"];

    _blacklistItems   = ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard", "U_B_T_FullGhillie_tna_F", "U_B_T_Sniper_F",
                        "U_B_GEN_Soldier_F", "U_B_GEN_Commander_F", "U_B_Protagonist_VR",
                        "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls",
                        "V_TacVest_gen_F", "G_I_Diving", "G_O_Diving", "G_WirelessEarpiece_F", "G_Goggles_VR","UK3CB_BAF_Kite",
						"UK3CB_BAF_MaxiKite",
						"RKSL_optic_PMII_312",
						"RKSL_optic_PMII_312_sunshade",
						"RKSL_optic_PMII_312_wdl",
						"RKSL_optic_PMII_312_sunshade_wdl",
						"RKSL_optic_PMII_312_des",
						"RKSL_optic_PMII_312_sunshade_des",
						"RKSL_optic_PMII_525",
						"RKSL_optic_PMII_525_wdl",
						"RKSL_optic_PMII_525_des",
						"rksl_optic_pmii_312"];

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
                              "U_B_PilotCoveralls", "U_B_HeliPilotCoveralls",
								"UK3CB_BAF_H_CrewHelmet_A",
								"UK3CB_BAF_H_CrewHelmet_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_B",
								"UK3CB_BAF_H_CrewHelmet_DPMT_A",
								"UK3CB_BAF_H_CrewHelmet_DPMT_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_DDPM_A",
								"UK3CB_BAF_H_CrewHelmet_DDPM_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_DPMW_A",
								"UK3CB_BAF_H_CrewHelmet_DPMW_ESS_A",
								"UK3CB_BAF_H_PilotHelmetHeli_A",
								"UK3CB_BAF_V_Pilot_A"
								];
    };

    // MERT have heli helmets
    if(["MERT"] call YFNC(testTraits)) then {
        _permitItems append ["H_CrewHelmetHeli_B", "H_CrewHelmetHeli_O",
								"UK3CB_BAF_H_CrewHelmet_A",
								"UK3CB_BAF_H_CrewHelmet_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_B",
								"UK3CB_BAF_H_CrewHelmet_DPMT_A",
								"UK3CB_BAF_H_CrewHelmet_DPMT_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_DDPM_A",
								"UK3CB_BAF_H_CrewHelmet_DDPM_ESS_A",
								"UK3CB_BAF_H_CrewHelmet_DPMW_A",
								"UK3CB_BAF_H_CrewHelmet_DPMW_ESS_A",
								"ToolKit"
							];
    };

    // Squad Spotters/Snipers also get NATO Ghillies
    if(["SNIPER", "SPOTTER"] call YFNC(testTraits)) then {
        _permitItems append ["U_B_GhillieSuit", "U_B_FullGhillie_lsh", "U_B_FullGhillie_sard", "U_B_FullGhillie_ard"];
    };

    if(["SNIPER", "MARKSMAN", "SPOTTER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_AMS", "optic_SOS", "optic_DMS", "optic_KHS"];
    };

//Desired to allow 312 to Spotter but tech diff., rksl_optic_pmii_312 has issues so blacklisted

    if(["SNIPER"] call YFNC(testTraits)) then {
        _permitGroups append ["optic_LRPS", "optic_Nightstalker"];
		_permitItems append ["UK3CB_BAF_Kite",
							"UK3CB_BAF_MaxiKite",
							"RKSL_optic_PMII_525",
							"RKSL_optic_PMII_525_wdl",
							"RKSL_optic_PMII_525_des",
							"RKSL_optic_PMII_312_sunshade", "RKSL_optic_PMII_312_wdl",
							"RKSL_optic_PMII_312_sunshade_wdl", "RKSL_optic_PMII_312_des", 
							"RKSL_optic_PMII_312_sunshade_des"];
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
        _blacklistItems append ["ACE_optic_LRPS_2D", "ACE_optic_LRPS_PIP", "ACE_optic_SOS_2D", "ACE_optic_SOS_PIP"];
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

    _permitItems  = ["B_UAV_01_backpack_F",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_H_A",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_H_B",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_H_C",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_A",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_B",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_C",
					"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_D",
					"UK3CB_BAF_B_Bergen_MTP_SL_H_A",
					"UK3CB_BAF_B_Bergen_MTP_SL_L_A",
					"UK3CB_BAF_B_Bergen_MTP_Medic_H_A",
					"UK3CB_BAF_B_Bergen_MTP_Medic_H_B",
					"UK3CB_BAF_B_Bergen_MTP_Medic_L_A",
					"UK3CB_BAF_B_Bergen_MTP_Medic_L_B",
					"UK3CB_BAF_B_Bergen_MTP_Engineer_H_A",
					"UK3CB_BAF_B_Bergen_MTP_Engineer_L_A",
					"UK3CB_BAF_B_Bergen_MTP_Sapper_H_A",
					"UK3CB_BAF_B_Bergen_MTP_Sapper_L_A",
					"UK3CB_BAF_B_Bergen_MTP_PointMan_H_A",
					"UK3CB_BAF_B_Bergen_MTP_PointMan_L_A",
					"UK3CB_BAF_B_Carryall_MTP",
					"UK3CB_BAF_B_Kitbag_MTP",
					"ACE_TacticalLadder_Pack",
					"ACE_ReserveParachute",
					"B_Parachute",
					"UK3CB_BAF_B_Bergen_Arctic_Rifleman_A",
					"UK3CB_BAF_B_Bergen_Arctic_Rifleman_B",
					"UK3CB_BAF_B_Kitbag_Arctic",
					"UK3CB_BAF_B_Carryall_Arctic",
					"UK3CB_BAF_B_Bergen_OLI_Rifleman_A",
					"UK3CB_BAF_B_Bergen_OLI_Rifleman_B",
					"UK3CB_BAF_B_Kitbag_OLI",
					"UK3CB_BAF_B_Carryall_OLI"];

    if (["MERT_UAV"] call YFNC(testTraits)) then {
        _permitGroups pushBackUnique "B_MedicalUAV";
    };

    if (_hasTFAR) then {

		 _permitGroups pushBack "tf_rt1523g";
		 _permitItems append ["UK3CB_BAF_B_Bergen_MTP_Radio_H_A",
								"UK3CB_BAF_B_Bergen_MTP_Radio_H_B",
								"UK3CB_BAF_B_Bergen_MTP_Radio_L_A",
								"UK3CB_BAF_B_Bergen_MTP_Radio_L_B",
								"UK3CB_BAF_B_Bergen_MTP_JTAC_H_A",
								"UK3CB_BAF_B_Bergen_MTP_JTAC_L_A",
								"UK3CB_BAF_B_Bergen_Arctic_SL_A",
								"UK3CB_BAF_B_Bergen_Arctic_JTAC_A",
								"UK3CB_BAF_B_Bergen_Arctic_JTAC_H_A",
								"UK3CB_BAF_B_Bergen_OLI_SL_A",
								"UK3CB_BAF_B_Bergen_OLI_JTAC_A",
								"UK3CB_BAF_B_Bergen_OLI_JTAC_H_A"];
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
	_items	 = ["UK3CB_BAF_HandGrenade_Blank_Ammo",
						"UK3CB_BAF_B_127x99_Ball", 
						"UK3CB_BAF_B_127x99_AP", 
						"UK3CB_BAF_B_12Gauge_Pellets", 
						"UK3CB_BAF_B_12Gauge_Slug", 
						"UK3CB_BAF_Blank", 
						"UK3CB_BAF_556_Ball", 
						"UK3CB_BAF_556_Ball_Tracer_Red", 
						"UK3CB_BAF_762_Ball", 
						"UK3CB_BAF_762_Ball_Tracer_Red", 
						"UK3CB_BAF_762_Ball_L42A1", 
						"UK3CB_BAF_762_Ball_L42A1_Tracer_Red", 
						"UK3CB_BAF_762_Ball_B416",
						"UK3CB_BAF_338_Ball", 
						"UK3CB_BAF_338_Ball_Tracer_Red", 
						"UK3CB_BAF_G_40mm_Blank",
						"UK3CB_BAF_F_40mm_White", 
						"UK3CB_BAF_F_40mm_Green", 
						"UK3CB_BAF_F_40mm_Red", 
						"UK3CB_BAF_F_40mm_Yellow", 
						"UK3CB_BAF_F_40mm_CIR",
						"UK3CB_BAF_Smoke_81mm_AMOS", 
						"UK3CB_BAF_Flare_81mm_AMOS_White", 
						"UK3CB_BAF_IRFlare_81mm_AMOS_White", 
						"UK3CB_BAF_Sh_60mm_AMOS", 
						"UK3CB_BAF_Flare_60mm_AMOS_White", 
						"UK3CB_BAF_Smoke_60mm_AMOS",
						"UK3CB_BAF_HandGrenade_Blank",
						"UK3CB_BAF_9_17Rnd", 
						"UK3CB_BAF_9_30Rnd", 
						"UK3CB_BAF_127_10Rnd", 
						"UK3CB_BAF_127_10Rnd_AP", 
						"UK3CB_BAF_127_100Rnd",
						"UK3CB_BAF_12G_Pellets", 
						"UK3CB_BAF_12G_Slugs",
						"UK3CB_BAF_338_5Rnd", 
						"UK3CB_BAF_338_5Rnd_Blank", 
						"UK3CB_BAF_338_5Rnd_Tracer",
						"UK3CB_BAF_556_30Rnd", 
						"UK3CB_BAF_556_30Rnd_Blank", 
						"UK3CB_BAF_556_30Rnd_T", 
						"UK3CB_BAF_556_100Rnd", 
						"UK3CB_BAF_556_100Rnd_Blank", 
						"UK3CB_BAF_556_100Rnd_T", 
						"UK3CB_BAF_556_200Rnd", 
						"UK3CB_BAF_556_200Rnd_Blank", 
						"UK3CB_BAF_556_200Rnd_T", 
						"UK3CB_BAF_762_20Rnd", 
						"UK3CB_BAF_762_20Rnd_Blank", 
						"UK3CB_BAF_762_20Rnd_T", 
						"UK3CB_BAF_762_100Rnd", 
						"UK3CB_BAF_762_100Rnd_Blank", 
						"UK3CB_BAF_762_100Rnd_T", 
						"UK3CB_BAF_762_200Rnd", 
						"UK3CB_BAF_762_200Rnd_Blank", 
						"UK3CB_BAF_762_200Rnd_T", 
						"UK3CB_BAF_762_L42A1_10Rnd", 
						"UK3CB_BAF_762_L42A1_10Rnd_Blank", 
						"UK3CB_BAF_762_L42A1_10Rnd_T",
						"UK3CB_BAF_762_L42A1_20Rnd", 
						"UK3CB_BAF_762_L42A1_20Rnd_Blank", 
						"UK3CB_BAF_762_L42A1_20Rnd_T", 
						"UK3CB_BAF_1Rnd_HE_Grenade_Shell", 
						"UK3CB_BAF_1Rnd_HEDP_Grenade_Shell", 
						"UK3CB_BAF_1Rnd_Blank_Grenade_Shell",
						"UK3CB_BAF_UGL_FlareWhite_F", 
						"UK3CB_BAF_UGL_FlareRed_F", 
						"UK3CB_BAF_UGL_FlareGreen_F", 
						"UK3CB_BAF_UGL_FlareYellow_F", 
						"UK3CB_BAF_UGL_FlareCIR_F",
						"UK3CB_BAF_32Rnd_40mm_G_Box",
						"UK3CB_BAF_1Rnd_60mm_Mo_Shells", 
						"UK3CB_BAF_1Rnd_60mm_Mo_Flare_White", 
						"UK3CB_BAF_1Rnd_60mm_Mo_Smoke_White",
						"UK3CB_BAF_1Rnd_81mm_Mo_Shells", 
						"UK3CB_BAF_1Rnd_81mm_Mo_Flare_White", 
						"UK3CB_BAF_1Rnd_81mm_Mo_IRFlare_White", 
						"UK3CB_BAF_1Rnd_81mm_Mo_Smoke_White", 
						"UK3CB_BAF_1Rnd_81mm_Mo_Guided", 
						"UK3CB_BAF_1Rnd_81mm_Mo_LG"];
						
    _blacklistGroups = ["Mine"];

    // And we don't want Red Flares, UGLs
    _blacklistItems  = ["6Rnd_RedSignal_F"];

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
	
	if (_hasACE) then {
    _blacklistItems = ["ACE_Chemlight_HiRed", "ACE_HandFlare_Red"] ;
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
