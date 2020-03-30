// init.sqf
//
// Recommend installing the following server-side mods:
//
//   Advanced Sling Loading
//   Advanced Repelling
//   Advanced Towing

enableSaving [false, false];

if (real_weather_enabled) then {
    [] execVM "scripts\code34\real_weather.sqf";
};

// Only use Advanced Ropes on the Huron
ASL_SUPPORTED_VEHICLES_OVERRIDE = [ "B_Heli_Transport_03_F", "B_Heli_Transport_03_unarmed_F" ];