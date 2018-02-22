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
      arr set [0, (arr select 0) + ((_x select 0) select 0)];
      arr set [1, (arr select 1) + ((_x select 0) select 1)];
    } forEach ([
      [getItemCargo cursorObject],
      [getWeaponCargo cursorObject],
      [getBackpackCargo cursorObject],
      [getMagazineCargo cursorObject]
    ]);
    copyToClipboard str arr;

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
    ["FirstAidKit","optic_NVS","optic_MRCO","NVGoggles_OPFOR","1Rnd_HE_Grenade_shell","20Rnd_556x45_UW_mag","20Rnd_762x51_Mag","30Rnd_45ACP_Mag_SMG_01","30Rnd_556x45_Stanag_red","30Rnd_65x39_caseless_mag","7Rnd_408_Mag","B_IR_Grenade","DemoCharge_Remote_Mag","HandGrenade","NLAW_F","SatchelCharge_Remote_Mag","SmokeShell","SmokeShellBlue","Titan_AA","Titan_AP","Titan_AT","UGL_FlareWhite_F","10Rnd_338_Mag","130Rnd_338_Mag","10Rnd_50BW_Mag_F","10Rnd_127x54_Mag","5Rnd_127x108_APDS_Mag","30Rnd_545x39_Mag_F","150Rnd_556x45_Drum_Mag_F","200Rnd_556x45_Box_Red_F","100Rnd_580x42_Mag_F","30Rnd_580x42_Mag_F","100Rnd_65x39_caseless_mag","200Rnd_65x39_cased_Box","20Rnd_650x39_Cased_Mag_F","30Rnd_65x39_caseless_green","150Rnd_762x54_Box","30Rnd_762x39_Mag_Green_F","10Rnd_762x54_Mag","30Rnd_9x21_Mag_SMG_02","10Rnd_93x64_DMR_05_Mag","150Rnd_93x64_Mag","RPG7_F","RPG32_HE_F","RPG32_F"],
    [20,10,10,10,10,10,10,10,30,60,10,5,5,20,5,5,60,10,5,5,5,5,10,10,5,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,5,5,5]
];

// Place holder for last selected player
GVAR(loadout_last_idx) = nil;

///////////////////////////////////////////////////////////
// Device
///////////////////////////////////////////////////////////
(_tablet displayCtrl 11) ctrlSetEventHandler ["ButtonClick", format["ctrlIDC (_this select 0) call %1", FNC(clickMainMenu)]];
(_tablet displayCtrl 12) ctrlSetEventHandler ["ButtonClick", format["ctrlIDC (_this select 0) call %1", FNC(clickMainMenu)]];
(_tablet displayCtrl 13) ctrlSetEventHandler ["ButtonClick", format["ctrlIDC (_this select 0) call %1", FNC(clickMainMenu)]];

///////////////////////////////////////////////////////////
// Page: Requests
///////////////////////////////////////////////////////////

private _requests = _tablet displayCtrl IDC_PAGE_REQUESTS;
(_requests controlsGroupCtrl 1500) ctrlSetEventHandler ["ButtonClick", format["[%1] call %2 ", IDC_PAGE_AMMOBOX, FNC(displayPage)]];
(_requests controlsGroupCtrl 1501) ctrlSetEventHandler ["ButtonClick", "call YAINA_AD_fnc_activateAirDefence"];
(_requests controlsGroupCtrl 1502) ctrlSetEventHandler ["ButtonClick", format["call %1", FNC(createMedicalContainer)]];

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

GVAR(lastRewardSelection) = nil;
private _rewards = _tablet displayCtrl IDC_PAGE_REWARDS;
for "_i" from 30 to 33 step 1 do {
  (_rewards controlsGroupCtrl _i) ctrlSetEventHandler ["ButtonClick", format["ctrlIDC (_this select 0) call %1", FNC(clickRewardsButton)]];
};

(_rewards controlsGroupCtrl 1500) ctrlSetEventHandler ["LBSelChanged", format["_this call %1", FNC(selectionChangedRewards)]];
(_rewards controlsGroupCtrl 1600) ctrlSetEventHandler ["ButtonClick", format["call %1", FNC(clickOrderReward)]];
(_rewards controlsGroupCtrl 1601) ctrlSetEventHandler ["ButtonClick", format["call %1", FNC(clickCancelReward)]];

///////////////////////////////////////////////////////////
// DEVICE
///////////////////////////////////////////////////////////

// Explicitly call default parent
11 call FNC(clickMainMenu);