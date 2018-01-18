/* ----------------------------------------------------------------------------
Function: derp_fnc_dirfffectCall
Description:
    Executes a piece of code in unscheduled environment.
Parameters:
    _code      - Code to execute <CODE>
    _arguments - Parameters to call the code with. (optional) <ANY>
Returns:
    _return - Return value of the function <ANY>
Examples:
    (begin example)
        0 spawn { {systemChat str canSuspend} call derp_fnc_directCall; };
        -> false
    (end)
Author:
    commy2
---------------------------------------------------------------------------- */

params [["_CBA_code", {}, [{}]], ["_CBA_arguments", []]];

private "_CBA_return";

isNil {
    _CBA_return = _CBA_arguments call _CBA_code;
};

if (!isNil "_CBA_return") then {_CBA_return};