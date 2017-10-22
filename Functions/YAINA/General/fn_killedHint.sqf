/*
	author: Martin
	description: none
	returns: nothing
*/

YAINA_last_killhint_player = 0;

// Rather than searching through CfgWeapons / Magazines etc
// each time for explosives (pain), just do it here
YAINA_explosivesMap = [[],[]];

{
    _type = _x;
    {
        {
            (YAINA_explosivesMap select 0) pushBack getText(configFile >> "CfgMagazines" >> _x >> "ammo");
            (YAINA_explosivesMap select 1) pushBack getText(configFile >> "CfgMagazines" >> _x >> "displayName");
            true;
        } count (getArray(configFile >> "CfgWeapons" >> _type >> _x >> "Magazines"));
        true;
    } count getArray(configFile >> "CfgWeapons" >> _type >> "muzzles");
    true;
} count ["Throw", "Put"];

// Make note of our original side
player setVariable ["YAINA_side", playerSide, true];

// And add our killed by hint
["AIS_Unconscious", {
    params ["_unit", "_source", "_projectile", "_aisDamageType"];

    diag_log _this;

    // If i'm not the one unconsious, bail
    if (_unit != player) exitWith {};

    // There is also a race here with this being triggered multiple times in a frame so...
    // Lets just make sure we have a suitable gap between notifications

    /*
    _lkid = (YAINA_last_killhint select 0) find _unit;
    _lktt = 0;
    if !(_lkid isEqualTo -1) then {
        _lktt = (YAINA_last_killhint select 1) select _lkid;
    };
    */

    // can't die twice in 5 seconds
    if ((diag_tickTime - YAINA_last_killhint_player) < 5) exitWith {};

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
            _weapon = format["%1 %2", ["Their", "Your"] select (_unit isEqualTo _sourcePlayer), ["driving", "Flying"] select (_vehicle isKindOf "Air")];
        };
    };

    // if source is empty, then it's likely environmental, probably zeus though as they show up null-objs
    if (isNil "_sourcePlayer" || isNull _sourcePlayer) exitWith {};

    // Distance
    _distance = _source distance _unit;

    // And try and find the weapon, if there is a projectile, else we mark it as driver
    if !(_projectile isEqualTo "") then {

        // we search for the weapon, starting with the current weapon as it's the most likely
        _weaponMap = [currentWeapon _source];
        { _weaponMap pushBackUnique _x; true; } count (weapons _source);

        {
            _test = _x;
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
            } count (getArray(configFile >> "CfgWeapons" >> _test >> "Magazines"));

            if !(_c isEqualTo 0) exitWith { true; };
            false
        } count _weaponMap;
    };

    // If still nice dice, perhaps it was some explosives...
    if(isNil "_weapon") then {
        _eidx = (YAINA_explosivesMap select 0) find _projectile;
        if !(_eidx isEqualTo -1) then {
            _weapon = (YAINA_explosivesMap select 1) select _eidx;
        };
    };

    // If it's nil, then they could just be harry potter, but most likley
    // they fell as flames have no damage source.

    if(isNil "_weapon") then {
        // if falling, we have a different message
        if (_aisDamageType == "falling") then {
            _weapon = "Falling";
        } else {
            _weapon = format["%1 magic wand", ["Their", "Your"] select (_unit isEqualTo _sourcePlayer)];
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
        if((_sourcePlayer getVariable ["YAINA_side", side _sourcePlayer]) isEqualTo (_unit getVariable ["YAINA_side", side _unit])) then {
            _header = "<t color='#ff0000' size='2' shadow='1' shadowColor='#000000' align='center'>Friendly Fire...</t><br/>";
        };
    };

    _bodys  = "<t align='left'>";

    _bodys  = _bodys + (["Killer", name _sourcePlayer] call _elem);
    _bodys  = _bodys + (["Cause", _weapon] call _elem);

    if !((vehicle _sourcePlayer) isEqualTo _sourcePlayer) then {
        _bodys = _bodys + (["Vehicle", getText(configFile >> "CfgVehicles" >> (typeOf (vehicle _sourcePlayer)) >> "displayName")] call _elem);
    };

    _bodys = _bodys + (["Range", format["%1 meter%2", round(_distance), ["s", ""] select (_distance isEqualTo 1)]] call _elem);
    _hint = _header + _bodys + "</t>";

    hint parseText _hint;

    /*
    if (_lkid isEqualTo -1) then {
        (YAINA_last_killhint select 0) pushBack _unit;
        (YAINA_last_killhint select 1) pushBack diag_tickTime;
    } else {
        (YAINA_last_killhint select 1) set [_lkid, diag_tickTime];
    };
    */
    YAINA_last_killhint_player = diag_tickTime;

}] call CBA_fnc_addEventHandler;
