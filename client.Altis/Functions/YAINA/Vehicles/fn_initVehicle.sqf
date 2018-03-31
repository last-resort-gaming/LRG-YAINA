/*
	author: MartinCo
	description: none
	returns: nothing
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

// Mark as complete straight away
_veh setVariable [QVAR(init), true, true];

if (_initOnInit) then {
    diag_log format["Running init on %1", _veh];
    [_veh, _initCodeArgs] call _initCode;
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

    // Setup the ejection if it has keys and the driver isn't in the group
    [_veh, {
        params ["_unit", "_pos", "_veh", "_turret"];

        [{
            params ["_args", "_pfhID"];
            _args params ["_veh"];

            // We delete the pfh if we are no longer the driver
            if !(driver _veh isEqualTo player) then {
                [_pfhID] call CBAP_fnc_removePerFrameHandler;
            };

            // Otherwise, return if no owner set
            _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
            if (isNil "_owner") exitWith {};

            // And lastly, if we aren't in the group, we start a chain of events
            // First we empty the fule, when we've come to a stop, eject the driver
            // and lastly, return the fuel

            if !((group _owner) isEqualTo (group player)) then {
                // So we can remove this PFH to stop it firing
                [_pfhID] call CBAP_fnc_removePerFrameHandler;

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

        }, 1, [_veh]] call CBAP_fnc_addPerFrameHandler;

    }] call FNC(addGetInHandler);
};

// If it's a ground vehicle we allow engineers to flip if it falls over
if (typeOf _veh isKindOf "LandVehicle") then {

    _checkCode = "'ENG' call YAINA_fnc_testTraits &&
                 { ( { alive _x } count (crew _target) ) isEqualTo 0 } &&
                 { (vectorUp _target) select 2 < 0.5 }";

    [_veh, "<t color='#ff1111'>Flip Vehicle</t>", {
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


true;