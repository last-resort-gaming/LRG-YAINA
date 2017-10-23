/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if !(isServer) exitWith {};

GVAR(ownerIDs) = [[],[]]; // [[1,2,3,...], [[uid, profileName, _owner ID],...]

// Load reward Points
YVAR(rewardPoints) = profileNamespace getVariable QYVAR(rewardPoints);
if (isNil QYVAR(rewardPoints)) then {
    YVAR(rewardPoints) = 0;
};
publicVariable QYVAR(rewardPoints);

onPlayerConnected {
    (GVAR(ownerIDs) select 0) pushBack _id;
    (GVAR(ownerIDs) select 1) pushBack [_uid, _name, _owner];
};

onPlayerDisconnected {
    _idx = (GVAR(ownerIDs) select 0) find _id;
    if !(_idx isEqualTo -1) then {
        (GVAR(ownerIDs) select 0) deleteAt _idx;
        (GVAR(ownerIDs) select 1) deleteAt _idx;
    };
};
