/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_group", ["_skillLevel", 3]];

if (_skillLevel < 0) then { _skillLevel = 0; };
if (_skillLevel > 3) then { _skillLevel = 4; };

// We set each unit to be a random skill within the range below table
([[0.1, 0.35], [.45, 0.2], [0.65, 0.2], [0.85, 0.2], [1,0]] select _skillLevel) params ["_min", "_range"];

{
    _x setSkill ["general",         _min + random _range];
    _x setSkill ["aimingAccuracy",  _min + random _range];
    _x setSkill ["aimingShake",     _min + random _range];
    _x setSkill ["aimingSpeed",     _min + random _range];
    _x setSkill ["spotDistance",    _min + random _range];
    _x setSkill ["spotTime",        _min + random _range];
    _x setSkill ["courage",         _min + random _range];
    _x setSkill ["reloadSpeed",     _min + random _range];
    _x setSkill ["commanding",      _min + random _range];
} forEach (units _group);