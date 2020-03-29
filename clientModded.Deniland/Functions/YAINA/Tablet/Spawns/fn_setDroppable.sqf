/*
Function: YAINA_TABLET_fnc_setDroppable

Description:
	Set a crate to be droppable using sling loading system.

Parameters:
	_crate - The crate we want to set to a droppable vehicle

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_crate"];

[_crate, {
    params ["_crate", "_heli"];

    if ((position _crate) select 2 >= 50) then {

        _smoke1 = "SmokeShellGreen" createVehicle (position _crate);
        _smoke1 attachTo [_crate, [0,0,0.6]];

        _chemLight = "Chemlight_green" createVehicle (position _crate);
        _chemLight attachTo [_crate, [0,0.2,0.8]];

        _irGrenade = "B_IRStrobe" createVehicle (position _crate);
        _irGrenade attachTo [_crate, [0,-0.2,0.8]];

        // wait until we are 40m below chopper...
        [
            { !alive (_this select 1) or (_this select 0) distance (_this select 1) > 45 },
            {
                params ["_heli", "_crate"];

                if (alive _crate) then {
                    _chute1 = createVehicle ["B_parachute_02_F", [0,0,0], [], 0, 'FLY'];

                    _chute1 allowDamage false;
                    _chute1 disableCollisionWith _heli;

                    _chute1 setDir getDir _crate;
                    _chute1 setPos getPos _crate;

                    _crate attachTo [_chute1, [0,0,0]];

                    // When the crate gets to gound, clean up
                    [
                        { !alive (_this select 0) or (position (_this select 0)) select 2 < 1 },
                        {
                            private _crate = _this select 0;
                            detach _crate;
                            _chute setVelocity [0,0,0];
                            [ { deleteVehicle (_this select 0); }, [_this select 1], 4] call CBA_fnc_waitAndExecute;
                        },
                        [ _crate, _chute1 ]
                    ] call CBA_fnc_waitUntilAndExecute;
                };
            },
            [ _heli, _crate ]
        ] call CBA_fnc_waitUntilAndExecute;
    };
}] call YAINA_VEH_fnc_addRopeDetachHandler;