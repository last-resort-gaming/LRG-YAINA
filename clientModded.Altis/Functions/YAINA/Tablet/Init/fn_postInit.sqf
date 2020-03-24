/*
Function: YAINA_TABLET_fnc_postInit

Description:
	Handles initialization of the HQ tablet during the postInit phase.
    Mainly concerned with initializing the required variables and event
    handlers.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

if (hasInterface) then {

    _res = {
        if ([["HQ", "hq-tablet"]] call YFNC(testTraits)) then {
            player addAction [
                "Open Command Tablet",
                { call FNC(openTablet); },
                [],
                1.5,
                false
            ];
        };
    };

    call _res;

    // Add for respawn too
    player addEventHandler ["Respawn", _res];

    // Add on laptop
    {
        _x addAction ["Open Command Tablet", {
            call FNC(openTablet);
        }, [], 1.5, false, true, "", "'PILOT' call YAINA_fnc_testTraits", 5];
        nil;
    } count AIR_DEFENCES_TERMINALS;

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
            ["B_Heli_Attack_01_dynamicLoadout_F",9000,60],
            ["B_Heli_Light_01_dynamicLoadout_F",4500,40],
            ["B_Heli_Light_01_F",1000,20],
            ["B_Heli_Transport_01_F",1000,30],
            ["B_Heli_Transport_03_unarmed_F",1000,25],
            ["B_Heli_Transport_03_F",1000,30],
            ["I_Heli_light_03_dynamicLoadout_F",4500,40],
            ["I_Heli_light_03_unarmed_F",1000,25],
            ["I_Heli_Transport_02_F",1000,25],
            ["O_Heli_Attack_02_dynamicLoadout_F",9000,60],
            ["O_Heli_Light_02_dynamicLoadout_F",4500,40],
            ["O_Heli_Light_02_unarmed_F",1000,20],
            ["O_Heli_Transport_04_bench_black_F",1000,20],
            ["O_Heli_Transport_04_covered_black_F",1000,20]
        ],
        [
            ["B_Plane_CAS_01_dynamicLoadout_F",12000,50],
            ["B_Plane_Fighter_01_F",9000,60],
            ["B_Plane_Fighter_01_Stealth_F",9000,60],
            ["B_T_VTOL_01_armed_F",6000,50],
            ["B_T_VTOL_01_infantry_F",1000,40],
            ["B_T_VTOL_01_vehicle_F",1000,40],
            ["I_Plane_Fighter_03_AA_F",3000,20],
            ["I_Plane_Fighter_03_dynamicLoadout_F",4500,20],
            ["I_Plane_Fighter_04_F",3000,25],
            ["O_Plane_CAS_02_dynamicLoadout_F",6000,40],
            ["O_Plane_Fighter_02_F",9000,55],
            ["O_Plane_Fighter_02_Stealth_F",9000,55],
            ["O_T_VTOL_02_infantry_dynamicLoadout_F",6000,55],
            ["O_T_VTOL_02_vehicle_dynamicLoadout_F",6000,55]
        ],
        [
            ["B_APC_Tracked_01_AA_F",4500,35],
            ["B_APC_Tracked_01_CRV_F",1000,30],
            ["B_APC_Wheeled_01_cannon_F",4500,30],
            ["B_G_Offroad_01_repair_F",500,15],
            ["B_LSV_01_unarmed_F",250,15],
            ["B_MBT_01_arty_F",6000,55],
            ["B_MBT_01_cannon_F",9000,45],
            ["B_MBT_01_mlrs_F",6000,60],
            ["B_MBT_01_TUSK_F",9000,45],
            ["B_MRAP_01_F",500,15],
            ["B_MRAP_01_gmg_F",1500,30],
            ["B_MRAP_01_hmg_F",1000,20],
            ["B_Quadbike_01_F",100,10],
            ["B_T_APC_Tracked_01_rcws_F",1500,30],
            ["B_T_LSV_01_armed_CTRG_F",1000,20],
            ["B_Truck_01_ammo_F",250,10],
            ["B_Truck_01_covered_F",250,10],
            ["B_Truck_01_fuel_F",250,10],
            ["B_Truck_01_medical_F",250,10],
            ["B_Truck_01_Repair_F",250,10],
            ["B_Truck_01_transport_F",250,10],
            ["I_MBT_03_cannon_F",9000,50],
            ["I_MRAP_03_F",500,15],
            ["I_MRAP_03_gmg_F",1500,30],
            ["I_MRAP_03_hmg_F",1000,20],
            ["O_MBT_02_cannon_F",9000,40],
            ["O_APC_Tracked_02_cannon_F", 6000, 55],
            ["O_T_LSV_02_armed_F",1000,20],
            ["O_T_LSV_02_unarmed_F",250,15],
            ["I_LT_01_AA_F", 3000, 35],
            ["I_LT_01_AT_F", 3000, 35],
            ["I_LT_01_scout_F", 1500, 25],
            ["I_LT_01_cannon_F", 4500, 45],
            ["B_AFV_Wheeled_01_cannon_F", 6000, 50],
            ["B_AFV_Wheeled_01_up_cannon_F", 7000, 60],
            ["O_MBT_04_cannon_F", 9000, 60],
            ["O_MBT_04_command_F", 10000, 75],
            ["B_LSV_01_AT_F", 1000, 20],
            ["O_LSV_02_AT_F", 1000, 20],
            ["B_G_Offroad_01_AT_F", 750, 20],
            ["I_C_Offroad_02_AT_F", 750, 20]
        ],
        [
            ["B_T_UAV_03_dynamicLoadout_F",4500,40],
            ["B_UAV_02_dynamicLoadout_F",4500,20],
            ["B_UAV_05_F",4500,30],
            ["B_UGV_01_rcws_F",4500,10]
        ]
    ];


    publicVariable QVAR(rewards);

    GVAR(orderRewardInProgress) = false;
    GVAR(orderRewardInProgressLocal) = false;
    publicVariable QVAR(orderRewardInProgress);
};
