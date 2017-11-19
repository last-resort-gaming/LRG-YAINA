class YAINA_MM {
    tag = "YAINA_MM";

    class Managers {
        file = "Functions\YAINA\Missions\Manager";
        class addHC {};
        class addHCDCH {};
        class delHCDCH {};
        class missionManager {};
        class mmPostInit { postInit=1; };
        class mmPreInit  { preInit=1; };
        class setMissionID {};
        class startMissionPFH {};
        class endMissionPFH {};
        class updateMissionStage {};
        class updateMissionState {};
        class setupParadrop {};
    };

    class Objectives_MAO {
        file = "Functions\YAINA\Missions\Objectives\MainAO";
        class spawnMainAO {};
    };

    class SideMissions {
        file = "Functions\YAINA\Missions\Objectives\SideMissions";
        class radioTower {};
    };

    class Utils {
        file = "Functions\YAINA\Missions\Utils";
        class createMapMarkers {};
        class getMissionID {};
        class missionCleanup {};
        class getMissionGroups {};
        class paraDrop {};
        class setupParadropActions { postInit = 1; };
        class openChute {};
    };

};