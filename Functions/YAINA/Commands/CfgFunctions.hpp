class YAINA_CMD {
	tag = "YAINA_CMD";

    class Core {
        file = "Functions\YAINA\Commands\Core";
        class postInit { postInit=1; };
        class log {};
        class exec {};
        class allowed {};
        class findPlayer {};
        class notifyAdmins {};
    };

    class Commands {
        file = "Functions\YAINA\Commands\Commands";
        class addcredits {};
        class credits    {};
        class help {};
        class ugmsg {};
        class mmstart {};
        class mmpause {};
        class mmlist {};
        class mmstop {};
        class report {};
        class setadmin {};
        class settrait {};
    };
};
