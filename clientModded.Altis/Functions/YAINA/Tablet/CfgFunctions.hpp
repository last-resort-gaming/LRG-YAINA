
class YAINA_TABLET {

    class Init {
        file = "functions\YAINA\Tablet\Init";
        class postInit { postInit = 1; };
    };

    class General {
        file = "functions\YAINA\Tablet\General";
        class clickMainMenu {};
        class displayPage {};
        class formatDuration {};
    };

    class Loadout {
        file = "functions\YAINA\Tablet\Loadout";
        class clickLoadoutButton {};
        class clickLoadoutQuantity {};
        class populateLoadout {};
        class selectionChangedPlayer {};
        class createLoadout {};
        class refreshLoadoutPage {};
    };

    class Rewards {
        file = "functions\YAINA\Tablet\Rewards";
        class refreshRewardsPage {};
        class clickRewardsButton {};
        class selectionChangedRewards {};
        class clickOrderReward {};
        class clickCancelReward {};
        class rewardsEH { postInit = 1; };
        class getSpawnPoint {};
        class provisionReward {};
    };

    class Message {
        file  = "functions\YAINA\Tablet\Message";
        class refreshMessagePage {};
    };

    class Player {
        file = "functions\YAINA\Tablet\Player";
        class openTablet {};
    };

    class Spawns {
        file = "functions\YAINA\Tablet\Spawns";
        class createSupplyDrop {};
        class createMedicalContainer {};
		class createVehicleAmmo {};
		class createVehicleRepair {};
		class createFuelContainer {};
        class setDroppable {};
    };
};
