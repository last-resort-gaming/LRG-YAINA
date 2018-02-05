class YAINA_SPAWNS {
	tag = "YAINA_SPAWNS";

    class CQ {
        file = "Functions\YAINA\Spawns\CQ";
        class CQ_Deer {};
        class CQ_Eagle {};
        class CQ_Falcon {};
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