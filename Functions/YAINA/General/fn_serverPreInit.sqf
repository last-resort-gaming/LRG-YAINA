/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if !(isServer) exitWith {};

// Bring in admins from DB
call YFNC(loadAdmins);

GVAR(ownerIDs) = [[],[]]; // [[1,2,3,...], [[uid, profileName, _owner ID]]
GVAR(addActionMPList) = [];

// Load reward Points
YVAR(rewardPoints) = profileNamespace getVariable QYVAR(rewardPoints);
if (isNil QYVAR(rewardPoints)) then {
    YVAR(rewardPoints) = 0;
};
publicVariable QYVAR(rewardPoints);

addMissionEventHandler["PlayerConnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    // Are they an admin ?
    private _idx = (GVAR(admins) select 0) find _uid;
    private _adminLevel = 0;
    if !(_idx isEqualTo -1) then {
        _adminLevel = (GVAR(admins) select 1) select _idx;
    };

    (GVAR(ownerIDs) select 0) pushBack _owner;
    (GVAR(ownerIDs) select 1) pushBack [_id, _uid, _name, _adminLevel];

    for "_i" from ((count GVAR(addActionMPList))-1) to 0 step -1 do {
        _obj = (GVAR(addActionMPList) select _i) select 0;
        if ( isNull ((GVAR(addActionMPList) select _i) select 0) ) then {
            GVAR(addActionMPList) deleteAt _i;
        } else {
            [GVAR(addActionMPList) select _i, {
                _obj = _this deleteAt 0;
                _obj addAction _this;
            }] remoteExec ["call", _owner];
        };
    };

}];


addMissionEventHandler["PlayerDisconnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    private _idx = (GVAR(adminsLogged) select 0) find _uid;
    if !(_idx isEqualTo -1) then {
        (GVAR(adminsLogged) select 0) deleteAt _idx;
        (GVAR(adminsLogged) select 1) deleteAt _idx;
    };

    _idx = (GVAR(ownerIDs) select 0) find _id;
    if !(_idx isEqualTo -1) then {
        (GVAR(ownerIDs) select 0) deleteAt _idx;
        (GVAR(ownerIDs) select 1) deleteAt _idx;
    };
}];
