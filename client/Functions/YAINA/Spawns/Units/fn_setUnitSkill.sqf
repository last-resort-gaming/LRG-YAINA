/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_target", ["_skillLevel", 2]];

if (_skillLevel < 1) then { _skillLevel = 1; };
if (_skillLevel > 4) then { _skillLevel = 4; };

// We set each unit to be a random skill within the range below table
private _skillt = ["aimingAccuracy", "aimingShake", "aimingSpeed", "commanding", "courage", "endurance", "general", "reloadSpeed", "spotDistance", "spotTime"];
private _skillv = call {
    if (_skillLevel isEqualTo 1) exitWith { [0.25, 0.65, 0.40, 1, 1, 1, 1, 1, 0.75, 0.6] };
    if (_skillLevel isEqualTo 2) exitWith { [0.35, 0.75, 0.55, 1, 1, 1, 1, 1, 0.80, 0.7] };
    if (_skillLevel isEqualTo 3) exitWith { [0.50, 0.90, 0.70, 1, 1, 1, 1, 1, 1.00, 0.9] };
    if (_skillLevel isEqualTo 4) exitWith { [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] };
};

private _units = call {
    if ((typeName _target) isEqualTo "GROUP") exitWith { units _target };
    _target;
};

{
    _a = _x;
    _b = _skillv select _forEachIndex;
    { _x setSkill [_a, _b]; true } count _units;
} forEach _skillt;
