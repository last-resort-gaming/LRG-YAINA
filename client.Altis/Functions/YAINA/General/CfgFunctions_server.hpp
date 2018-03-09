class YAINA {
	tag = "YAINA";

	class General {
		file = "Functions\YAINA\General";
		class baseCleanupManager { postInit = 1; };
		class timeManager{ postInit=1; };
		class hideTerrainObjects{};
		class showTerrainObjects{};
		class getPointBetween {};
		class postInit { postInit = 1; };
		class markerManager { postInit = 1; };
		class preInit { preInit = 1; };
		class dirFromNearestName {};
		class addRewardPoints {};
		class globalHint {};
		class getPosAround {};
		class loadDB {};
		class log {};
		class getAdminLevelFromGUID {};
		class addActionMP {};
		class killLog {};
		class deleteVehicleIn {};
		class kickSelf {};
		class playerIntroComplete {};
		class settings { preInit=1; };
    };
};