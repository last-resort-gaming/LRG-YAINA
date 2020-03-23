/*
Function: YAINA_fnc_setUnitTraits

Description:
	Set a unit's traits. The unit modified has to be local, but the effect
    of adding a trait is global. Traits are also stored in a seperate variable.

Parameters:
	_traits - The traits we want to add to the given unit
    _unit - The unit which trait's we want to modify

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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