class CfgPatches {
    class cba_settings_userconfig {
        author = "$STR_CBA_Author";
        name = "$STR_CBA_Settings_Component";
        url = "$STR_CBA_URL";
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"cba_settings"};
        version = 1.0;
        authors[] = {"commy2"};
    };
};

class CfgFunctions {
	class TFAR_SETTINGS {
		class SETTINGS {
			file = "\cba_settings_userconfig";
			class tfar_settings { preInit = 1; };
		};
	};
};

class CfgWeapons {
  class myNightVision: NVGoggles {
      scope = 1;
      modelOptics = "";
      author = ECSTRING(common,ACETeam);
      descriptionShort = "Biocular nightvision goggles";
      displayName = "NV Goggles (Bio)";
      GVAR(border) = QPATHTOF(data\nvg_mask_binos_4096.paa); // Edge mask for different tube configurations. Three types: mono, bino and quad.
      GVAR(bluRadius) = 0.13; // Edge blur radius.
      GVAR(eyeCups) = 1; // Does have eyecups.
      GVAR(generation) = 4; // Generation 4. Affects image quality.
  };
};