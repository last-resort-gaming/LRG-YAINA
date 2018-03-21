/*
* Author: unknown
* Rewrote by: alganthe
* Display the crew and vehicle heading / target
*
* Arguments:
* Nothing
*
* Return Value:
* Nothing
*/

player addEventHandler ["GetInMan", {
    [{
        params ["_args", "_pfhID"];

        if (isNull objectParent player) then {
            [_pfhID] call CBAP_fnc_removePerFrameHandler;
        } else {
            disableSerialization;

            1000 cutRsc ["HudNames","PLAIN"];
            private _ui = uiNameSpace getVariable "HudNames";
            private _HudNames = _ui displayCtrl 99999;

            private _vehicle = assignedVehicle player;
            private _weap = currentWeapon vehicle player;
            private _name = format ["<t size='1.1' color='#FFFFFF'>%1</t><br/>", getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "DisplayName")];

            {
                if ((driver _vehicle == _x) || (gunner _vehicle == _x)) then {
                    if (driver _vehicle == _x) then {
                        _name = format ["<t size='0.9' color='#f0e68c'>%1 %2</t> <img size='0.8' color='#6b8e23' image='a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa'/><br/>", _name, (name _x)];
                    } else {
                        _name = format ["<t size='0.9' color='#f0e68c'>%1 %2</t> <img size='0.8' color='#6b8e23' image='a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/><br/>", _name, (name _x)];
                    };
                } else {
                    _name = format ["<t size='0.9' color='#f0e68c'>%1 %2</t> <img size='0.8' color='#6b8e23' image='a3\ui_f\data\IGUI\Cfg\Actions\getincargo_ca.paa'/><br/>", _name, (name _x)];
                };

            } forEach crew _vehicle;

            _HudNames ctrlSetStructuredText parseText _name;
            _HudNames ctrlCommit 0;

        };
    }, 0, []] call CBAP_fnc_addPerFrameHandler;
}];