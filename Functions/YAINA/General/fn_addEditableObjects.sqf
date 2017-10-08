/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_objArr", ["_addCrew", true]];

if !(isServer) then {
    [_objArr, _addCrew] remoteExec [Q(FNC(addEditableObjects)), 2];
} else {
    {
        _x addCuratorEditableObjects [_objArr, _addCrew];
    } forEach allCurators;
};
