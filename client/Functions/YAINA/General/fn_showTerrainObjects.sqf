/*
	author: Martin
	description: none
	returns: nothing
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
} count _this; // array of keys

nil
