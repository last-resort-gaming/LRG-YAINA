/*
Function: YAINA_fnc_preInit

Description:
	General preInit handler for YAINA. Initializes some global variables, mainly
    concerned with Zeus and the admin system. Loads the reward points from the database,
    set-up addActions for players using the Connected EH and set-up player
    disconnect-handling.

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

if !(isServer) exitWith {};

YVAR(zeuslist) = [[],[]]; // Temporary Zeus Users
YVAR(ownerIDs) = [[],[]]; // [[1,2,3,...], [[uid, profileName, _owner ID]]
YVAR(addActionMPList) = [];

// Load reward Points from database
YVAR(rewardPoints) = ["credits", "balance", 0, 0] call YFNC(getDBKey);
publicVariable QYVAR(rewardPoints);

addMissionEventHandler["PlayerConnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    (YVAR(ownerIDs) select 0) pushBack _owner;
    (YVAR(ownerIDs) select 1) pushBack [_id, _uid, _name];

    // This only runs on the server, but if we are a server and player, we don't want
    // to do this, as it results in duplicate items

    if !(_owner isEqualTo clientOwner) then {
        for "_i" from ((count YVAR(addActionMPList))-1) to 0 step -1 do {
            _obj = (YVAR(addActionMPList) select _i) select 0;
            if ( isNull ((YVAR(addActionMPList) select _i) select 0) ) then {
                YVAR(addActionMPList) deleteAt _i;
            } else {
                [YVAR(addActionMPList) select _i, {
                    _obj  = _this deleteAt 0;
                    _code = _this deleteAt 0;
                    _evt  = _obj addAction _this;
                    [_obj, _evt] call _code;
                }] remoteExec ["call", _owner];
            };
        };
    };
}];


addMissionEventHandler["PlayerDisconnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    _idx = (YVAR(ownerIDs) select 0) find _owner;
    if !(_idx isEqualTo -1) then {
        (YVAR(ownerIDs) select 0) deleteAt _idx;
        (YVAR(ownerIDs) select 1) deleteAt _idx;
    };

}];
