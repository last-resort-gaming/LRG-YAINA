/*
Function: YAINA_fnc_killedHint

Description:
	Handles initialization of the hint displaying information about the killer etc.
    after a player's death, during the postInit phase.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if(!hasInterface) exitWith {};

YVAR(last_killhint_player) = 0;

// Rather than searching through CfgWeapons / Magazines etc
// each time for explosives (pain), just do it here
YVAR(explosivesMap) = [[],[]];

{
    _type = _x;
    {
        {
            (YVAR(explosivesMap) select 0) pushBack getText(configFile >> "CfgMagazines" >> _x >> "ammo");
            (YVAR(explosivesMap) select 1) pushBack getText(configFile >> "CfgMagazines" >> _x >> "displayName");
            true;
        } count (getArray(configFile >> "CfgWeapons" >> _type >> _x >> "Magazines"));
        true;
    } count getArray(configFile >> "CfgWeapons" >> _type >> "muzzles");
    true;
} count ["Throw", "Put"];

// Make note of our original side (unconsious etc.)
player setVariable [QYVAR(side), playerSide, true];

// And add our killed by hint
["AIS_Unconscious", {
    params ["_unit", "_source", "_projectile", "_aisDamageType"];

    // If i'm not the one unconsious, bail
    if (_unit != player) exitWith {};

    // can't die twice in 5 seconds
    if ((diag_tickTime - YVAR(last_killhint_player)) < 5) exitWith {};

    _vehicle   = vehicle _source;
    _inVehicle = !(_vehicle isEqualTo _source);
    _weapon    = nil;

    // Update source to be the player in charge of the gun (will be player if not in vehicle)
    _sourcePlayer = gunner _vehicle;

    // Now, if we're a UAV pick who is in control
    if (_vehicle isKindOf "UAV") then {

        // Might be null if it's disconnected
        _sourcePlayer = (UAVControl _vehicle) select 0;

        if(isNull _sourcePlayer) then {
            _sourcePlayer = gunner _vehicle;
        };

        _source = _vehicle;
        _weapon = format["%1 drone", ["Their", "Your"] select (_unit isEqualTo _sourcePlayer)];
    } else {
        // If no projectile, but we're in a vehicle, then blame the driver
        if (_projectile isEqualTo "" && _inVehicle) then {
            _sourcePlayer = driver _vehicle;
            _source = _vehicle;
            _weapon = format["%1 %2", ["Their", "Your"] select (_unit isEqualTo _sourcePlayer), ["driving", "flying"] select (_vehicle isKindOf "Air")];
        };
    };

    // if source is empty, then it's likely environmental, possibly zeus though as they show up null-objs
    // when using ModuleOrdnanceHowitzer_F_ammo / LightningBolt etc.

    if (isNil "_sourcePlayer" || isNull _sourcePlayer) exitWith {
        // We update here to avoid getting suicide from residual damage
        YVAR(last_killhint_player) = diag_tickTime;
        [_source, _projectile, _aisDamageType] remoteExec [QYFNC(killLog), 2];
    };

    // Distance
    _distance = round (_source distance _unit);

    // And try and find the weapon, if there is a projectile, else we mark it as driver
    if !(_projectile isEqualTo "") then {

        // we search for the weapon, starting with the current weapon as it's the most likely
        _weaponMap = [currentWeapon _source];
        { _weaponMap pushBackUnique _x; true; } count (weapons _source);

        {
            _test = _x;

            // For each weapon, we either have just the magazines, or the magazines of each of the muzzles
            _magazines = getArray(configFile >> "CfgWeapons" >> _test >> "Magazines");

            // If it's a turret etc. with multiple muzzles, gather them here
            {
                if (isClass(configFile >> "CfgWeapons" >> _test >> _x)) then {
                    _magazines append getArray(configFile >> "CfgWeapons" >> _test >> _x >> "Magazines");
                };
            } count getArray(configFile >> "CfgWeapons" >> _test >> "Muzzles");

            _c = {
                _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                if (_ammo isEqualTo _projectile) exitWith {
                    _weapon = getText(configFile >> "CfgWeapons" >> _test >> "displayName");
                    true;
                };

                // It could be a >> submunitionAmmo of the main ammo too (e.g. Cluster Bomb)
                _subMunitions  = getArray(configFile >> "CfgAmmo" >> _ammo >> "submunitionAmmo");
                _subMunitionsC = (count _subMunitions) / 2;

                for "_i" from 0 to _subMunitionsC do {
                    if ((_subMunitions select (_i * 2)) isEqualTo _projectile) exitWith {
                        _weapon = getText(configFile >> "CfgWeapons" >> _test >> "displayName");
                        true;
                    };
                };
                false
            } count _magazines;

            // Time to look at muzzles for each of our weapons if we haven't found them
            if !(_c isEqualTo 0) exitWith { true };
            false;
        } count _weaponMap;
    };

    // If still nice dice, perhaps it was some explosives...
    if(isNil "_weapon") then {
        _eidx = (YVAR(explosivesMap) select 0) find _projectile;
        if !(_eidx isEqualTo -1) then {
            _weapon = (YVAR(explosivesMap) select 1) select _eidx;
        };
    };

    // If it's nil, then they could just be harry potter, but most likley
    // they fell as flames have no damage source.

    if(isNil "_weapon") then {
        // if falling, we have a different message
        if (_aisDamageType == "falling") then {
            _weapon = "Falling";
        } else {
            _weapon = "Unknown";
        };
    };

    // Form up a string and display it
    _elem = {
        params ["_a", "_b"];
        format ["<br/><t color='#ffffff'>%1:</t><t align='right'>%2</t>", _a, _b];
    };

    // Friendly Fire / Suicide ?
    _header = "<t color='#ff0000' size='2' shadow='1' shadowColor='#000000' align='center'>You were killed...</t><br/>";

    if(_sourcePlayer isEqualTo _unit) then {
        _header = "<t color='#ff0000' size='2' shadow='1' shadowColor='#000000' align='center'>Suicide...</t><br/>";
    } else {
        if((_sourcePlayer getVariable [QYVAR(side), side _sourcePlayer]) isEqualTo (_unit getVariable [QYVAR(side), side _unit])) then {
            _header = "<t color='#ff0000' size='2' shadow='1' shadowColor='#000000' align='center'>Friendly Fire...</t><br/>";

            // If it were friendly fire and had a projectile, we make a public announcement of it
            if !(_projectile isEqualTo "") then {
                format["%1 was killed by %2's %3 from %4 meter%5", name player, name _sourcePlayer, _weapon, _distance, ["s", ""] select (_distance isEqualTo 1)] remoteExec ["systemChat"];
            };
        };
    };

    _bodys  = "<t align='left'>";
    _bodys  = _bodys + (["Killer", name _sourcePlayer] call _elem);
    _bodys  = _bodys + (["Cause", _weapon] call _elem);

    _feedb  = format["%1 killed by %2 (%3) with %4", name player, name _sourcePlayer, groupId (group _sourcePlayer), _weapon];

    if !((vehicle _sourcePlayer) isEqualTo _sourcePlayer) then {
        private _vs = getText(configFile >> "CfgVehicles" >> (typeOf (vehicle _sourcePlayer)) >> "displayName");
        _bodys = _bodys + (["Vehicle", _vs] call _elem);
        _feedb = _feedb + format[" from their %1", _vs];
    };

    private _rtxt = format["%1 meter%2", _distance, ["s", ""] select (_distance isEqualTo 1)];
    _bodys = _bodys + (["from", _rtxt] call _elem);
    _feedb = _feedb + format[" range %1", _rtxt];

    // We also dispatch to the server for the kill feed
    [_sourcePlayer, _projectile, _aisDamageType, _weapon, weapons _source, _vehicle] remoteExec [QYFNC(killLog), 2];

    _hint = _header + _bodys + "</t>";
    hint parseText _hint;

    YVAR(last_killhint_player) = diag_tickTime;

}] call CBAP_fnc_addEventHandler;
