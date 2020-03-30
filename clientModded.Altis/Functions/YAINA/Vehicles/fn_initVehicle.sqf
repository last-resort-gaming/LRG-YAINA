/*
Function: YAINA_VEH_fnc_initVehicle

Description:
	Handles initialization of vehicles with a lot of parameters.
    These are for example respawning, init code, keys setup and 
    automatic removal if abandoned.

Parameters:
	_veh - The vehicle we want to initialize
    _hasKeys - If the vehicle has keys available for taking
    _respawnTime - The time it takes for the vehicle to respawn, -1 to disable respawning
    _abandonDistance - The distance of the vehicle to any player to mark it as abandoned
    _persistVars - Variables that persist across respawns
    _initCode - Code run on initialization of the vehicle (also on respawn)
    _initCodeArgs - Arguments for the init code
    _initOnInit - Run init code during first init, too?
    _respawnCode - Code run on vehicle respawn
    _respawnCodeArgs - Arguments for the respawn code

Return Values:
	true, if initialization succesful, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if(!isServer) exitWith {
    _this remoteExec[QFNC(initVehicle), 2]
};

params ["_veh",
    ["_hasKeys", true],
    ["_respawnTime", -1],
    ["_abandonDistance", 3000],
    ["_persistVars", []],
    ["_initCode", {}],
    ["_initCodeArgs", []],
    ["_initOnInit", false],
    ["_respawnCode", {}],
    ["_respawnCodeArgs", []]
];

// Dont init more than once
if (_veh getVariable [QVAR(init), false]) exitWith {};

private _class = typeOf _veh;
private _checkCode = "";

// Mark as complete straight away
_veh setVariable [QVAR(init), true, true];

if (_initOnInit) then {
    [format["Running init on %1", _veh]] call YFNC(log);
    [_veh, _initCodeArgs] call _initCode;
};


// Ensure all vehicles have sensor system enabled
if !(vehicleReportOwnPosition _veh) then {
 _veh setVehicleReportRemoteTargets true;
 _veh setVehicleReceiveRemoteTargets true;
 _veh setVehicleReportOwnPosition true;
};

if (_hasKeys) then {

    _veh setVariable [QVAR(hasKeys), true, true];

    // If it's killed/deleted we need to remove markers
    _veh addEventHandler ["killed", {
        params ["_veh", "_killer"];
        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if (!isNil "_owner") then { [_owner, _veh, "remove"] call FNC(updateOwnership); };
    }];

    _veh addEventHandler ["Deleted", {
        params ["_veh"];
        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if (!isNil "_owner") then { [_owner, _veh, "remove"] call FNC(updateOwnership); };
    }];

    // HQ Lock/Unlock Action
    // Store the default locked state, for when HQ disconnects
    _veh setVariable [QVAR(defaultLock), locked _veh, true];
    [_veh, {
        params ["_obj", "_id"];
        _obj setUserActionText [_id, ["Unlock Vehicle", "Lock Vehicle"] select (locked _obj isEqualTo 0)];
        _obj setVariable [QVAR(lockActionID), _id];
    }, "Unlock Vehicle", {
        params ["_target", "_caller", "_id", "_arguments"];

        _unlocked  = locked _target isEqualTo 0;
        _newState  = [0, 2] select _unlocked;

        // lock has a local effect
        [[_target, _newState], {
            _this remoteExec ["lock", owner (_this select 0)];
        }] remoteExec ["call", 2];

        // Broadcast VehicleLock event to update the action across players
        ["VehicleLock", [player, _target, _newState]] call CBA_fnc_globalEvent;

    }, [], 1.5, false, true, "", "['HQ', 'veh-unlock'] call YAINA_fnc_testTraits && { ( { alive _x } count (crew _target) ) isEqualTo 0 }", 10, false] call YFNC(addActionMP);

    // Setup the ejection if it has keys and the driver isn't in the group
    [_veh, {
        params ["_unit", "_pos", "_veh", "_turret"];

        [{
            params ["_args", "_pfhID"];
            _args params ["_veh"];

            // We delete the pfh if we are no longer the driver
            if !(driver _veh isEqualTo player) then {
                [_pfhID] call CBA_fnc_removePerFrameHandler;
            };

            // Otherwise, return if no owner set
            _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
            if (isNil "_owner") exitWith {};

            // And lastly, if we aren't in the group, we start a chain of events
            // First we empty the fule, when we've come to a stop, eject the driver
            // and lastly, return the fuel

            if !((group _owner) isEqualTo (group player)) then {
                // So we can remove this PFH to stop it firing
                [_pfhID] call CBA_fnc_removePerFrameHandler;

                0 = [] spawn {
                    _veh = vehicle player;
                    private _fuel = fuel _veh;
                    _veh setFuel 0;

                    // always make sure this can be passed and not keep the script
                    // around forever
                    waitUntil { not alive _veh || { speed _veh < 10 } };

                    if (alive _veh) then {
                        // Set fuel before moveOut due to needing to be executed locally
                        _veh setFuel _fuel;
                        moveOut player;

                        // And we put a little message to say you're no longer in owners group
                        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
                        _msg   = "You are no longer in the owners group";

                        if !(isNil "_owner") then {
                            _msg = format ["You are no longer in the %1's group", name _owner];
                        };

                        _msg call YFNC(hintC);
                    };
                };
            };

        }, 1, [_veh]] call CBA_fnc_addPerFrameHandler;

    }] call FNC(addGetInHandler);
};

// If it's a ground vehicle we allow engineers to flip if it falls over
if (_class isKindOf "LandVehicle") then {

    _checkCode = "'ENG' call YAINA_fnc_testTraits &&
                 { ( { alive _x } count (crew _target) ) isEqualTo 0 } &&
                 { (vectorUp _target) select 2 < 0.5 }";

    [_veh, {}, "<t color='#ff1111'>Flip Vehicle</t>", {
        params ["_target", "_caller", "_id", "_arguments"];
        // Fire it back to server
        if (local _target) then {
            [_target] call FNC(flip);
        } else {
            // Ask the server who will forward it to right place
            [_target] remoteExec [QFNC(flip), 2];
        };
    }, [], 1.5, false, true, "", _checkCode, 10, false] call YFNC(addActionMP);
};

// If it's an air asset with transport slots, then add our paradrop action
if (_class isKindOf "Air" && { !(getNumber (configFile >> "CfgVehicles" >> _class >> "transportSoldier") isEqualTo 0) } ) then {


    // Add a get in handler for the driver to control the paradrop
    [_veh, {
        params ["_unit", "_pos", "_veh", "_turret"];


        if (driver _veh isEqualTo player) then {

            // Do we have an action already ?
            _action = _veh getVariable QVAR(paraAct);
            if (!isNil "_action") then { _veh removeAction _action; };

            // Reset Drop Var
            _veh setVariable [QVAR(paraEnable), false, true];

            // Add action
            _action = _veh addAction ["Enable Paradrop", {
                params ["_target", "_caller", "_id", "_arguments"];

                _next = !(_target getVariable QVAR(paraEnable));
                _target setVariable [QVAR(paraEnable), _next, true];

                _target setUserActionText [_id,
                    ["Enable Paradrop", "Disable Paradrop"] select _next
                ];

            }, [], 3, false, true];

            _veh setVariable [QVAR(paraAct), _action];

        };
    }] call FNC(addGetInHandler);

    // Only allow, if it's green lit
    // Or if we've lost ATRQ / Main Rot
    _checkCode = call {
        // Helicopter ?
        if (_class isKindOf "Helicopter") exitWith {
            "!(driver _target isEqualTo player)
              && { getPosATL _target select 2 > 20 }
              && {
                (
                  _target getVariable ['YAINA_VEH_paraEnable', false] isEqualTo true
                  || { _target getHitPointDamage 'HitHRotor' >= 0.9 }
                  || { _target getHitPointDamage 'HitVRotor' >= 0.9 }
                )
              }"
        };

        "!(driver _target isEqualTo player)
            && { getPosATL _target select 2 > 20 }
            && { _target getVariable ['YAINA_VEH_paraEnable', false] isEqualTo true }"
    };

    [_veh, {}, "<t color='#ff1111'>Paradrop</t>",
        YAINA_MM_fnc_openChute,
    [], 100, false, true, "", _checkCode, 10, false] call YFNC(addActionMP);

};


// Setup the loadout
_loadout =  [
    getBackpackCargo _veh,
    getWeaponCargo _veh,
    getMagazineCargo _veh,
    getItemCargo _veh
];

// Save any wing fold state
_animationInfo = [];
if(_veh isKindOf "Plane") then {
    _wingFoldAnimationsList = [(configFile >> "CfgVehicles" >> typeOf _veh  >> "AircraftAutomatedSystems"), "wingFoldAnimations", []] call BIS_fnc_returnConfigEntry;
    { _animationInfo pushBack [_x, _veh animationPhase _x]; } forEach _wingFoldAnimationsList;
};

// Else push back any other element from the animationList
private _n = -1;
{
  _animationInfo pushBack [_x, _veh animationPhase _x];
  nil;
} count (getArray (configFile >> "CfgVehicles" >> typeOf _veh >> "animationList") select { _n = _n+1; _n % 2 isEqualTo 0 });


// Save any pylon weapon loadouts
_pylonLoadout = getPylonMagazines _veh;

// Add default persist vars
_persistVars pushBackUnique QVAR(Drivers);
_persistVars pushBackUnique QVAR(DriversMessage);
_persistVars pushBackUnique QVAR(getIn);

// Save persist vars
_persistVarsSave = _persistVars apply { [_x, _veh getVariable [_x, nil]] };

// Build respawn area
boundingBoxReal _veh params ["_p1", "_p2"];
_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
_maxLength = abs ((_p2 select 1) - (_p1 select 1));
_maxHeight = abs ((_p2 select 2) - (_p1 select 2));

// And just push back to the respawn list
GVAR(respawnList) pushBack [
    _veh,
    typeOf _veh,
    getPosATL _veh,
    getDir _veh,
    [_veh modelToWorld [0,0,0], _maxWidth, _maxLength, getDir _veh, true, _maxHeight],
    getObjectTextures _veh,
    isCopilotEnabled _veh,
    locked _veh,
    _loadout,
    _animationInfo,
    _pylonLoadout,
    _respawnTime,
    _abandonDistance,
    _hasKeys,
    _persistVarsSave,
    _initCode,
    _initCodeArgs,
    _respawnCode,
    _respawnCodeArgs
];

// Setup Rope detach handlers on Helicopters
if (_veh isKindOf "Helicopter" && !(_veh isKindOf "UAV")) then {
    [_veh] call FNC(setupRopeDetachHandler);
};

// And we always ensure it's added to zeus
[[_veh]] call YFNC(addEditableObjects);

// The very last thing we do, is run the getIn handler for any current crew in the vehicle, this lets folks
// take keys etc. if the vehicle was initialized when there were players in it (such as commandeering an
// asset from an objective
// params ["_unit", "_pos", "_veh", "_turret"];
{
    _x params ["_unit", "_pos", "_cargoIndex", "_turretPath", "_personTurret"];
    if (isPlayer _unit) then {
        [_unit, _pos, _veh, _turretPath] remoteExec [QFNC(getInMan), _unit];
    };
    nil;
} count (fullCrew _veh);

_sel2 = selectRandom [1,2];
_sel3 = selectRandom [1,2,3];
_sel4 = selectRandom [1,2,3,4];

//=========Mohawk

if (typeOf _veh == "I_Heli_Transport_02_F") then {

	_veh setObjectTextureGlobal [1,'z\LRG Fundamentals\Addons\Media\images\Textures\Merlin0.paa'];
	_veh setObjectTextureGlobal [0,'z\LRG Fundamentals\Addons\Media\images\Textures\Merlin1.paa'];
	_veh setObjectTextureGlobal [2,'z\LRG Fundamentals\Addons\Media\images\Textures\Merlin2.paa'];
	
	};	
//=========Ghosthawk

if (typeOf _veh == "B_Heli_Transport_01_F") then {

switch ( _sel4 ) do {
	
	case 1 : {

	_veh setObjectTextureGlobal [0,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext01_BLUFOR_CO.paa'];
	_veh setObjectTextureGlobal [1,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext02_BLUFOR_CO.paa'];

	};
	
	case 2 : {
	
		_veh setObjectTextureGlobal [0,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext01_CO.paa'];
		_veh setObjectTextureGlobal [1,'A3\Air_F_Beta\Heli_Transport_01\Data\Heli_Transport_01_ext02_CO.paa'];
		
		};
	
	case 3 : {
	
		_veh setObjectTextureGlobal [0,'A3\Air_F_Exp\Heli_Transport_01\Data\Heli_Transport_01_ext01_tropic_CO.paa'];
		_veh setObjectTextureGlobal [1,'A3\Air_F_Exp\Heli_Transport_01\Data\Heli_Transport_01_ext02_tropic_CO.paa'];
		
		};
		
	case 4 : {
	
		_veh setObjectTextureGlobal [0,'A3\Air_F_Exp\Heli_Transport_01\Data\Heli_Transport_01_ext01_sand_CO.paa'];
		_veh setObjectTextureGlobal [1,'A3\Air_F_Exp\Heli_Transport_01\Data\Heli_Transport_01_ext02_sand_CO.paa'];
		
		};
	};
};

//=========Huron

if (typeOf _veh == "B_Heli_Transport_03_F") then {

switch ( _sel3 ) do {
	
	case 1 : {

	_veh setObjectTextureGlobal [0,'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext01_co.paa'];
	_veh setObjectTextureGlobal [1,'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext02_co.paa'];

	};
	
	case 2 : {

	_veh setObjectTextureGlobal [0,'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext01_co.paa'];
	_veh setObjectTextureGlobal [1,'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext02_co.paa'];

	};
	
	case 3 : {
	
	_veh setObjectTextureGlobal [0,'A3\Air_F_Heli\Heli_Transport_03\Data\Heli_Transport_03_ext01_black_CO.paa'];
	_veh setObjectTextureGlobal [1,'a3\air_f_heli\heli_transport_03\data\heli_transport_03_ext02_black_co.paa'];
		
		};
	
	};
};

//=========LittleBird

if (typeOf _veh == "B_Heli_Light_01_F") then {

switch ( _sel2 ) do {
	
	case 1 : {

	_veh setObjectTextureGlobal [0,'A3\Air_F\Heli_Light_01\Data\Heli_Light_01_ext_Blufor_CO.paa'];

	};
	
	case 2 : {

	_veh setObjectTextureGlobal [0, "\a3\air_f\Heli_Light_01\Data\heli_light_01_ext_ion_co.paa"]; 

		};
	
	};
};

true;