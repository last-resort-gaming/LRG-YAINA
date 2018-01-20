/*
	author: Martin
	description: none
	returns: nothing
*/

#include "script_component.hpp"

// Initialisation required by CBA events.
GVAR(eventNamespace) = call CBAP_fnc_createNamespace;
GVAR(eventHashes) = call CBAP_fnc_createNamespace;

if (isServer) then {
    GVAR(eventNamespaceJIP) = true call CBAP_fnc_createNamespace;
    publicVariable QGVAR(eventNamespaceJIP);
};
