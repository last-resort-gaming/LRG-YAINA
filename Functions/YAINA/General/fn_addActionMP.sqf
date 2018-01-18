/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (!isServer) exitWith {
    _this remoteExec [QYFNC(addActionMP), 2];
};

// Add it for JIP clients
YVAR(addActionMPList) pushBack _this;

[_this, {
    _obj = _this deleteAt 0;
    _obj addAction _this;
}] remoteExec ["call"];
