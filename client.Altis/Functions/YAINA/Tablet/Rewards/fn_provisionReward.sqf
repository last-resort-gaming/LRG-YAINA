/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player", "_class"];

if !(isServer) exitWith {};

private _clearPylons = {
    // Then Remove the weapons, and works on UAVs nicely so you don't, after removing the
    // pylons, get the weapon showing up with 0 ammo
    { _this removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon"); } forEach getPylonMagazines _this;

    // Clear any remaining pylon loadouts
    { _this setPylonLoadOut [_forEachIndex + 1, ""]; } forEach getPylonMagazines _this;
};

private _sp = _class call FNC(getSpawnPoint);
private _veh = _class createVehicle [0,0,1000];

if (!alive _veh) exitWith {};

// General Start
_veh enableSimulation false;

// Manage our Loadouts / Animations / Textures
call {

    if (_class isKindOf "Plane" && { !(_class call YFNC(isUAV)) } ) exitWith {

        // Gryphon
        if (_class isEqualTo "I_Plane_Fighter_04_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_Missile_BIM9X_x1",true,[]],
                [2,"PylonRack_Missile_BIM9X_x1",true,[]],
                [3,"PylonRack_Missile_BIM9X_x1",true,[]],
                [4,"PylonRack_Missile_BIM9X_x1",true,[]],
                [5,"PylonRack_Missile_AMRAAM_D_x2",true,[]],
                [6,"PylonRack_Missile_AMRAAM_D_x2",true,[]]
            ];

            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'a3\air_f_jets\plane_fighter_04\data\Fighter_04_fuselage_01_co.paa'],
                [1,'a3\air_f_jets\plane_fighter_04\data\Fighter_04_fuselage_02_co.paa']
            ];

        };

        // Black Wasp AA
        if (_class isEqualTo "B_Plane_Fighter_01_Stealth_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [5,"PylonMissile_Missile_BIM9X_x1",true,[]],
                [6,"PylonMissile_Missile_BIM9X_x1",true,[]],
                [7,"PylonMissile_Missile_AMRAAM_D_INT_x1",true,[]],
                [8,"PylonMissile_Missile_AMRAAM_D_INT_x1",true,[]],
                [9,"PylonMissile_Missile_AMRAAM_D_INT_x1",true,[]],
                [10,"PylonMissile_Missile_AMRAAM_D_INT_x1",true,[]]
            ];
        };

        // Black Wasp CAS
        if (_class isEqualTo "B_Plane_Fighter_01_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_Missile_AGM_02_x1",true,[]],
                [2,"PylonRack_Missile_AGM_02_x1",true,[]],
                [3,"PylonRack_Missile_AGM_02_x1",true,[]],
                [4,"PylonRack_Missile_AGM_02_x1",true,[]],
                [7,"PylonMissile_1Rnd_BombCluster_01_F",true,[]],
                [8,"PylonMissile_1Rnd_BombCluster_01_F",true,[]],
                [11,"PylonMissile_Bomb_GBU12_x1",true,[]],
                [12,"PylonMissile_Bomb_GBU12_x1",true,[]]
            ];
        };

        // Wipeout
        if (_class isEqualTo "B_Plane_CAS_01_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_Missile_BIM9X_x1",true,[]],
                [2,"PylonRack_Missile_AMRAAM_D_x1",true,[]],
                [3,"PylonRack_Missile_AGM_02_x1",true,[]],
                [4,"PylonMissile_1Rnd_BombCluster_01_F",true,[]],
                [5,"PylonMissile_Bomb_GBU12_x1",true,[]],
                [6,"PylonMissile_Bomb_GBU12_x1",true,[]],
                [7,"PylonMissile_1Rnd_BombCluster_01_F",true,[]],
                [8,"PylonRack_Missile_AGM_02_x1",true,[]],
                [9,"PylonRack_Missile_AMRAAM_D_x1",true,[]],
                [10,"PylonRack_Missile_BIM9X_x1",true,[]]
            ];

        };

        // Shikra AA
        if (_class isEqualTo "O_Plane_Fighter_02_Stealth_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [7,"PylonMissile_Missile_AA_R73_x1",true,[]],
                [8,"PylonMissile_Missile_AA_R73_x1",true,[]],
                [9,"PylonMissile_Missile_AA_R73_x1",true,[]],
                [10,"PylonMissile_Missile_AA_R73_x1",true,[]],
                [11,"PylonMissile_Missile_AA_R77_INT_x1",true,[]],
                [12,"PylonMissile_Missile_AA_R77_INT_x1",true,[]],
                [13,"PylonMissile_Missile_AA_R77_INT_x1",true,[]]
            ];

            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'a3\air_f_jets\plane_fighter_02\data\Fighter_02_fuselage_01_Blue_co.paa'],
                [1,'a3\air_f_jets\plane_fighter_02\data\Fighter_02_fuselage_02_Blue_co.paa']
            ];
        };

        // Shikra CAS
        if (_class isEqualTo "O_Plane_Fighter_02_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [2,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [3,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [4,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [7,"PylonMissile_1Rnd_BombCluster_02_F",true,[]],
                [8,"PylonMissile_1Rnd_BombCluster_02_F",true,[]],
                [11,"PylonMissile_Bomb_KAB250_x1",true,[]],
                [12,"PylonMissile_Bomb_KAB250_x1",true,[]]
            ];

            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'a3\air_f_jets\plane_fighter_02\data\Fighter_02_fuselage_01_Blue_co.paa'],
                [1,'a3\air_f_jets\plane_fighter_02\data\Fighter_02_fuselage_02_Blue_co.paa']
            ];
        };

        // Buzzard CAS
        if (_class isEqualTo "I_Plane_Fighter_03_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_7Rnd_Rocket_04_AP_F",true,[]],
                [7,"PylonRack_7Rnd_Rocket_04_AP_F",true,[]],
                [3,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [5,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [4,"PylonMissile_Bomb_KAB250_x1",true,[]]
            ];

            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'a3\Air_F_Gamma\Plane_Fighter_03\Data\Plane_Fighter_03_body_1_greyhex_CO.paa'],
                [1,'a3\Air_F_Gamma\Plane_Fighter_03\Data\Plane_Fighter_03_body_2_greyhex_CO.paa']
            ];
        };


        // Buzzard AA
        if (_class isEqualTo "I_Plane_Fighter_03_AA_F") exitWith {
            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'a3\Air_F_Gamma\Plane_Fighter_03\Data\Plane_Fighter_03_body_1_greyhex_CO.paa'],
                [1,'a3\Air_F_Gamma\Plane_Fighter_03\Data\Plane_Fighter_03_body_2_greyhex_CO.paa']
            ];
        };

        // Neophron
        if (_class isEqualTo "O_Plane_CAS_02_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [9,"PylonRack_20Rnd_Rocket_03_HE_F",true,[]],
                [2,"PylonRack_20Rnd_Rocket_03_AP_F",true,[]],
                [8,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [3,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [7,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [4,"PylonMissile_Missile_AGM_KH25_x1",true,[]],
                [5,"PylonMissile_Bomb_KAB250_x1",true,[]],
                [6,"PylonMissile_Bomb_KAB250_x1",true,[]]
            ];
        };
    };

    if (_class isKindOf "Helicopter" && { !(_class call YFNC(isUAV)) } ) exitWith {

        // All choppers should have a darter in them
        _veh addBackpackCargoGlobal ["B_UAV_01_backpack_F", 1];

        // Ghost Hawk
        if (_class in ["B_Heli_Transport_01_camo_F","B_Heli_Transport_01_F","B_CTRG_Heli_Transport_01_sand_F","B_CTRG_Heli_Transport_01_tropic_F"]) exitWith {
            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext01_BLUFOR_CO.paa'],
                [1,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext02_BLUFOR_CO.paa']
            ];
        };

        // Huron
        if (_class in ["B_Heli_Transport_03_F","B_Heli_Transport_03_unarmed_F"]) exitWith {
            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0, 'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext01_co.paa'],
                [1, 'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext02_co.paa']
            ];
        };

        // Hummingbird
        if (_class isEqualTo "B_Heli_Light_01_F") exitWith {
            _veh setObjectTextureGlobal [0, 'a3\air_f\heli_light_01\data\heli_light_01_ext_blufor_co.paa'];
        };

        // Kajman
        if (_class isEqualTo "O_Heli_Attack_02_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_19Rnd_Rocket_Skyfire",true,[]],
                [2,"PylonRack_12Rnd_PG_missiles",true,[0]],
                [3,"PylonRack_12Rnd_PG_missiles",true,[0]],
                [4,"PylonRack_19Rnd_Rocket_Skyfire",true,[]]
            ];

            {
                _veh setObjectTextureGlobal _x;
            } count [
                [0,'A3\Air_F_Beta\Heli_Attack_02\Data\Heli_Attack_02_body1_black_CO.paa'],
                [1,'A3\Air_F_Beta\Heli_Attack_02\Data\Heli_Attack_02_body2_black_CO.paa']
            ];

        };

        // Hellcat (Unarmed)
        if (_class isEqualTo "I_Heli_light_03_unarmed_F") exitWith {
            _veh setObjectTextureGlobal [0,'\A3\Air_F_EPB\Heli_Light_03\data\Heli_Light_03_base_CO.paa'];
        };

        // Hellcat (CAS)
        if (_class isEqualTo "I_Heli_light_03_dynamicLoadout_F") exitWith {
            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_12Rnd_PG_missiles",true],
                [2,"PylonRack_12Rnd_PG_missiles",true]
            ];

            _veh setObjectTextureGlobal [0,'\A3\Air_F_EPB\Heli_Light_03\data\Heli_Light_03_base_CO.paa'];
        };

        // Pawnee
        if (_class isEqualTo "I_Heli_light_03_dynamicLoadout_F") exitWith {
            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_12Rnd_PG_missiles",true],
                [2,"PylonRack_12Rnd_PG_missiles",true]
            ];

            _veh setObjectTextureGlobal [0,'\A3\Air_F_EPB\Heli_Light_03\data\Heli_Light_03_base_CO.paa'];
        };

        if (_class isEqualTo "B_Heli_Attack_01_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonMissile_1Rnd_AAA_missiles",true,[]],
                [2,"PylonRack_12Rnd_PG_missiles",true,[0]],
                [3,"PylonMissile_1Rnd_LG_scalpel",true,[0]],
                [4,"PylonMissile_1Rnd_LG_scalpel",true,[0]],
                [5,"PylonRack_12Rnd_PG_missiles",true,[0]],
                [6,"PylonMissile_1Rnd_AAA_missiles",true,[]]
            ];
        };

        // Orca
        if (_class isEqualTo "O_Heli_Light_02_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            _veh setObjectTextureGlobal [0,'\A3\Air_F_Heli\Heli_Light_02\Data\Heli_Light_02_ext_OPFOR_V2_CO.paa'];

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_12Rnd_PG_missiles",true],
                [2,"PylonRack_19Rnd_Rocket_Skyfire",true]
            ];
        };

    };

    if (_class call YFNC(isUAV)) exitWith {

        // We always create a crew, trigger our UAV Spawned event
        // for UAV restrictions
        createVehicleCrew _veh;
        ["UAVSpawn", _veh] call CBAP_fnc_globalEvent;

        // Sentinel
        if (_class isEqualTo "B_UAV_05_F") exitWith {

            // Fold up
            { _veh animate [_x, 1,true] } foreach ['wing_fold_l','wing_fold_r','wing_fold_cover_l','wing_fold_cover_r','wing_fold_l_arm','wing_fold_cover_l_arm','wing_fold_r_arm','wing_fold_cover_r_arm'];

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_Bomb_GBU12_x2",true,[0]],
                [2,"PylonMissile_1Rnd_BombCluster_01_F",true,[0]]
            ];
        };

        // Greyhawk
        if (_class isEqualTo "B_UAV_02_dynamicLoadout_F") exitWith {

            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_Bomb_GBU12_x2",true,[0]],
                [2,"PylonRack_Bomb_GBU12_x2",true,[0]]
            ];

        };

        // Falcon
        if (_class isEqualTo "B_T_UAV_03_dynamicLoadout_F") exitWith {
            _veh call _clearPylons;

            {
                _veh setPylonLoadout _x;
                nil;
            } count [
                [1,"PylonRack_4Rnd_LG_scalpel",true,[0]],
                [2,"PylonRack_7Rnd_Rocket_04_HE_F",true,[0]],
                [3,"PylonRack_7Rnd_Rocket_04_AP_F",true,[0]],
                [4,"PylonRack_4Rnd_LG_scalpel",true,[0]]
            ];
        };
    };

    // Bobcat
    if (_class isEqualTo "B_APC_Tracked_01_CRV_F") exitWith {
        _veh lockTurret [[0],TRUE];
        _veh animate ['hideturret',1];
        _veh removeWeaponTurret ["LMG_RCWS",[0]];
    };

    // Gorgon
    if (_class isEqualTo "B_APC_Tracked_01_CRV_F") exitWith {
        {
            _veh setObjectTextureGlobal _x;
        } count [
            [0, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext_co.paa"],
            [1, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext2_co.paa"],
            [2, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\rcws30_co.paa"],
            [3, "A3\Armor_F_Gamma\APC_Wheeled_03\Data\apc_wheeled_03_ext_alpha_co.paa"]
        ];
    };

    // Striders
    if (_class in ["I_MRAP_03_F","I_MRAP_03_hmg_F","I_MRAP_03_gmg_F"]) exitWith {
        {
            _veh setObjectTextureGlobal _x;
        } count [
            [0,'\A3\soft_f_beta\mrap_03\data\mrap_03_ext_co.paa'],
            [1,'\A3\data_f\vehicles\turret_co.paa']
        ];
    };

    // Van
    if (_class in ["C_Van_02_transport_F"]) exitWith {
        {
            _veh setObjectTextureGlobal _x;
        } count [
            [0, "a3\soft_f_orange\van_02\data\van_body_fia_03_co.paa"],
            [1, "a3\soft_f_orange\van_02\data\van_wheel_transport_co.paa"],
            [2, "a3\soft_f_orange\van_02\data\van_glass_transport_ca.paa"],
            [3, "a3\soft_f_orange\van_02\data\van_body_fia_03_co.paa"]
        ];
    };
};

// Move to destination Spawn
_veh setDir (triggerArea _sp select 2);
_veh setPosATL (getPosATL _sp);

_veh enableSimulation true;
_veh enableCopilot false;

// We don't respawn, but do give full functionality...
[_veh] call YAINA_VEH_fnc_initVehicle;

// Let folks know...
[_player, format["Reward: %1 has been completed", getText (configFile >> "CfgVehicles" >> _class >> "displayName")]] remoteExec ["sideChat"];
