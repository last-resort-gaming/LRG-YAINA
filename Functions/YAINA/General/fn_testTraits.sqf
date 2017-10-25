/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_traits"];

!({ player getUnitTrait format["YAINA_%1", _x]; } count _this isEqualTo 0);
