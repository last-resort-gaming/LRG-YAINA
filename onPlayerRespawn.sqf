/*
	author: MartinCo
	description: none
	returns: nothing
*/

[] execVM "scripts\YAINA\Utils\earplugs.sqf";


private _defaultLoadout = [
    ["arifle_AK12_F", "", "", "", ["30Rnd_762x39_Mag_Tracer_Green_F", 55], [], ""],[],[],
    ["U_Rangemaster",[["FirstAidKit",1]]],
    ["V_Rangemaster_belt",[["FirstAidKit",1]]],
    ["B_Carryall_khk",[["SatchelCharge_Remote_Mag",2,1],["Titan_AA",1,1],["SmokeShellGreen",5,1], ["FirstAidKit",1]]],
    "H_Cap_headphones",
    "",
    ["Laserdesignator_02_ghex_F","","","",["Laserbatteries",1],[],""],
    ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch",""]
];


player setUnitLoadout _defaultLoadout;
