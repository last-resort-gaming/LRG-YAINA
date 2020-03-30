class YAINA_CMD {
	tag = "YAINA_CMD";

    class Core {
        file = "Functions\YAINA\Commands\Core";
		class postInitServer { postInit=1; };
        class log {};
        class exec {};
        class findPlayer {};
        class notifyAdmins {};
        class generalMessage {};
        class hasCommand {};
    };

    class Commands {
        file = "Functions\YAINA\Commands\Commands";
        class addcredits {};
        class credits {};
        class help {};
        class mmstart {};
        class mmpause {};
        class mmlist {};
        class mmstop {};
        class report {};
        class settrait {};
        class revive {};
        class zeusadd {};
        class zeusdel {};
        class zeuslist {};
        class warn {};
        class kick {};
        class restart {};
        class rtpause {};
        class mission {};
        class logfps {};
        class promote {};
        class repair {};
        class players {};
        class paradrop {};
        class jet {};
		class bppause {};
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
		class tfarmsg {};

    };
};
