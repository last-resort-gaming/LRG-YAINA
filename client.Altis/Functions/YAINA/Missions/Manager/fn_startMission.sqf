/*
	author: Martin
	description: none
	returns: nothing
*/


#include "..\defines.h"

params ["_start"];
private ["_hcOwners", "_hcUnitCounts", "_cid", "_sortedHCs", "_dispatched"];

// If we are asked to start a PM, reset the PM timer, this covers #mmstart arty etc.
if (_start in GVAR(lPM)) then {
    GVAR(nextPM) = -1;
};

_hcOwners = GVAR(hcList) apply { owner (missionNamespace getVariable _x) };

// Get list of units per HC
_hcUnitCounts = [[],[]];
_cid = -1;
{
  if (_cid isEqualTo -1 || { !(((_hcUnitCounts select 0) select _cid) isEqualTo _x) } ) then {
    _cid = (_hcUnitCounts select 0) find _x;
  };

  if (_cid isEqualTo -1) then {
    (_hcUnitCounts select 0) pushBack _x;
    (_hcUnitCounts select 1) pushBack 1;
  } else {
    (_hcUnitCounts select 1) set [_cid, ((_hcUnitCounts select 1) select _cid) + 1];
  };
  nil;
} count (allUnits apply { owner _x } select { _x in _hcOwners } );

// Add any HCs not in the list already as they have 0 units on them
{
  _idx = (_hcUnitCounts select 0) find _x;
  if (_idx isEqualTo -1) then {
    (_hcUnitCounts select 0) pushBack _x;
    (_hcUnitCounts select 1) pushBack 0;
  };
  nil;
} count _hcOwners;

// sort the list based on the number of PFHs
_sortedHCs = [_hcUnitCounts select 1, [],{_x}, "ASCEND"] call BIS_fnc_sortBy;
_dispatched = false;

// Now go through the ones with least units on, and dispatch to them
while { !(_sortedHCs isEqualTo []) and !_dispatched } do {

    _id = (_hcUnitCounts select 1) find (_sortedHCs select 0);
    _sortedHCs deleteAt 0;

    if !(_id isEqualTo -1) then {
        _hcOwner = (_hcUnitCounts select 0) select _id;
        diag_log format ["missionManager: dispatching mission %1 to %2", _start, _hcOwner];
        [] remoteExec [_start, _hcOwner];
        _dispatched = true;
    };
};

// No suitable HC found, start on server here
if !(_dispatched) then {
    diag_log format ["missionManager: starting %1 on server", _start];
    _start spawn { call (missionNamespace getVariable _this ); };
};

nil