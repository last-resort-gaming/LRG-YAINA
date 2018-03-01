/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if !(isServer) exitWith {};

// Bring in admins from DB
call YFNC(loadDB);

YVAR(ownerIDs) = [[],[]]; // [[1,2,3,...], [[uid, profileName, _owner ID]]
YVAR(addActionMPList) = [];

// Load reward Points
YVAR(rewardPoints) = profileNamespace getVariable QYVAR(rewardPoints);
if (isNil QYVAR(rewardPoints)) then {
    YVAR(rewardPoints) = 0;
};
publicVariable QYVAR(rewardPoints);

addMissionEventHandler["PlayerConnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    // Are they an admin ?
    _adminLevel = [_uid] call YFNC(getAdminLevelFromGUID);

    (YVAR(ownerIDs) select 0) pushBack _owner;
    (YVAR(ownerIDs) select 1) pushBack [_id, _uid, _name, _adminLevel];

    for "_i" from ((count YVAR(addActionMPList))-1) to 0 step -1 do {
        _obj = (YVAR(addActionMPList) select _i) select 0;
        if ( isNull ((YVAR(addActionMPList) select _i) select 0) ) then {
            YVAR(addActionMPList) deleteAt _i;
        } else {
            [YVAR(addActionMPList) select _i, {
                _obj = _this deleteAt 0;
                _obj addAction _this;
            }] remoteExec ["call", _owner];
        };
    };

}];


addMissionEventHandler["PlayerDisconnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    private _idx = (YVAR(adminsLogged) select 0) find _uid;
    if !(_idx isEqualTo -1) then {
        (YVAR(adminsLogged) select 0) deleteAt _idx;
        (YVAR(adminsLogged) select 1) deleteAt _idx;
    };

    _idx = (YVAR(ownerIDs) select 0) find _owner;
    if !(_idx isEqualTo -1) then {
        (YVAR(ownerIDs) select 0) deleteAt _idx;
        (YVAR(ownerIDs) select 1) deleteAt _idx;
    };

}];
