
/*

 Author: MitchJC
 Updated: MartinCo

 Last Resort Gaming (LastResortGaming.net)

*/

if (!hasInterface) exitWith {};

private _onScreenTime = 10;

sleep 10;

private _messages = call {

    if ("HQ" call YAINA_fnc_testTraits) exitWith {
        [
            [ "You're HQ, you MUST be on Teamspeak.", ["ts.yaina.eu"]],
            [ "You can purchase Mission rewards from the laptop.", ["ONLY approve sensible requests!"]],
            [ "Organise transport for each Section.", ["Approve and coordinate CAS."]]
        ]
    };

    if ("PILOT" call YAINA_fnc_testTraits) exitWith {
        [
            ["You're a Pilot, you MUST be on Teamspeak.", ["ts.yaina.eu"]],
            ["Create your own group.", ["Press 'U' and click 'Create.'"]],
            ["Listen to HQ and Section Commanders.", ["CAS is by request ONLY."]]
        ]
    };

    if ("UAV" call YAINA_fnc_testTraits) exitWith {
        [
            ["You're UAV, you MUST be on Teamspeak.", ["ts.yaina.eu"]],
            ["Create your own group.", ["Press 'U' and click 'Create.'"]],
            ["Assist Sections on the Ground", ["CAS is by request ONLY"]]
        ]
    };

    [
        [ "You MUST be in a Section.", ["Press 'U' to create or join one."] ],
        [ "Wait in your Section Area and request transport.", ["Don't board choppers without HQ Permission."] ],
        [ "Work as a team.", ["No Teamkilling or shooting at base."] ]
    ];
};

_messages pushBack [ "Any bugs or suggestions?", ["Report them at LastResortGaming.net"] ];

{
    _x params ["_heading", "_lines"];

    sleep 2;

    _finalText = format ["<t size='0.70' color='#ffae00' align='right'>%1<br /></t><t size='0.60' color='#FFFFFF' align='right'>", _heading];
    { _finalText = _finalText + format ["%1<br />", _x]; } forEach _lines;
    _finalText = _finalText + "</t>";

    _onScreenTime + (((count _lines) - 1) * 0.5);

    [
        _finalText,
        [safezoneX + safezoneW - 1.2,0.8], //DEFAULT: 0.5,0.35
        [safezoneY + safezoneH - 0.8,0.9], //DEFAULT: 0.8,0.7
        _onScreenTime,
        0.5
    ] spawn BIS_fnc_dynamicText;

    sleep (_onScreenTime);
} forEach _messages;