/*
Function: YAINA_fnc_addRewardPoints

Description:
	Add or subtract the given amount of reward points to/from
    the current balance.

Parameters:
	_count - The amount of points to add or subtract from the current balance
    _source - The source of where the points came from

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_count", ["_source", ""]];

if (!isServer) exitWith {
    [_count, _source] remoteExecCall [QYFNC(addRewardPoints), 2];
};

YVAR(rewardPoints) = YVAR(rewardPoints) + _count;
if (YVAR(rewardPoints) < 0) then {
    YVAR(rewardPoints) = 0;
};

if(_source isEqualTo "") then { _source = "unknown"; };

// Logging
private _owner = "server";

if (isRemoteExecuted && { !(remoteExecutedOwner isEqualTo 0) } ) then {
    _idx = (YVAR(ownerIDs) select 0) find remoteExecutedOwner;
    if !(_idx isEqualTo -1) then {
        _owner = (YVAR(ownerIDs) select 1) select _idx;
    };
};

diag_log format ["RewardPoints: %1 added by %2 for %3 - total: %4", _count, _owner, _source, YVAR(rewardPoints)];

profileNamespace setVariable [QYVAR(rewardPoints), YVAR(rewardPoints)];
saveProfileNamespace;

publicVariable QYVAR(rewardPoints);
