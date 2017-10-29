class YAINA_SPAWNS {
	tag = "YAINA_SPAWNS";

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

    };

    class Reinforcements {
        file = "Functions\YAINA\Spawns\Reinforcements";
    };
};