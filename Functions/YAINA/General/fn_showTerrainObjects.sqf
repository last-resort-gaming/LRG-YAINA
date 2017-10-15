/*
	author: Martin
	description: none
	returns: nothing
*/


params [
    ["_objects", [], [[]]]
];

{
    if !(isNull _x) then {
        _x hideObjectGlobal false;
        _x allowDamage true;
    };
    true;
} count _objects;