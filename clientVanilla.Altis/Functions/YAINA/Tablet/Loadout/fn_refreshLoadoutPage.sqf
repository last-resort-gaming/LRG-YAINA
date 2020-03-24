/*
Function: YAINA_TABLET_fnc_refreshLoadoutPage

Description:
	Reload the loadout page, resetting selections and quantities.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h";
disableSerialization;

private ["_tablet", "_lb"];

// If the spawn point is empty, dont show and just let them know.
if (triggerActivated SP_CARGO) exitWith {
    [IDC_PAGE_MESSAGE, "<br/><br/>Please clear the cargo spawn<br/><br/>There is currently something blocking the cargo spawn point, please clear it before proceeding"] call FNC(displayPage);
};

// Find Tablet
_tablet = findDisplay IDD_TABLET; if(_tablet isEqualTo displayNull) exitWith {};

// Get the player list control, empty and re-fill
_lb = _tablet displayCtrl IDC_PAGE_AMMOBOX controlsGroupCtrl 1500;

// If we have the last player selected saved, select them
// if they still exist

private _currIDX = GVAR(loadout_last_idx);
private _currPlayer = nil;

if (!(isNil "_currIDX")) then {
    _currPlayer = missionNamespace getVariable ( _lb lbData _currIDX );
};

private _allGroupsWithPlayers = [];
private _playerSide = side player;

{
    if (alive _x && side _x == _playerSide) then {
        _allGroupsWithPlayers pushBackUnique group _x
    }
} forEach (allPlayers - entities "HeadlessClient_F");

// Clear them
lbClear _lb;

{
    _lb lbAdd (groupId _x);

    _members = units _x;
    {
      _idx = _lb lbAdd format ["    %1", name _x];
      _lb lbSetData [_idx, [_x] call BIS_fnc_objectVar];

      if (isNil "_currIDX") then {
        _currIDX = _idx;
      };

      if (_x isEqualTo _currPlayer) then {
        _currIDX = _idx;
      };
    } forEach _members;

} forEach _allGroupsWithPlayers;

// Fill up the drop types
_typeBox = _tablet displayCtrl IDC_PAGE_AMMOBOX controlsGroupCtrl 1503;
lbClear _typeBox;
{
    _idx = _typeBox lbAdd getText(configFile >> "CfgVehicles" >> _x >> "displayName");
    _typeBox lbSetData [_idx, _x];
} forEach [
    "B_CargoNet_01_ammo_F",
    "B_Truck_01_box_F"
];
_typeBox lbSetCurSel 0;


// Set Remeber position of user when we opened, and then select
// so the event fires, and we get our user-list
GVAR(loadout_last_idx) = _currIDX;
_lb lbSetCurSel _currIDX;
