class YAINA_CMD {
	tag = "YAINA_CMD";

    class Core {
        file = "Functions\YAINA\Commands\Core";
		class postInitServer { postInit=1; };
    };

    class Commands {
        file = "Functions\YAINA\Commands\Commands";
        class servermsg {};
    };

};
