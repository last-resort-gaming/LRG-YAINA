/*
	author: Martin
	description:
	    Opens up the HQ tablet, sets any default parameters
	    for all pages and hooks up our event handlers for
	    button presses.
	returns: nothing

	Default loadout is most easily authored by creating an
	ammo box in the editor and running the following:

    arr = [[], []];
    {
      arr set [0, (aarr select 0) + ((_x select 0) select 0)];
      arr set [1, (aarr select 1) + ((_x select 0) select 1)];
    } forEach ([
      [getItemCargo DummyBox],
      [getWeaponCargo DummyBox],
      [getBackpackCargo DummyBox],
      [getMagazineCargo DummyBox]
    ]);
    diag_log str arr;

*/
#include "..\defines.h"
disableSerialization;

if (!createDialog "HQTabletDialog") exitWith {};

// immediately hide all child pages if they aren't already
{ctrlShow [_x,false];} count IDC_PAGES;

// Display Items
private _tablet = findDisplay IDD_TABLET;

// RESET TO BASE LOADOUT
GVAR(loadout) = [
    ["FirstAidKit","Medikit","NVGoggles_OPFOR","optic_NVS","ToolKit","arifle_AK12_F","B_Patrol_Soldier_Carrier_weapon_F","30Rnd_65x39_caseless_mag","20Rnd_762x51_Mag","Laserbatteries","HandGrenade","MiniGrenade","SmokeShell","10Rnd_338_Mag","130Rnd_338_Mag","5Rnd_127x108_APDS_Mag","150Rnd_556x45_Drum_Mag_Tracer_F","200Rnd_556x45_Box_Tracer_Red_F","150Rnd_762x54_Box_Tracer","30Rnd_762x39_Mag_Tracer_Green_F","DemoCharge_Remote_Mag","SatchelCharge_Remote_Mag","RPG32_HE_F","RPG32_F","SmokeShellBlue","Titan_AA","Titan_AP","Titan_AT"],
    [20,2,5,2,2,2,5,25,10,5,10,10,30,10,10,20,10,10,10,25,10,5,5,10,10,5,5,10]
];

// Place holder for last selected player
GVAR(loadout_last_idx) = nil;

///////////////////////////////////////////////////////////
// Page: Requests
///////////////////////////////////////////////////////////

private _requests = _tablet displayCtrl IDC_PAGE_REQUESTS;
(_requests controlsGroupCtrl 1500) ctrlSetEventHandler ["ButtonClick", format["[%1] call %2 ", IDC_PAGE_AMMOBOX, FNC(displayPage)]];
(_requests controlsGroupCtrl 1501) ctrlSetEventHandler ["ButtonClick", "call YAINA_AD_fnc_activateAirDefence"];

///////////////////////////////////////////////////////////
// Page: AmmoBox
///////////////////////////////////////////////////////////

private _ammoBox = _tablet displayCtrl IDC_PAGE_AMMOBOX;

for "_i" from 30 to 40 step 1 do {
  (_ammoBox controlsGroupCtrl _i) ctrlSetEventHandler ["ButtonClick", format["_this call %1", FNC(clickLoadoutButton)]];
};

(_ammoBox controlsGroupCtrl 1500) ctrlSetEventHandler ["LBSelChanged", format["_this call %1", FNC(selectionChangedPlayer)]];
(_ammoBox controlsGroupCtrl 1606) ctrlSetEventHandler ["ButtonClick", format["[%1] call %2 ", IDC_PAGE_REQUESTS, FNC(displayPage)]];
(_ammoBox controlsGroupCtrl 1607) ctrlSetEventHandler ["ButtonClick", format["[] call %1 ", FNC(createLoadout)]];
(_ammoBox controlsGroupCtrl 1192) ctrlSetEventHandler ["ButtonClick", format["[_this, 'sub'] call %1 ", FNC(clickLoadoutQuantity)]];
(_ammoBox controlsGroupCtrl 1193) ctrlSetEventHandler ["ButtonClick", format["[_this, 'add'] call %1 ", FNC(clickLoadoutQuantity)]];

///////////////////////////////////////////////////////////
// Page: Rewards
///////////////////////////////////////////////////////////

private _rewards = _tablet displayCtrl IDC_PAGE_REWARDS;
for "_i" from 30 to 33 step 1 do {
  (_rewards controlsGroupCtrl _i) ctrlSetEventHandler ["ButtonClick", format["ctrlIDC (_this select 0) call %1", FNC(clickRewardsButton)]];
};

(_rewards controlsGroupCtrl 1500) ctrlSetEventHandler ["LBSelChanged", format["_this call %1", FNC(selectionChangedRewards)]];

///////////////////////////////////////////////////////////
// DEVICE
///////////////////////////////////////////////////////////

// We do these last so the event triggers
(_tablet displayCtrl 11) ctrlSetEventHandler ["ButtonClick", format["_this call %1", FNC(clickMainMenu)]];
(_tablet displayCtrl 12) ctrlSetEventHandler ["ButtonClick", format["_this call %1", FNC(clickMainMenu)]];
(_tablet displayCtrl 13) ctrlSetEventHandler ["ButtonClick", format["_this call %1", FNC(clickMainMenu)]];