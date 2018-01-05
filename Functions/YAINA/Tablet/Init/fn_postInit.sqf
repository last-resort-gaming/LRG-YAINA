/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (hasInterface) then {

    if (["HQ"] call YFNC(testTraits)) then {

        player addAction [
            "Open Command Tablet",
            { call FNC(openTablet); }
        ];

        // Add for respawn too
        player addEventHandler ["Respawn", {
            player addAction [
                "Open Command Tablet",
                { call FNC(openTablet); }
            ];
        }];
    };
};

/*
	author: Martin
	description: none
	returns: nothing

    _i = [];
    _r = [];
    {
      _c = configName _x;
      _t = _c call {
        if (getNumber (_x >> "isUav") isEqualTo 1) exitWIth { "UAV" };
        if (_this isKindOf "Plane") exitWIth { "Plane" };
        if (_this isKindOf "Helicopter") exitWith { "Helicopter"; };
        if (_this isKindOf "LandVehicle") exitWith { "LandVehicle"; };
        nil;
      };
      if !(isNil "_t") then {
        _idx = _i find _t;
        if(_idx isEqualTo -1) then {
          _i pushBack _t;
          _r pushBack [[_c, 100, 30]];
        } else {
          (_r select _idx) pushBack [_c, 100, 30];
        };
      };
    } forEach (("_cn = configName _x; getNumber(_x >> 'scope') isEqualTo 2 && ({ _cn isKindOf _x; } count ['Plane', 'Helicopter', 'LandVehicle']) > 0 && !(_cn isKindOf 'StaticWeapon')" configClasses (configFile >> "CfgVehicles")));
    copyToClipboard str _r

*/
if (isServer) then {

    GVAR(rewards) = [
        [
            ["B_Heli_Light_01_F",100,10],
            ["B_Heli_Light_01_dynamicLoadout_F",100,10],
            ["C_Heli_Light_01_civil_F",100,10],
            ["O_Heli_Light_02_dynamicLoadout_F",100,10],
            ["O_Heli_Light_02_unarmed_F",100,10],
            ["B_Heli_Attack_01_dynamicLoadout_F",100,10],
            ["O_Heli_Attack_02_dynamicLoadout_F",100,10],
            ["B_Heli_Transport_01_F",100,10],
            ["I_Heli_Transport_02_F",100,10],
            ["I_Heli_light_03_dynamicLoadout_F",100,10],
            ["I_Heli_light_03_unarmed_F",100,10],
            ["B_Heli_Transport_03_F",100,10],
            ["B_Heli_Transport_03_unarmed_F",100,10],
            ["O_Heli_Transport_04_F",100,10],
            ["O_Heli_Transport_04_ammo_F",100,10],
            ["O_Heli_Transport_04_bench_F",100,10],
            ["O_Heli_Transport_04_box_F",100,10],
            ["O_Heli_Transport_04_covered_F",100,10],
            ["O_Heli_Transport_04_fuel_F",100,10],
            ["O_Heli_Transport_04_medevac_F",100,10],
            ["O_Heli_Transport_04_repair_F",100,10],
            ["I_C_Heli_Light_01_civil_F",100,10],
            ["B_CTRG_Heli_Transport_01_sand_F",100,10],
            ["B_CTRG_Heli_Transport_01_tropic_F",100,10],
            ["C_IDAP_Heli_Transport_02_F",100,10]
        ],
        [
            ["I_Plane_Fighter_03_dynamicLoadout_F",100,10],
            ["B_Plane_CAS_01_dynamicLoadout_F",100,10],
            ["O_Plane_CAS_02_dynamicLoadout_F",100,10],
            ["C_Plane_Civil_01_F",100,10],
            ["C_Plane_Civil_01_racing_F",100,10],
            ["I_C_Plane_Civil_01_F",100,10],
            ["B_T_VTOL_01_infantry_F",100,10],
            ["B_T_VTOL_01_vehicle_F",100,10],
            ["B_T_VTOL_01_armed_F",100,10],
            ["O_T_VTOL_02_infantry_dynamicLoadout_F",100,10],
            ["O_T_VTOL_02_vehicle_dynamicLoadout_F",100,10],
            ["B_Plane_Fighter_01_F",100,10],
            ["B_Plane_Fighter_01_Stealth_F",100,10],
            ["O_Plane_Fighter_02_F",100,10],
            ["O_Plane_Fighter_02_Stealth_F",100,10],
            ["I_Plane_Fighter_04_F",100,10]
        ],
        [
            ["B_APC_Tracked_01_rcws_F",100,10],
            ["B_APC_Tracked_01_CRV_F",100,10],
            ["B_APC_Tracked_01_AA_F",100,10],
            ["O_APC_Tracked_02_cannon_F",100,10],
            ["O_APC_Tracked_02_AA_F",100,10],
            ["B_MBT_01_cannon_F",100,10],
            ["B_MBT_01_arty_F",100,10],
            ["B_MBT_01_mlrs_F",100,10],
            ["O_MBT_02_cannon_F",100,10],
            ["O_MBT_02_arty_F",100,10],
            ["B_MRAP_01_F",100,10],
            ["B_MRAP_01_gmg_F",100,10],
            ["B_MRAP_01_hmg_F",100,10],
            ["O_MRAP_02_F",100,10],
            ["O_MRAP_02_hmg_F",100,10],
            ["O_MRAP_02_gmg_F",100,10],
            ["C_Offroad_01_F",100,10],
            ["C_Offroad_01_repair_F",100,10],
            ["B_G_Offroad_01_repair_F",100,10],
            ["O_G_Offroad_01_repair_F",100,10],
            ["I_G_Offroad_01_repair_F",100,10],
            ["I_G_Offroad_01_F",100,10],
            ["I_G_Offroad_01_armed_F",100,10],
            ["B_G_Offroad_01_F",100,10],
            ["O_G_Offroad_01_F",100,10],
            ["B_G_Offroad_01_armed_F",100,10],
            ["O_G_Offroad_01_armed_F",100,10],
            ["C_Quadbike_01_F",100,10],
            ["B_Quadbike_01_F",100,10],
            ["O_Quadbike_01_F",100,10],
            ["I_Quadbike_01_F",100,10],
            ["I_G_Quadbike_01_F",100,10],
            ["B_G_Quadbike_01_F",100,10],
            ["O_G_Quadbike_01_F",100,10],
            ["I_MRAP_03_F",100,10],
            ["I_MRAP_03_hmg_F",100,10],
            ["I_MRAP_03_gmg_F",100,10],
            ["B_Truck_01_transport_F",100,10],
            ["B_Truck_01_covered_F",100,10],
            ["O_Truck_02_covered_F",100,10],
            ["O_Truck_02_transport_F",100,10],
            ["I_Truck_02_covered_F",100,10],
            ["I_Truck_02_transport_F",100,10],
            ["C_Truck_02_covered_F",100,10],
            ["C_Truck_02_transport_F",100,10],
            ["C_Hatchback_01_F",100,10],
            ["C_Hatchback_01_sport_F",100,10],
            ["C_SUV_01_F",100,10],
            ["B_Truck_01_mover_F",100,10],
            ["B_Truck_01_box_F",100,10],
            ["B_Truck_01_Repair_F",100,10],
            ["B_Truck_01_ammo_F",100,10],
            ["B_Truck_01_fuel_F",100,10],
            ["B_Truck_01_medical_F",100,10],
            ["O_Truck_02_box_F",100,10],
            ["O_Truck_02_medical_F",100,10],
            ["O_Truck_02_Ammo_F",100,10],
            ["O_Truck_02_fuel_F",100,10],
            ["I_Truck_02_ammo_F",100,10],
            ["I_Truck_02_box_F",100,10],
            ["I_Truck_02_medical_F",100,10],
            ["I_Truck_02_fuel_F",100,10],
            ["C_Truck_02_fuel_F",100,10],
            ["C_Truck_02_box_F",100,10],
            ["C_Van_01_transport_F",100,10],
            ["I_G_Van_01_transport_F",100,10],
            ["C_Van_01_box_F",100,10],
            ["C_Van_01_fuel_F",100,10],
            ["I_G_Van_01_fuel_F",100,10],
            ["B_G_Van_01_transport_F",100,10],
            ["O_G_Van_01_transport_F",100,10],
            ["B_G_Van_01_fuel_F",100,10],
            ["O_G_Van_01_fuel_F",100,10],
            ["B_APC_Wheeled_01_cannon_F",100,10],
            ["O_APC_Wheeled_02_rcws_F",100,10],
            ["I_APC_tracked_03_cannon_F",100,10],
            ["I_MBT_03_cannon_F",100,10],
            ["B_MBT_01_TUSK_F",100,10],
            ["I_APC_Wheeled_03_cannon_F",100,10],
            ["O_Truck_03_transport_F",100,10],
            ["O_Truck_03_covered_F",100,10],
            ["O_Truck_03_repair_F",100,10],
            ["O_Truck_03_ammo_F",100,10],
            ["O_Truck_03_fuel_F",100,10],
            ["O_Truck_03_medical_F",100,10],
            ["O_Truck_03_device_F",100,10],
            ["C_Kart_01_F",100,10],
            ["C_Kart_01_Fuel_F",100,10],
            ["C_Kart_01_Blu_F",100,10],
            ["C_Kart_01_Red_F",100,10],
            ["C_Kart_01_Vrana_F",100,10],
            ["B_T_LSV_01_armed_F",100,10],
            ["B_T_LSV_01_unarmed_F",100,10],
            ["B_LSV_01_armed_F",100,10],
            ["B_LSV_01_unarmed_F",100,10],
            ["B_CTRG_LSV_01_light_F",100,10],
            ["O_T_LSV_02_armed_F",100,10],
            ["O_T_LSV_02_unarmed_F",100,10],
            ["O_LSV_02_armed_F",100,10],
            ["O_LSV_02_unarmed_F",100,10],
            ["B_T_MRAP_01_F",100,10],
            ["B_T_MRAP_01_gmg_F",100,10],
            ["B_T_MRAP_01_hmg_F",100,10],
            ["O_T_MRAP_02_ghex_F",100,10],
            ["O_T_MRAP_02_hmg_ghex_F",100,10],
            ["O_T_MRAP_02_gmg_ghex_F",100,10],
            ["B_GEN_Offroad_01_gen_F",100,10],
            ["C_Offroad_02_unarmed_F",100,10],
            ["I_C_Offroad_02_unarmed_F",100,10],
            ["O_T_Quadbike_01_ghex_F",100,10],
            ["B_T_Quadbike_01_F",100,10],
            ["B_T_Truck_01_mover_F",100,10],
            ["B_T_Truck_01_ammo_F",100,10],
            ["B_T_Truck_01_box_F",100,10],
            ["B_T_Truck_01_fuel_F",100,10],
            ["B_T_Truck_01_medical_F",100,10],
            ["B_T_Truck_01_Repair_F",100,10],
            ["B_T_Truck_01_transport_F",100,10],
            ["B_T_Truck_01_covered_F",100,10],
            ["O_T_Truck_03_transport_ghex_F",100,10],
            ["O_T_Truck_03_covered_ghex_F",100,10],
            ["O_T_Truck_03_repair_ghex_F",100,10],
            ["O_T_Truck_03_ammo_ghex_F",100,10],
            ["O_T_Truck_03_fuel_ghex_F",100,10],
            ["O_T_Truck_03_medical_ghex_F",100,10],
            ["O_T_Truck_03_device_ghex_F",100,10],
            ["I_C_Van_01_transport_F",100,10],
            ["B_T_APC_Tracked_01_AA_F",100,10],
            ["B_T_APC_Tracked_01_CRV_F",100,10],
            ["B_T_APC_Tracked_01_rcws_F",100,10],
            ["O_T_APC_Tracked_02_cannon_ghex_F",100,10],
            ["O_T_APC_Tracked_02_AA_ghex_F",100,10],
            ["B_T_APC_Wheeled_01_cannon_F",100,10],
            ["O_T_APC_Wheeled_02_rcws_ghex_F",100,10],
            ["B_T_MBT_01_arty_F",100,10],
            ["B_T_MBT_01_mlrs_F",100,10],
            ["B_T_MBT_01_cannon_F",100,10],
            ["B_T_MBT_01_TUSK_F",100,10],
            ["O_T_MBT_02_cannon_ghex_F",100,10],
            ["O_T_MBT_02_arty_ghex_F",100,10],
            ["C_IDAP_Offroad_01_F",100,10],
            ["C_IDAP_Offroad_02_unarmed_F",100,10],
            ["C_IDAP_Truck_02_F",100,10],
            ["C_IDAP_Truck_02_transport_F",100,10],
            ["C_IDAP_Truck_02_water_F",100,10],
            ["C_Van_02_transport_F",100,10],
            ["C_IDAP_Van_02_transport_F",100,10],
            ["I_G_Van_02_transport_F",100,10],
            ["B_G_Van_02_transport_F",100,10],
            ["O_G_Van_02_transport_F",100,10],
            ["I_C_Van_02_transport_F",100,10],
            ["C_Van_02_vehicle_F",100,10],
            ["C_IDAP_Van_02_vehicle_F",100,10],
            ["I_G_Van_02_vehicle_F",100,10],
            ["B_G_Van_02_vehicle_F",100,10],
            ["O_G_Van_02_vehicle_F",100,10],
            ["I_C_Van_02_vehicle_F",100,10],
            ["C_Van_02_medevac_F",100,10],
            ["C_IDAP_Van_02_medevac_F",100,10],
            ["C_Van_02_service_F",100,10]
        ],
        [
            ["B_UAV_01_F",1033330,10],
            ["B_UAV_02_dynamicLoadout_F",100,10],
            ["B_UGV_01_F",100,10],
            ["B_UGV_01_rcws_F",100,10],
            ["B_T_UAV_03_dynamicLoadout_F",100,10],
            ["B_UAV_05_F",100,100],
            ["B_UAV_06_F",100,330],
            ["B_UAV_06_medical_F",100,10]
        ]
    ];


    publicVariable QVAR(rewards);

    GVAR(orderRewardInProgress) = false;
    publicVariable QVAR(orderRewardInProgress);
};
