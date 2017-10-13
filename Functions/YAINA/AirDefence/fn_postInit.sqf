/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (isServer) then {

    GVAR(nextActive) = 0;
    GVAR(online) = false;

    // Lock and delete any crew in there
    {
        _x lock 2;
        _x allowDamage false;
        { deleteVehicle _x; } count crew _x;
        true;
    } count AIR_DEFENCES;

    // Set action on air Defence Terminals
    {
        _x addAction ["<t color='#ff1111'>Activate Air-Defense Network</t>",
        {
            _nextAD = call FNC(activateAirDefence);

            if (_nextAD isEqualTo 0) exitWith {};

            if (_nextAD isEqualTo -1) then {
                hint "Air Defence Network is already online";
            } else {
                hint format ["Air defence network will be available in %1", _nextAD call YFNC(getPrintableDuration)];
            };
        }];
        true;
    } count AIR_DEFENCE_TERMINALS;
};

