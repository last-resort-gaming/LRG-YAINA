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
		class postInit { postInit = 1; };
    };

    class Reinforcements {
        file = "Functions\YAINA\Spawns\Reinforcements";
    };
};