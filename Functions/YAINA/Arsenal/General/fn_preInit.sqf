/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

///////////////////////////////////////////////////////////
// WEAPONS
///////////////////////////////////////////////////////////
GVAR(allWeapons) = [[],[]];

_addToArray = {
    params ["_array", "_key", "_value"];

    _idx = (_array select 0) find _key;
    if (_idx isEqualTo -1) then {
        (_array select 0) pushBack _key;
        (_array select 1) pushBack [_value];
    } else {
        ((_array select 1) select _idx) pushBack _value;
    };
};


// Weapons
{
    _class = configName _x;

    // Skip if it's a MineDetector (type 4)
    if !(_class isEqualTo "MineDetector") then {

        _type = getText (_x >> "cursor");

        // create custom class for weapons with GLs
        if (!({ _x in [ "EGLM", "GL_3GL_F" ] } count getArray(_x >> "muzzles") isEqualTo 0)) then {
            _type = "gl";
        };

        [GVAR(allWeapons), _type, _class] call _addToArray;
    };
    true;
} count ("getnumber (_x >> 'type') in [1,2,4] AND getnumber (_x >> 'scope') isEqualTo 2 AND count ('!(configName _x isEqualTo ""LinkedItemsUnder"")' configClasses (_x >> 'LinkedItems')) isEqualTo 0" configClasses (configfile >> 'CfgWeapons'));
// Primary weapons, main scope, do not have additional item attachments (base items) other than under for bipod

///////////////////////////////////////////////////////////
// BACKPACKS
///////////////////////////////////////////////////////////
GVAR(carryPacks) = [[],[]];
GVAR(specialPacks) = [[],[]];

{
    _class = configName _x;
    _cap   = getNumber(_x >> "maximumLoad");

    if !(_cap isEqualTo 0) then {
        [GVAR(carryPacks), _cap, _class] call _addToArray;
    } else {
        // Special Packs: UAVs/static weapons etc, these are split by side
        // B_static, B_UAV, B_MedicalUAV

        _elems = _class splitString "_";
        _side  = _elems select 0;
        _type  = nil;

        if (_class isEqualTo "B_Parachute") then {
            _type = "basic";
        } else {
            // We split out UAV and Medical UAVs
            if(_elems select 1 in ["UAV", "IDAP"]) then {
                if (_elems select 3 isEqualTo "medical") then {
                    _type = "MedicalUAV";
                } else {
                    _type = "UAV";
                };
            } else {
                _type = "StaticWeapon";
            };
            _type = format["%1_%2", _side, _type];
        };

        if (!isNil "_type") then {
            [GVAR(specialPacks), _type, _class] call _addToArray;
        };
    };

    true;
} count ("getText (_x >> 'vehicleClass') isEqualTo 'Backpacks' AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgVehicles'));

///////////////////////////////////////////////////////////
// Headgwear / Eyewear / Vests / Uniforms / NVG / Binos
///////////////////////////////////////////////////////////

// These are all general items, so just have items, though
// we look up the values separately as the filtering depends
// on it

GVAR(items) = [[],[]];

// Headgear
{
    _class = configName _x;
    _elems = _class splitString "_";

    // If it ends with a _S<Side> we leave it e.g: PilotHelmetHeli_B
    _type = _elems select [0,2] joinString "_";
    _end  = _elems select (count _elems - 1);
    if (_end in ["B", "O", "I"]) then {
        _type = format["%1_%2", _type, _end];
    };

    [GVAR(items), _type, _class] call _addToArray;

    true;
} count ("getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 605 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgWeapons'));

// Vests
{
    _class = configName _x;
    _elems = _class splitString "_";

    // Most of the time we can just pick the first two elems, except one...
    _type  = _elems select [0,2] joinString "_";

    if (_class isEqualTo "V_I_G_resistanceLeader_F") then {
        _type = "V_I_G_resistanceLeader";
    };

    if (_class isEqualTo "V_EOD_IDAP_blue_F") then {
        _type = "V_EOD_IDAP";
    };

    [GVAR(items), _type, _class] call _addToArray;

    true;
} count ("getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 701 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgWeapons'));

// Eyewear G_X, just pick the first two again
{
    _class = configName _x;
    _elems = _class splitString "_";

    if !(_class isEqualTo "None") then {
        _type  = _elems select [0,2] joinString "_";

        if ((_elems select 1) in ["I", "O"]) then {
            _type = _class;
        };

        [GVAR(items), _type, _class] call _addToArray;
    };
    true;
} count ("getNumber (_x >> 'scope') >= 2" configClasses (configFile >> "CfgGlasses"));

// NVGs/Binos, first item, unless it's an O, in which case first and second...
{
    _class = configName _x;
    _elems = _class splitString "_";
    _type  = _elems select 0;

    if (_elems select 0 isEqualTo "O") then {
        _type = _elems select [0,2] joinString "_";
    };

    [GVAR(items), _type, _class] call _addToArray;
    true;
} count ("getnumber (_x >> 'scope') isEqualTo 2 AND getnumber (_x >> 'type') isEqualTo 4096" configClasses (configfile >> 'CfgWeapons'));

// Uniforms....thankfully, are consistently named
{
    _class = configName _x;
    _elems = _class splitString "_";

    // Because the nature, we'll shortcut, and just group by side so, U_B or U_O
    _type = _elems select [0,2] joinString "_";

    // Then filter what we don't want later
    [GVAR(items), _type, _class] call _addToArray;

    true;
} count ("getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 801 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgWeapons'));


// Silencers (101) / Scopes (201) /  Attachments (IR/Flash) - 301 / Bipods (302)
{
    _class = configName _x;
    _type  = getNumber (_x >> 'ItemInfo' >> 'Type');

    _group = call {
        if (_type isEqualTo 101) exitWith { "silencers" };
        if (_type isEqualTo 201) exitWith {
            // We group on the 2nd element
            _elems = _class splitString "_";
            format ["optic_%1", _elems select 1];
        };
        if (_type isEqualTo 301) exitWith { "acc" };
        if (_type isEqualTo 302) exitWith { "bipods" };
    };

    [GVAR(items), _group, _class] call _addToArray;

    true;
} count ("getnumber (_x >> 'ItemInfo' >> 'Type') in [101,201,301,302] AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgWeapons'));
