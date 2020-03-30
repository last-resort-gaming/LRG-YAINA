/*
Function: YAINA_fnc_showTerrainObjects

Description:
	Make previously hidden terrain objects reappear, negating the effect of
    YAINA_fnc_hideTerrainObjects. Terrain objects supposed to reappear
    have to be passed as reference keys.

Parameters:
	_this - An array containing the keys of previous hiding operations which shall be negated

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if(!isServer) exitWith {
    _this remoteExecCall [QYFNC(showTerrainObjects), 2];
};

{
    private _idx = (YVAR(hiddenTerrainObjects) select 0) find _x;
    if !(_idx isEqualTo -1) then {
        {
            // an array of arrays
            {
                if !(isNull _x) then {
                    _x hideObjectGlobal false;
                    _x allowDamage true;
                };
                true;
            } count _x;
            true;
        } count ((YVAR(hiddenTerrainObjects) select 1) select _idx);

        (YVAR(hiddenTerrainObjects) select 0) deleteAt _idx;
        (YVAR(hiddenTerrainObjects) select 1) deleteAt _idx;
    };
    true;
} count _this; // array of keys

nil
