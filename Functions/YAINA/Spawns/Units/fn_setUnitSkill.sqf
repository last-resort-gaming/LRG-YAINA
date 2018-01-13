/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_group", ["_skillLevel", 2]];

if (_skillLevel < 0) then { _skillLevel = 0; };
if (_skillLevel > 2) then { _skillLevel = 3; };

// We set each unit to be a random skill within the range below table

// We pick the level above for general/commanding/courage though to try and ensure the
// AI plays nice and flanks etc.
([[0.1, 0.35], [.45, 0.2], [0.65, 0.2], [0.8, 0.15], [0.9,0.1]] select _skillLevel) params ["_min", "_range"];
([[0.1, 0.35], [.45, 0.2], [0.65, 0.2], [0.8, 0.15], [0.9,0.1]] select (_skillLevel+1)) params ["_minC", "_rangeC"];


{
    _x setSkill ["general",         _minC + random _rangeC];
    _x setSkill ["courage",         _minC + random _rangeC];
    _x setSkill ["commanding",      _minC + random _rangeC];

    _x setSkill ["aimingAccuracy",  _min + random _range];
    _x setSkill ["aimingShake",     _min + random _range];
    _x setSkill ["aimingSpeed",     _min + random _range];

    _x setSkill ["spotDistance",    _min + random _range];
    _x setSkill ["spotTime",        _min + random _range];

    _x setSkill ["reloadSpeed",     _min + random _range];
} forEach (units _group);