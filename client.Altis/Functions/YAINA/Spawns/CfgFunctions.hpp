class YAINA_SPAWNS {
	tag = "YAINA_SPAWNS";

    class CB {
        file = "Functions\YAINA\Spawns\CB";
        class CB_Deer {};
        class CB_Eagle {};
        class CB_Falcon {};
    };

    class CV {
        file = "Functions\YAINA\Spawns\CV";
        class CV_Alpha {};
		class CV_Bravo {};
		class CV_Charlie {};
    };

    class HQ {
        file = "Functions\YAINA\Spawns\HQ";
        class HQ_Courage {};
        class HQ_Defiance {};
        class HQ_Endurance {};
    };

	class General {
		file = "Functions\YAINA\Spawns";
		class getAirSpawnPos {};
        class getUnitsFromGroupArray {};
    };

    class Units {
        file = "Functions\YAINA\Spawns\Units";
        class infantryGarrison {};
        class infantryPatrol {};
        class setUnitSkill {};
        class createCrew {};
        class taskPatrol {};
        class populateArea {};
    };

    class Reinforcements {
        file = "Functions\YAINA\Spawns\Reinforcements";
        class cas {};
    };
};