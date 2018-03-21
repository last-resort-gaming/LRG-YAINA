class YAINA_CMD {
	tag = "YAINA_CMD";

    class Core {
        file = "Functions\YAINA\Commands\Core";
        class postInit { postInit=1; };
		class postInitServer { postInit=1; };
        class log {};
        class exec {};
        class allowed {};
        class findPlayer {};
        class notifyAdmins {};
        class generalMessage {};
    };

    class Commands {
        file = "Functions\YAINA\Commands\Commands";
        class addcredits {};
        class credits    {};
        class help {};
        class mmstart {};
        class mmpause {};
        class mmlist {};
        class mmstop {};
        class report {};
        class setadmin {};
        class settrait {};
        class revive {};
        class zeusadd {};
        class zeusdel {};
        class zeuslist {};
        class warn {};
        class kick {};
        class restart {};
        class stable {};
        class rtpause {};
        class mission {};
        class logfps {};
    };

    class Messages {
        file = "Functions\YAINA\Commands\Messages";
        class abusemsg {};
        class ffmsg {};
        class helimsg {};
        class hqmsg {};
        class lwmsg {};
        class mertmsg {};
        class pilotmsg {};
        class uavmsg {};
        class ugmsg {};
        class vehmsg {};
        class micmsg {};
    };
};
