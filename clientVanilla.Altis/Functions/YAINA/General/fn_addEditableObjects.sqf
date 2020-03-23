/*
Function: YAINA_fnc_addEditableObjects

Description:
	Add objects in given array as editable objects
	to all curators. Allows inclusion of vehicle crews.

Parameters:
	_objArr - Array containing all the objects we want to add
	_addCrew - true if vehicle crews shall be added too, false otherwise [true by default]

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params [["_objArr",[],[[]]], ["_addCrew", true]];

if !(isServer) then {
    [_objArr, _addCrew] remoteExecCall [QYFNC(addEditableObjects), 2];
} else {
    { _x addCuratorEditableObjects [_objArr, _addCrew]; } forEach allCurators;
};
