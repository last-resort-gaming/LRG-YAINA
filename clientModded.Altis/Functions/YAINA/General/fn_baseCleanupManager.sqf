/*
Function: YAINA_fnc_baseCleanupManager

Description:
	Handles initialization of the base cleanup scripts during the 
    postInit phase. Removes dead bodies, dropped stuff and clears
    the inventory of the arsenal boxes if no players are nearby.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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

            // Remove any empty groups, not technically base, but no point creating another cleanup
            { deleteGroup _x; true } count (allGroups select { count (units _x) isEqualTo 0; } );

            // Remove any inventory from arsenals where players arent within 5m as we don't want
            // weapons despawning from in front of them
            {
                clearWeaponCargoGlobal _x;
                clearMagazineCargoGlobal _x;
                clearItemCargoGlobal _x;
                clearBackpackCargoGlobal _x;
                nil
            } count (ARSENALS select { count ( position _x nearEntities ["CAManBase", 5] select { isPlayer _x }) isEqualTo 0 });

            nil
        } count BASE_PROTECTION_AREAS;
    };
}, 30, []] call CBA_fnc_addPerFrameHandler;
