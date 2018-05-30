class YAINA_MM_OBJ {
    tag = "YAINA_MM_OBJ";

    class InfantryObjectives {
        file = "Functions\YAINA\Missions\Objectives\InfantryObjectives";
        class conquestBandit {};
        class conquestViper {};
        class conquestAAF {};	
    };

    class MainAO {
        file = "Functions\YAINA\Missions\Objectives\MainAO";
        class mainAO {};
    };

    class SubObjectivesAAF {
        file = "Functions\YAINA\Missions\Objectives\SubObjectivesAAF";
        class vicDepot {};
		class heliCAS {};
    };

    class SubObjectivesCSAT {
        file = "Functions\YAINA\Missions\Objectives\SubObjectivesCSAT";
        class radioTower {};
        class factory {};
    };

    class Priority {
        file = "Functions\YAINA\Missions\Objectives\Priority";
        class aa {};
        class arty {};
    };

    class SideMissions {
        file = "Functions\YAINA\Missions\Objectives\SideMissions";
        class prototypeTank {};
        class secureintelvehicle {};
        class secureradar {};
        class securechopper {};
        class hqcoast {};
        class hqresearch {};
    };

};

class YAINA_MM {
    tag = "YAINA_MM";

    class Managers {
        file = "Functions\YAINA\Missions\Manager";
        class addHC {};
        class addHCDCH {};
        class delHCDCH {};
        class missionManager {};
        class mmPostInitServer { postInit=1; };
        class mmPreInit  { preInit=1; };
        class setMissionID {};
        class startMissionPFH {};
        class updateMission{};
        class setupParadrop {};
        class startMission {};
        class stopMission {};
        class missionCleanup {};
        class addReinforcements {};
        class utilityPFH {};
    };

    class Utils {
        file = "Functions\YAINA\Missions\Utils";
        class createMapMarkers {};
        class getMissionID {};
        class getMissionUnits {};
        class getMissionGroups {};
        class findLargestBuilding {};
        class destroy {};
        class getAOExclusions {};
        class getFunctions {};
        class prefixGroups {};
    };

};