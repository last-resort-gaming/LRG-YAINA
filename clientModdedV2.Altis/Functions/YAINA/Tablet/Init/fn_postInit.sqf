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
			
			["B_Heli_Light_01_F",1000,15],
			["UK3CB_BAF_Merlin_HM2_18",1200,20],
			["UK3CB_BAF_Merlin_HC3_18",1250,20],
			["UK3CB_BAF_Merlin_HC4_18",1300,20],
			["UK3CB_BAF_Merlin_HC3_24",1350,25],
			["UK3CB_BAF_Merlin_HC4_24",1400,25],
			["UK3CB_BAF_Merlin_HC3_32",1450,30],
			["UK3CB_BAF_Merlin_HC4_32",1500,30],
            ["B_Heli_Transport_03_unarmed_F",1600,30],
			["UK3CB_BAF_Merlin_HC3_18_GPMG",1650,35],
			["UK3CB_BAF_Merlin_HC4_18_GPMG",1700,35],
            ["B_Heli_Transport_03_F",1750,35],
            ["UK3CB_BAF_Wildcat_AH1_TRN_8A",1800,35],
			["UK3CB_BAF_Wildcat_HMA2_TRN_8A",1850,35],
			["B_Heli_Transport_01_F",2000,35],
			["B_Heli_Light_01_dynamicLoadout_F",9000,35],			
			["UK3CB_BAF_Wildcat_AH1_CAS_6A",10000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_6B",10000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_6C",10000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_6D",10000,40],
			["UK3CB_BAF_Wildcat_AH1_HEL_6A",10000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_8A",11000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_8B",11000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_8C",11000,40],
			["UK3CB_BAF_Wildcat_AH1_CAS_8D",11000,40],
			["UK3CB_BAF_Wildcat_AH1_HEL_8A",11000,40],
			["UK3CB_BAF_Apache_AH1_AT",12000,50],
			["UK3CB_BAF_Apache_AH1_CAS",12000,50],
			["UK3CB_BAF_Apache_AH1",12000,50],
			["UK3CB_BAF_Apache_AH1_JS",12000,50]
        ],
        [
            ["B_T_VTOL_01_infantry_F",2000,40],
            ["B_T_VTOL_01_vehicle_F",2000,40],
            ["I_Plane_Fighter_04_F",3000,25],
            ["I_Plane_Fighter_03_AA_F",3000,20],            
            ["I_Plane_Fighter_03_dynamicLoadout_F",4500,20],
            ["O_Plane_CAS_02_dynamicLoadout_F",6000,40],            
            ["O_T_VTOL_02_infantry_dynamicLoadout_F",6000,55],
            ["O_T_VTOL_02_vehicle_dynamicLoadout_F",6000,55],
            ["B_T_VTOL_01_armed_F",6000,50],
            ["O_Plane_Fighter_02_F",9000,55],
            ["O_Plane_Fighter_02_Stealth_F",9000,55],
            ["B_Plane_Fighter_01_F",9000,60],
            ["B_Plane_Fighter_01_Stealth_F",9000,60],
            ["B_Plane_CAS_01_dynamicLoadout_F",12000,50]                                   
        ],
        [
			["UK3CB_BAF_LandRover_Soft_Arctic_A",500,30],
			["UK3CB_BAF_LandRover_Soft_Green_A",500,30],
			["UK3CB_BAF_LandRover_Soft_Green_B",500,30],
			["UK3CB_BAF_LandRover_Soft_MERT_A",500,30],
			["UK3CB_BAF_LandRover_Soft_RAF_A",500,30],
			["UK3CB_BAF_LandRover_Soft_Sand_A",500,30],
			["UK3CB_BAF_LandRover_Soft_UN_A",500,30],
			["UK3CB_BAF_LandRover_Hard_Arctic_A",600,30],
			["UK3CB_BAF_LandRover_Hard_Green_A",600,30],
			["UK3CB_BAF_LandRover_Hard_Green_B",600,30],
			["UK3CB_BAF_LandRover_Hard_MERT_A",600,30],
			["UK3CB_BAF_LandRover_Hard_Sand_A",600,30],
			["UK3CB_BAF_LandRover_Hard_UN_A",600,30],
			["UK3CB_BAF_LandRover_Snatch_Green_A",700,30],
			["UK3CB_BAF_LandRover_Snatch_Police_A",700,30],
			["UK3CB_BAF_LandRover_Snatch_Sand_A",700,30],
			["UK3CB_BAF_LandRover_Amb_Green_A",800,30],
			["UK3CB_BAF_LandRover_Amb_Sand_A",800,30],
			["UK3CB_BAF_LandRover_Amb_UN_A",800,30],
			["UK3CB_BAF_MAN_HX60_Cargo_Green_A",800,30],
			["UK3CB_BAF_MAN_HX60_Cargo_Sand_A",800,30],
			["UK3CB_BAF_MAN_HX60_Cargo_Green_B",800,30],
			["UK3CB_BAF_MAN_HX60_Cargo_Sand_B",800,30],
			["UK3CB_BAF_MAN_HX60_Fuel_Green",850,30],
			["UK3CB_BAF_MAN_HX60_Fuel_Sand",850,30],
			["UK3CB_BAF_MAN_HX60_Repair_Green",850,30],
			["UK3CB_BAF_MAN_HX60_Repair_Sand",850,30],
			["UK3CB_BAF_MAN_HX60_Transport_Green",850,30],
			["UK3CB_BAF_MAN_HX60_Transport_Sand",850,30],
			["UK3CB_BAF_MAN_HX58_Cargo_Green_A",900,30],
			["UK3CB_BAF_MAN_HX58_Cargo_Sand_A",900,30],
			["UK3CB_BAF_MAN_HX58_Cargo_Green_B",900,30],
			["UK3CB_BAF_MAN_HX58_Cargo_Sand_B",900,30],
			["UK3CB_BAF_MAN_HX58_Fuel_Green",950,30],
			["UK3CB_BAF_MAN_HX58_Fuel_Sand",950,30],
			["UK3CB_BAF_MAN_HX58_Repair_Green",950,30],
			["UK3CB_BAF_MAN_HX58_Repair_Sand",950,30],
			["UK3CB_BAF_MAN_HX58_Transport_Green",950,30],
			["UK3CB_BAF_MAN_HX58_Transport_Sand",950,30],
			["UK3CB_BAF_Jackal2_L111A1_D2",1000,30],
			["UK3CB_BAF_Jackal2_L111A1_D",1000,30],
			["UK3CB_BAF_Jackal2_L111A1_G",1000,30],
			["UK3CB_BAF_Jackal2_L111A1_W",1000,30],
			["UK3CB_BAF_LandRover_WMIK_GPMG_Green_A",1000,30],
			["UK3CB_BAF_LandRover_WMIK_GPMG_Green_B",1000,30],
			["UK3CB_BAF_LandRover_WMIK_GPMG_Sand_A",1000,30],
			["UK3CB_BAF_LandRover_WMIK_HMG_Green_A",1050,30],
			["UK3CB_BAF_LandRover_WMIK_HMG_Green_B",1050,30],
			["UK3CB_BAF_LandRover_WMIK_HMG_Sand_A",1050,30],
			["UK3CB_BAF_Coyote_Logistics_L111A1_D2",1200,30],
			["UK3CB_BAF_Coyote_Logistics_L111A1_D",1200,30],
			["UK3CB_BAF_Coyote_Logistics_L111A1_G",1200,30],
			["UK3CB_BAF_Coyote_Logistics_L111A1_W",1200,30],
			["UK3CB_BAF_Coyote_Passenger_L111A1_D2",1200,30],
			["UK3CB_BAF_Coyote_Passenger_L111A1_D",1200,30],
			["UK3CB_BAF_Coyote_Passenger_L111A1_G",1200,30],
			["UK3CB_BAF_Coyote_Passenger_L111A1_W",1200,30],
			["UK3CB_BAF_Husky_Logistics_GPMG_Green",1300,30],
			["UK3CB_BAF_Husky_Logistics_GPMG_Sand",1300,30],
			["UK3CB_BAF_Husky_Passenger_GPMG_Green",1300,30],
			["UK3CB_BAF_Husky_Passenger_GPMG_Sand",1300,30],            
			["UK3CB_BAF_Husky_Logistics_HMG_Green",1350,30],
			["UK3CB_BAF_Husky_Logistics_HMG_Sand",1350,30],
			["UK3CB_BAF_Husky_Passenger_HMG_Green",1350,30],
			["UK3CB_BAF_Husky_Passenger_HMG_Sand",1350,30],            
			["UK3CB_BAF_LandRover_WMIK_Milan_Green_A",1400,30],
			["UK3CB_BAF_LandRover_WMIK_Milan_Green_B",1400,30],
			["UK3CB_BAF_LandRover_WMIK_Milan_Sand_A",1400,30],
			["UK3CB_BAF_Panther_GPMG_Green_A",1450,30],
			["UK3CB_BAF_Panther_GPMG_Sand_A",1450,30],
			["UK3CB_BAF_FV432_Mk3_GPMG_Green",1500,30],
			["UK3CB_BAF_FV432_Mk3_GPMG_Sand",1500,30],
			["UK3CB_BAF_FV432_Mk3_RWS_Green",1550,30],
			["UK3CB_BAF_FV432_Mk3_RWS_Sand",1550,30],
			["UK3CB_BAF_Warrior_A3_W",2000,30],
			["UK3CB_BAF_Warrior_A3_D",2000,30]
        ],
        [
            ["UK3CB_BAF_LandRover_Panama_Sand_A",2000,20],
            ["UK3CB_BAF_LandRover_Panama_Green_A",2000,20],
            ["B_UGV_01_rcws_F",3000,20],
            ["B_UAV_05_F",4500,40],
            ["UK3CB_BAF_MQ9_Reaper",5000,40]

        ]
    ];


    publicVariable QVAR(rewards);

    GVAR(orderRewardInProgress) = false;
    GVAR(orderRewardInProgressLocal) = false;
    publicVariable QVAR(orderRewardInProgress);
};
