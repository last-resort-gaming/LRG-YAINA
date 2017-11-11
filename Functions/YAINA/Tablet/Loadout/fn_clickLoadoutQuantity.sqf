#include "..\defines.h";

params ["_lb", "_action"];
private ["_selected"];

_ctrl = (ctrlParentControlsGroup (_lb select 0)) controlsGroupCtrl 1501;
_row  = lnbCurSelRow _ctrl;

_ammo = _ctrl lnbData [_row, 1];

_idx = (GVAR(loadout) select 0) find _ammo;
_cv  = 1;

if (_idx isEqualTo -1) then {
    if (_action isEqualTo "sub") exitWith {};

    // Must be add...
    (GVAR(loadout) select 0) pushBack _ammo;
    (GVAR(loadout) select 1) pushBack 1;
} else {
    _cv = (GVAR(loadout) select 1) select _idx;

    if (_action isEqualTo "add") then {
        _cv = _cv + 1;
    } else {
        if (_cv > 0) then {
          _cv = _cv - 1;
        };
    };

    (GVAR(loadout) select 1) set [_idx, _cv];
};

// now set the row..
_ctrl lnbSetText [[_row, 1], str  _cv];