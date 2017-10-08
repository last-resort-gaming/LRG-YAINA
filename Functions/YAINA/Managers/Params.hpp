
/**************************************************************************
* TIME MANAGER, x * 10 due to not being able to have decimal defaults
**************************************************************************/

class TimeManagerEnable {
    title = "Enable Time Manager";
    values[] = {0, 1};
    texts[] = {"No", "Yes"};
    default = 0;
};

// 03:30 - 05:30
class TimeManagerDawnDuration {
    title = "Dawn Duration (03:30 - 05:30)";
    values[] = {10, 20, 30, 40, 60, 120};
    texts[] = {"2 hours", "1 hour", "40 minutes", "30 minutes", "20 minutes", "10 minutes"};
    default = 20;
};

// 05:30 - 18:30 (13 hours)
class TimeManagerDayDuration {
    title = "Day Duration (05:30 - 18:30)";
    values[] = {10, 26, 40, 65, 130, 260, 520, 1200};
    texts[] = {"13 hours", "5 hours", "3 hours 15 minutes", "2 hours", "1 hour", "30 minutes", "15 minutes", "6 ish minutes"};
    default = 65;
};

// 18:30 - 20:30
class TimeManagerDuskDuration {
    title = "Dusk Duration (18:30 - 20:30)";
    values[] = {10, 20, 30, 40, 60, 120};
    texts[] = {"2 hours", "1 hour", "40 minutes", "30 minutes", "20 minutes", "10 minutes"};
    default = 20;
};

// 20:30 - 03:30
class TimeManagerNightDuration {
    title = "Night Duration (20:30 - 03:30)";
    values[] = {10, 20, 40, 70, 140, 210, 420, 840};
    texts[] = {"7 hours", "3 hours 30 minutes", "1 hour 45 minutes", "1 hour", "30 minutes", "20 minutes", "10 minutes", "5 minutes"};
    default = 210;
};
