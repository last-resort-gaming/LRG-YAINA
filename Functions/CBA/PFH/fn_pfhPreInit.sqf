// band-aid fix for onPlayerConnected
[CBA_OPC_FIX, "onPlayerConnected", {}] call BIS_fnc_addStackedEventHandler;
[CBA_OPC_FIX, "onPlayerConnected"] call BIS_fnc_removeStackedEventHandler;

// PFH stuff
call compile preprocessFileLineNumbers 'functions\CBA\PFH\init_perFrameHandler.sqf';
