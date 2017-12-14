/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_traits", ["_unit", player]];

// Only modify local units, but with global effects
if !(local _unit) exitWith {};

// BIS default traits
private _defaultTraits = [
    'audibleCoef',
    'camouflageCoef',
    'engineer',
    'explosiveSpecialist',
    'loadCoef',
    'medic',
    'UAVHacker'
];

if (typeName _traits isEqualTo "STRING") then {
    _traits = [_traits];
};

private _defaultTraitsLC = _defaultTraits apply { toLower _x };
private _unitTraitVar = _unit getVariable ["YAINA_TRAITS", []];

{
    // We treat traits lower case for comp/custom traits
    _tl = toLower _x;

    // If it's a default trait, just straight set it
    _d  = _defaultTraitsLC find _tl;
    if !(_d isEqualTo -1) then {
        _unit setUnitTrait [_defaultTraits select _d, true];
    };

    // We always add it here for comparison later
    _unitTraitVar pushBackUnique _tl;

} forEach _traits;

_unit setVariable["YAINA_TRAITS", _unitTraitVar, true];