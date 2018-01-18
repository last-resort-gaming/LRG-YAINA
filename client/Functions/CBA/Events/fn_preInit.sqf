/*
	author: Martin
	description: none
	returns: nothing
*/

#include "script_component.hpp"

// Initialisation required by CBA events.
GVAR(eventNamespace) = call CBA_fnc_createNamespace;
GVAR(eventHashes) = call CBA_fnc_createNamespace;

if (isServer) then {
    GVAR(eventNamespaceJIP) = true call CBA_fnc_createNamespace;
    publicVariable QGVAR(eventNamespaceJIP);
};
