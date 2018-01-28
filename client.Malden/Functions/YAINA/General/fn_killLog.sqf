/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

params ["_killer", "_msg"];
private ["_tmp"];

if (!isServer) exitWith {};

// we expect this only to be called from players
if (remoteExecutedOwner in [0,2]) exitWith {};

_tmp = (allPlayers select { owner _x isEqualTo remoteExecutedOwner } );
if (_tmp isEqualTo []) exitWith {};
private _caller = _tmp select 0;

// Was the killer AI / Zeus / Player
private _ko = owner _killer;
private _kc = objNull;
private _kt = "AI    ";

_tmp = (allPlayers select { owner _x isEqualTo _ko } );
if (!(_tmp isEqualTo []) && { YAINA_MM_hcList find (name (_tmp select 0)) isEqualTo -1 }) then {
    _kc = _tmp select 0;
    _kt = ["ZEUS  ", "PLAYER"] select (_kc isEqualTo _killer);
};

// AI     | yaina_m_server_0_hqg:2  | caller | _msg
// PLAYER | MartinCo (129512508125) | caller | _msg
// ZEUS   | MartinCo (124124512512) | caller | _msg

// Form up log line
private _log = [_kt];
_log pushBack format ["Killed: %1 (%2)", name _caller, getPlayerUID _caller];

if (!isNull _kc) then {
    _log pushBack format["By: %1 (%2)", name _kc, getPlayerUID _kc];
};
_log pushBack _msg;

[(_log joinString " | "), "KillLog"] call YFNC(log);