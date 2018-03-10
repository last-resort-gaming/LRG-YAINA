/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

if(!isServer) exitWith {};

[{
    for "_i" from count(GVAR(respawnList)) to 0 step -1 do {
        (GVAR(respawnList) select _i) params ["_veh", "_vehType", "_pos", "_dir", "_respawnArea", "_tex", "_coPilotEnabled", "_locked", "_loadout", "_animationInfo", "_pylonLoadout", "_respawnTime", "_abandonDistance", "_hasKeys", "_persistVars", "_initCode", "_initCodeArgs", "_respawnCode", "_respawnCodeArgs"];

        // If the vehicle is not alive / null then we remove from the respawn
        // list and schedule a delete it in 30 seconds just in case it
        // doesn't get removed when not alive

        _respawn = false;
        if (!alive _veh || isNull _veh) then {
            diag_log format["RESPAWNING: %1 (%2), not alive", _veh, typeOf _veh];
            _respawn = true;
        } else {

            // E.g. UAVs don't have a distance.
            if (!(_abandonDistance isEqualTo 0) && { yaina_vehicle_abandonment } ) then {

                // If it's less than 5m from start pos, just bail
                if (_veh distance2D _pos < 5) exitWith {};

                // If it's within a BASE area, just bail
                if !(call { {_veh inArea _x} count BASE_PROTECTION_AREAS; } isEqualTo 0) exitWith {};

                // If the vehicle is owned, then the abandonDistance is doubled;
                _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
                if(!isNil "_owner") then {
                    _abandonDistance =  _abandonDistance * 2;
                };

                // If players near, we can bail out
                if (call {
                    {
                        if ((_veh distance2D _x) < _abandonDistance) exitWith {true};
                        false;
                    } forEach allPlayers;
                }) exitWith {};

                // Log it
                diag_log format["WOULD RESPAWN: %1, abandon distance: %2, alive crew: %3", _veh, _abandonDistance, crew _veh select { alive _x }];

                // Ensure no alive crew players in it
                if !(({alive _x } count (crew _veh)) isEqualTo 0) exitWith {};

                diag_log format["RESPAWNING: %1 (%2), abandon distance: %3, alive crew: %4", _veh, typeOf _veh, _abandonDistance, crew _veh select { alive _x }];

                // Else we are abandoned, delete this and respawn
                deleteVehicle _veh;

                _respawn = true;
            };

            // If it's a land base vehicle, and it's underwater, then may as well go ahead and respawn
            if (underwater _veh && !(_vehType isKindOf "Submarine")) then {
                diag_log format["WOULD RESPAWN: %1, underwater, crew: %2", _veh, crew _veh select { alive _x }];
                //deleteVehicle _veh;
                //_respawn = true;
            };
        };

        // Then we just trigger a respawn in _respawnTime
        if(_respawn) then {

            GVAR(respawnList) deleteAt _i;

            // Run our respawn code
            [_veh, _respawnCodeArgs] call _respawnCode;

            // If we are not to be respawning, we're done here, so delete the vehicle in 2 mintes and bail
            [_veh, 120] call YFNC(deleteVehicleIn);

            if(_respawnTime isEqualTo -1) exitWith {};

            [{
                params ["_args", "_pfhID"];
                _args params ["_respawnAfter", "_vehType", "_pos", "_dir", "_respawnArea", "_tex", "_coPilotEnabled", "_locked", "_loadout", "_animationInfo", "_pylonLoadout", "_respawnTime", "_abandonDistance", "_hasKeys", "_persistVars", "_initCode", "_initCodeArgs"];

                // Make sure we've passed the respawn time
                if (LTIME < _respawnAfter) exitWith {};

                // Wait for area to be empty before proceeding
                if !(count (entities "AllVehicles" select { _x inArea _respawnArea }) isEqualTo 0) exitWith {};

                // And stop this PFH, and respawn
                [_pfhID] call CBAP_fnc_removePerFrameHandler;

                _nv = createVehicle [_vehType, [0,0,0], [], 0, "NONE"];

                // We disable simulation right now due what seems to be a race between the
                // vehicle touching the ground under water and dying prior to the setDir a
                // few lines away... This in turn causes it to effectively never respawn
                _nv enableSimulation false;

                // reset textures
                {
                    _nv setObjectTextureGlobal [_forEachIndex, _x];
                } forEach _tex;

                // reset animations
                { _nv animate [_x select 0, _x select 1, true]; } forEach _animationInfo;

                // Then move to intended location
                _nv setDir _dir;
                _nv setPosATL _pos;

                // Re-enable simulation
                _nv enableSimulation true;

                // restore copilot action
                _nv enableCopilot _coPilotEnabled;

                // restore lcoked state
                _nv lock _locked;

                // Then Remove the weapons, and works on UAVs nicely so you don't, after removing the
                // pylons, get the weapon showing up with 0 ammo
                { _nv removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon"); } forEach getPylonMagazines _nv;

                // Clear any remaining pylon loadouts
                { _nv setPylonLoadOut [_forEachIndex + 1, ""]; } forEach getPylonMagazines _nv;

                // Reload the same pylons as before
                if (allTurrets _nv isEqualTo []) then {
                    {
                        _nv setPylonLoadout [_forEachIndex + 1, _x, true];
                    } forEach _pylonLoadout;
                } else {
                    {
                        _nv setPylonLoadout [_forEachIndex + 1, _x, true, [0]];
                    } forEach _pylonLoadout;
                };

                if ([_nv] call YFNC(isUAV)) then {

                    // And lastly add the crew
                    createVehicleCrew _nv;

                    ["UAVSpawn", _nv] call CBAP_fnc_globalEvent;
                };

                // restore provided persistant vars, and default persistants
                { _x set [2,true]; _nv setVariable _x; } forEach _persistVars;

                // handle inventories
                clearWeaponCargoGlobal _nv;
                clearMagazineCargoGlobal _nv;
                clearItemCargoGlobal _nv;
                clearBackpackCargoGlobal _nv;

                for "_l" from 0 to (count _loadout) do {

                    _cargoItems  = (_loadout select _l) select 0;
                    _cargoCounts = (_loadout select _l) select 1;

                    if (_l isEqualTo 0) then {
                        for "_x" from 0 to ((count _cargoItems) - 1) do {
                            _nv addBackpackCargoGlobal [_cargoItems select _x, _cargoCounts select _x];
                        };
                    } else {
                        for "_x" from 0 to ((count _cargoItems) - 1) do {
                            _nv addItemCargoGlobal [_cargoItems select _x, _cargoCounts select _x];
                        };
                    };
                };

                // Run custom init script
                [_nv, _initCodeArgs] call _initCode;

                // Re-Init Vehicle
                [_nv, _hasKeys, _respawnTime, _abandonDistance, _persistVars apply { _x select 0; }, _initCode, _initCodeArgs] call FNC(initVehicle);

                true;

            }, 10, [LTIME + _respawnTime, _vehType, _pos, _dir, _respawnArea, _tex, _coPilotEnabled, _locked, _loadout, _animationInfo, _pylonLoadout, _respawnTime, _abandonDistance, _hasKeys, _persistVars, _initCode, _initCodeArgs]] call CBAP_fnc_addPerFrameHandler;
        };

    };
}, 10, []] call CBAP_fnc_addPerFrameHandler;