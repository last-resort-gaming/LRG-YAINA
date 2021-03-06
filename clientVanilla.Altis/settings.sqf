// YAINA Mission Parameters: settings.sqf
// This is loaded during preInit

///////////////////////////////////////////////////////////
// MISSION MANAGER
///////////////////////////////////////////////////////////

// Disable the mission manager, this manages the
// spawning of all of the missions
yaina_mission_manager_disable = false;

///////////////////////////////////////////////////////////
// TIME AND WEWATHER
///////////////////////////////////////////////////////////

// Enable dynamic weather system, when set to false, make
// sure you have set the correct time and day for your op
real_weather_enabled = true;

// Enable time manager (variable time acceleration), if
// you disable this, then it will be set to the value of
// yaina_default_time_multiplier (1 = realtime, 2 = twice
// realtime etc.)

yaina_time_manager_enabled = true;
yaina_default_time_multiplier = 1;

///////////////////////////////////////////////////////////
// UAV LIMITS
///////////////////////////////////////////////////////////

// UAV Limits, limits the number of deployed UAVs from
// backpacks, set to 0 to disable
yaina_uav_limit_darters  = 3;
yaina_uav_limit_pelicans = 1;

///////////////////////////////////////////////////////////
// VEHICLES
///////////////////////////////////////////////////////////

// Enable vehicle abandonment, if set to false then
// vehicles cannot be abandoned and will only despawn and
// perhaps, respawn when they are destroyed
yaina_vehicle_abandonment = true;

///////////////////////////////////////////////////////////
// PLAYERS
///////////////////////////////////////////////////////////

// Allow players to fire within base protection areaas ?
yaina_allow_firing_at_base = false;