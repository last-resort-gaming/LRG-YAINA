class YAINA_VEH {
	tag = "YAINA_VEH";

    class Vehicles {
        file = "Functions\YAINA\Vehicles";
        class dropKey{};
        class initVehicle {};
        class postInit { postInit = 1; };
        class takeKey {};
        class updateOwnership {};
        class updatePlayerActions {};
        class respawnPFH {};
        class preInit { preInit = 1; };
        class setupRopeDetachHandler {};
        class addRopeDetachHandler {};
        class addGetInHandler {};
        class getInMan {};
        class getMarkers {};
        class flip {};
    };


    class defaults {
        file = "Functions\YAINA\Vehicles\defaults";
        class initHeli {};
    };
};
