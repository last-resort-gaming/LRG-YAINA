/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if(!isServer) exitWith {};

[{
     [] spawn {
        {
            _mrk = _x;
            _cp = getMarkerPos _mrk;
            _sz = getMarkerSize _mrk;
            _sz = (_sz select 0) max (_sz select 1);

            // Delete any dead bodies
            {
                deleteVehicle _x;
                nil
            } count (entities [["CAManBase"], [], true, false] select { _x inArea _mrk && { !alive _x } });

            // Remove Dropped bags etc, only clear these if no players within 5 meters
            {
                _t = _x;
                { deleteVehicle _x; true } count (_cp nearObjects [_t, _sz] select { count ( position _x nearEntities ["CAManBase", 5] select { isPlayer _x }) isEqualTo 0 } );
                true
            } count ["GroundWeaponHolder"];

            nil
        } count BASE_PROTECTION_AREAS;
    };
}, 30, []] call CBAP_fnc_addPerFrameHandler;
