/*
	author: Martin
	description: none
	returns: nothing

	Inspierd by MacRae's chair script

    TODO: if a player sits, then takes off their BP we should restore it's original texture

*/

#include "defines.h"

params ["_chair"];

// Stop them falling over
_chair enableSimulation false;

if (hasInterface) then {
    _chair addAction ["Sit Down", {
        params ["_target", "_caller", "_id", "_args"];

        // Fix Vars + Save Backpack texture
        _target setVariable [QVAR(occupied), _caller, true];
        _caller setVariable [QVAR(current), _target];

        private _bp  = backpackContainer _caller;
        if !(isNull _bp) then {
            _bp hideObjectGlobal true;
        };

        // Play animation across the network, set our position to chair and insta-animate
        [_caller, "Crew"] remoteExec ["switchMove", 0];
        player switchMove "Crew";

        _caller setDir (getDir _target + 180);
        _caller setPosASL (AGLToASL (_target modelToWorld [0,-0.15,-0.8]));

        // Add the action to player for them to get up
        _caller addAction ["Stand Up", {
            params ["_target", "_caller", "_id", "_args"];

            // Remove Action From me
            _target removeAction _id;

            // Remove Occupied from chair + my ref
            (_target getVariable QVAR(current)) setVariable [QVAR(occupied), nil, true];
            _target setVariable [QVAR(current), nil];

            // Restore Backpack texture (if we have one)
            private _bp = backpackContainer _caller;
            if !(isNull _bp) then {
                _bp hideObjectGlobal false;
            };


            // Unset my Move so i can get up
            player switchMove "";

         }, [], 1.5, false, true, "", "!(isNil { _this getVariable 'YAINA_CHAIRS_current' })", 2];

    }, [], 1.5, false, true, "", "_o = _target getVariable 'YAINA_CHAIRS_occupied'; _c = _this getVariable 'YAINA_CHAIRS_current'; isNil '_c' && { isNil '_o' || { !(alive _o) } }", 2];
};