/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"
#include "..\General\a3-ui_f-config.hpp"

///////////////////////////////////////////////////////////
// COLORS
///////////////////////////////////////////////////////////

#define BUTTON_COLOR         {0.23922,0.17255,0.07451,1}
#define BUTTON_COLOR_ACTIVE  {0.403922,0.294118,0.125490,1}

///////////////////////////////////////////////////////////
// DIMENSIONS
///////////////////////////////////////////////////////////

#define L_GUI_GRID_W	(0.025)
#define L_GUI_GRID_H	(0.025)

#define SCREEN_H (0.5957 * (0.8 * safezoneH) - 10 * pixelH)
#define SCREEN_W (0.3980 * (1.35 * safezoneH))
#define SCREEN_Y (safezoneY + 0.2773 * (0.8 * safezoneH) + 0.1 * safezoneH + 5 * pixelH)
#define SCREEN_X (safezoneX + ((safezoneW - (1.35 * safezoneH)) / 2) + 0.28 * (1.4 * safezoneH))

#define CONTENT_Y (SCREEN_Y + (10 * pixelH) + 0.04)
#define CONTENT_X (SCREEN_X + .5 * L_GUI_GRID_W)
#define CONTENT_W (SCREEN_W - (10 * pixelW))
#define CONTENT_H (SCREEN_H - (10 * pixelH + 0.04))

#define SLOT_W ((CONTENT_W / 3) - 8 * pixelW)
#define SLOT_H (0.12)

///////////////////////////////////////////////////////////
// GENERAL DEFINES
///////////////////////////////////////////////////////////

class RscListNBox {
    access=0;
    idc=102;
    type=CT_LISTNBOX;
    style=ST_LEFT + ST_MULTI;
    default=0;
    enable=1;
    show=1;
    fade=0;
    blinkingPeriod=0;
    x="29 * (((safezoneW / safezoneH) min 1.2) / 40) + (safezoneX + (safezoneW - ((safezoneW / safezoneH) min 1.2))/2)";
    y="15 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY + (safezoneH - (((safezoneW / safezoneH) min 1.2) / 1.2))/2)";
    w="10 * (((safezoneW / safezoneH) min 1.2) / 40)";
    h="3  * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
    sizeEx="0.03";
    font="RobotoCondensed";
    shadow=0;
    colorText[]={1,1,1,1};
    colorDisabled[]={1,1,1,0.5};
    colorSelect[]={1,1,1,1};
    colorSelectBackground[] = {0.6,0.6,0.6,1};
    colorShadow[]={0,0,0,0.5};
    tooltip="CT_LISTNBOX";
    tooltipColorShade[]={0,0,0,1};
    tooltipColorText[]={1,1,1,1};
    tooltipColorBox[]={1,1,1,1};
    colorPicture[] = {1,1,1,1};
    colorPictureSelected[] = {1,1,1,1};
    colorPictureDisabled[] = {1,1,1,1};
    columns[]={0.1,0.4};
    drawSideArrows=0;
    period=0;
    rowHeight="0.05";
    maxHistoryDelay=1;

    soundSelect[]= {
        "\A3\ui_f\data\sound\RscListbox\soundSelect",
        0.09,
        1
    };

    class ListScrollBar {
        width=0;
        height=0;
        scrollSpeed=0.0099999998;
        arrowEmpty="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull="\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border="\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb="\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
        color[]={1,1,1,1};
    };
};

class NavButton {
	idc = -1;
	type = CT_ACTIVETEXT;
	style = ST_PICTURE;
	x = 0.75;
    y = SCREEN_Y;
    w = SCREEN_W * 0.33;
    h = 0.04;
	font = PuristaMedium;
	sizeEx = 0.024;
	color[] = { 0.7, 0.7, 0.7, 1 };
	//colorActive[] = { 1, 1, 1, 1 };
	//colorDisabled[] = {1,1,1,1};
	soundEnter[] = { "", 0, 1 };   // no sound
	soundPush[] = { "", 0, 1 };
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1}; // basic button sound
	soundEscape[] = { "", 0, 1 };
	action = "";
	tooltip = "";
	text = "";  // texture location
	default = false;
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,0,0,1};
	colorActive[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,1};
};

class NavText : RscText {
    style = ST_CENTER;
    colorText[] = {0.8,0.8,0.8,1};
};

class LoadoutButton : NavButton {
    style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
    y = 0.04;
    w = 2.4 * L_GUI_GRID_W;
    h = 2.2 * L_GUI_GRID_H;
    colorText[] = {0.8, 0.8, 0.8, 1};
    colorActive[] = {1,1,1,1};
};

class RewardsButton : NavButton {
    style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
    y = 0.01 + ( (((SLOT_W/16)*3) - ((SLOT_W/20)*3)) / 2 );
    w = SLOT_W / 5;
    h = (SLOT_W / 20) * 3;
    colorText[] = {0.8, 0.8, 0.8, 1};
    colorActive[] = {1,1,1,1};
};

class LoadoutBG : RscText {
    text = "";
    y = 0.04;
    w = 2.4 * L_GUI_GRID_W;
    h = 2.2 * L_GUI_GRID_H;
};

class RewardsBG : RscText {
    text = "";
    y = 0.01;
    w = SLOT_W / 4;
    h = (SLOT_W / 16) * 3;
};

class RequestButton : RscButton {
    w = CONTENT_W * 0.23;
    h = CONTENT_H * 0.15;
    colorText[] = {0.8, 0.8, 0.8, 1};
    colorActive[] = {1,1,1,1};
    colorFocused[] = BUTTON_COLOR;
    colorBackground[] = BUTTON_COLOR;
    colorBackgroundActive[] = BUTTON_COLOR_ACTIVE;
};

class KanbanSlot : RscControlsGroup {
  idc = -1;
  w = SLOT_W;
  h = SLOT_H;

  class controls {

    class SlotBG : IGUIBack {
        idc = 123;
        colorBackground[] = {1,1,0,1};
        w = SLOT_W;
        h = SLOT_H;
        x = 0;
        y = 0;
    };

    class SlotFrame : RscFrame {
        idc = -1;
        colorText[] = {1,0,0,1};
        w = SLOT_W;
        h = SLOT_H;
        x = 0;
        y = 0;
    };


  };
};

class RscXListBox {
	deletable = 0;
	fade = 0;
	idc = -1;
	type = 42;
	x = 0.1;
	y = 0.1;
	color[] = {1, 1, 1, 0.6};
	colorActive[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.25};
	colorSelect[] = {0.95, 0.95, 0.95, 1};
	colorText[] = {1, 1, 1, 1};
	soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect", 0.09, 1};
	colorPicture[] = {1, 1, 1, 1};
	colorPictureSelected[] = {1, 1, 1, 1};
	colorPictudeDisabled[] = {1, 1, 1, 0.25};
	tooltipColorText[] = {1, 1, 1, 1};
	tooltipColorBox[] = {1, 1, 1, 1};
	tooltipColorShade[] = {0, 0, 0, 0.65};
	style = "0x400 + 0x02 +	0x10";
	shadow = 2;
	arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
	w = 0.14706;
	h = 0.039216;
	font = "PuristaMedium";
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorPictureDisabled[] = {1, 1, 1, 1};
};


///////////////////////////////////////////////////////////
// HQ TABLET START
///////////////////////////////////////////////////////////

class HQTabletDialog {
    idd = IDD_TABLET;
    movingEnable = 0;


    class controlsBackground {

        // Bring on the device...
        class DeviceBG: RscPicture {
            idc = -1;
            text = "Data\Comms\x10gxx.paa";
            colorBackground[] = {0,0,0,1};
            h = 0.8  * safezoneH;
            w = 1.35 * safezoneH;
            x = safezoneX + ((safezoneW - (1.35 * safezoneH)) / 2);
            y = 0.1 * safezoneH + safezoneY;
        };

        class NavButtonP1BG : NavButton {
            idc  = 11;
            text = "Data\Comms\button2.paa";
            x = SCREEN_X;
            default = true;
        };

        class NavButtonP2BG : NavButton {
            idc  = 12;
            text = "Data\Comms\button2.paa";
            x = SCREEN_X + (SCREEN_W * 0.333333);
        };

        class NavButtonP3BG : NavButton {
            idc  = 13;
            text = "Data\Comms\button2.paa";
            x = SCREEN_X + 2*(SCREEN_W * 0.333333);
        };

    };

    class controls {

        class NavButtonP1Txt : NavText {
            idc = 21;
            text = "P1: Support Requests";
            sizeEx = 0.04;
            x = SCREEN_X;
            y = SCREEN_Y;
            w = SCREEN_W * 0.33;
            h = 0.04;
        };

        class NavButtonP2Txt : NavText {
            idc = 22;
            text = "P2: Rewards";
            sizeEx = 0.04;
            x = SCREEN_X + (SCREEN_W * 0.333333);
            y = SCREEN_Y;
            w = SCREEN_W * 0.33;
            h = 0.04;
        };

        class NavButtonP3Txt : NavText {
            idc = 23;
            text = "P3: Coming Soon";
            sizeEx = 0.04;
            x = SCREEN_X + 2*(SCREEN_W * 0.333333);
            y = SCREEN_Y;
            w = SCREEN_W * 0.33;
            h = 0.04;
        };

        class NavLine : RscPicture {
            style = ST_TILE_PICTURE;
            text = "Data\Comms\line.paa";
            x = SCREEN_X;
            y = SCREEN_Y + 0.04 + 5 * pixelH;
            w = SCREEN_W;
            tileH = 2;
            tileW = 2;
            h = 2 * pixelH;
        };

        ///////////////////////////////////////////////////
        // PAGE: Requests
        ///////////////////////////////////////////////////

        class PageRequests: RscControlsGroup {
            idc = IDC_PAGE_REQUESTS;
            x = CONTENT_X;
            y = CONTENT_Y;
            w = CONTENT_W;
            h = CONTENT_H;
            onLoad = "ctrlShow [_this,false];";

            class controls {

                class AmmoDropButton : RequestButton {
                    idc = 1500;
                    x = 0;
                    y = 0.01;
                    text = "Create Ammo Drop";
                };

                class AirDefenceButton : RequestButton {
                    idc = 1501;
                    x = (CONTENT_W * 0.25);
                    y = 0.01;
                    text = "Activate Air Defence";
                };

                class MedicalContainerButton : RequestButton {
                    idc = 1502;
                    x = (CONTENT_W * 0.5);
                    y = 0.01;
                    text = "Create Medical Container";
                };

            };
        };

        ///////////////////////////////////////////////////
        // PAGE: Message
        ///////////////////////////////////////////////////

        class PageMessage : RscControlsGroup {
            idc = IDC_PAGE_MESSAGE;
            x = CONTENT_X;
            y = CONTENT_Y;
            w = CONTENT_W;
            h = CONTENT_H;
            onLoad = "ctrlShow [_this,false];";

            class controls {
                class Message : RscStructuredText {
                    idc   = 1500;
                    type  = CT_STRUCTURED_TEXT;
                    style = ST_LEFT;
                    x = 0;
                    y = 0;
                    w = CONTENT_W;
                    h = CONTENT_H;
                    class Attributes {
                        align = "center";
                        valign = "middle";
                        shadow = false;
                    };
                };
            };
        };

        /*
        class RequestsKanban: RscControlsGroup {
            idc = 99211;
            x = CONTENT_X;
            y = CONTENT_Y;
            w = CONTENT_W;
            h = CONTENT_H;

            class controls {
                class KanbanLine1 : RscPicture {
                    style = ST_TILE_PICTURE;
                    text = "Data\Comms\linev.paa";
                    x = CONTENT_W / 3;
                    y = 0.005;
                    w = 2 * pixelW;
                    h = CONTENT_H - 0.01;
                    tileH = 2;
                    tileW = 2;
                };
                class KanbanLine2 : RscPicture {
                    style = ST_TILE_PICTURE;
                    text = "Data\Comms\linev.paa";
                    x = (2 * CONTENT_W) / 3;
                    y = 0.005;
                    w = 2 * pixelW;
                    h = CONTENT_H - 0.01;
                    tileH = 2;
                    tileW = 2;
                };
            };
        };
        */

        ///////////////////////////////////////////////////
        // PAGE: Ammo Drop
        ///////////////////////////////////////////////////

        class PageAmmoDrop: RscControlsGroup {

            idc = IDC_PAGE_AMMOBOX;
            x = CONTENT_X;
            y = CONTENT_Y;
            w = CONTENT_W;
            h = CONTENT_H;
            onLoad = "ctrlShow [_this,false];";

            class controls {

                // Loadout Minus
                class LoadoutMinus : RscButton {
                    idc = 1192;
                    colorBackground[] = {0,0,0,0.5};
                    text = "-";
                    onLoad = "ctrlShow [_this,false];";
                };

                // Loadout Plus
                class LoadoutPlus : RscButton {
                    idc = 1193;
                    colorBackground[] = {0,0,0,0.5};
                    text = "+";
                    onLoad = "ctrlShow [_this,false];";
                };

                class PlayerTitle: RscText {
                    idc = -1;
                    text = "Players:";
                    sizeEx = 0.03;
                    x = 0;
                    y = 0;
                    w = 0.333 * SCREEN_W;
                    h = 0.04;
                };

                class SIText: RscText {
                    idc = 1001;
                    text = "Suitable Items";
                    sizeEx = 0.03;
                    x = 0.3333 * CONTENT_W;
                    y = 0;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                // PlayerList
                class PlayerListbox: RscListbox {
                    idc = 1500;
                    x = 0;
                    y = 0.04;
                    w = 0.3 * CONTENT_W;
                    h = CONTENT_H - 0.04 - 2 * L_GUI_GRID_H ;
                    //colorBackground[] = {0.2,0.2,0.2,1};


                    class ListScrollBar
                    {
                        width=0;
                        height=0;
                        scrollSpeed=0.0099999998;
                        arrowEmpty="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull="\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border="\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb="\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                        color[]={1,1,1,1};
                    };
                };

                // We use BGs as we can't get the color i want without it...works
                // and it allows me to drop the player button down to be in the middle
                class PlayerLoadoutButtonBG: LoadoutBG { idc = 50; x = 0.33 * CONTENT_W; };
                class PrimaryLoadoutButtonBG: LoadoutBG { idc = 51; x = 0.333 * CONTENT_W + 2.4 * L_GUI_GRID_W; };
                class SecondaryLoadoutButtonBG: LoadoutBG { idc = 52; x = 0.33 * CONTENT_W + 2 *(2.4 * L_GUI_GRID_W); };
                class HandgunLoadoutButtonBG: LoadoutBG { idc = 53; x = 0.33 * CONTENT_W + 3 *(2.4 * L_GUI_GRID_W); };
                class GrenadeLoadoutButtonBG: LoadoutBG { idc = 54; x = 0.33 * CONTENT_W + 4 *(2.4 * L_GUI_GRID_W); };
                class OpticsLoadoutButtonBG: LoadoutBG { idc = 55; x = 0.33 * CONTENT_W + 5 *(2.4 * L_GUI_GRID_W); };
                class UniformLoadoutButtonBG: LoadoutBG { idc = 56; x = 0.33 * CONTENT_W + 6 *(2.4 * L_GUI_GRID_W); };
                class VestLoadoutButtonBG: LoadoutBG { idc = 57; x = 0.33 * CONTENT_W + 7 *(2.4 * L_GUI_GRID_W); };
                class BackpackLoadoutButtonBG: LoadoutBG { idc = 58; x = 0.33 * CONTENT_W + 8 *(2.4 * L_GUI_GRID_W); };
                class HeadgearLoadoutButtonBG: LoadoutBG { idc = 59; x = 0.33 * CONTENT_W + 9 *(2.4 * L_GUI_GRID_W); };
                class BinosLoadoutButtonBG: LoadoutBG { idc = 60; x = 0.33 * CONTENT_W + 10 *(2.4 * L_GUI_GRID_W); };

                class PlayerLoadoutButton: LoadoutButton {
                    idc = 30;
                    x = 0.33 * CONTENT_W;
                    y = 0.045;
                    text = "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa";
                    tooltip = "Player Loadout";
                };

                class PrimaryLoadoutButton: LoadoutButton {
                    idc = 31;
                    x = 0.33 * CONTENT_W + 2.4 * L_GUI_GRID_W;
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\primaryweapon_ca.paa";
                    tooltip = "Primary Weapons";
                };

                class SecondaryLoadoutButton: LoadoutButton {
                    idc = 32;
                    x = 0.33 * CONTENT_W + 2 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\secondaryweapon_ca.paa";
                    tooltip = "Launchers";
                };

                class HandgunLoadoutButton: LoadoutButton {
                    idc = 33;
                    x = 0.33 * CONTENT_W + 3 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\handgun_ca.paa";
                    tooltip = "Handguns";
                };

                class GrenadeLoadoutButton: LoadoutButton {
                    idc = 34;
                    x = 0.33 * CONTENT_W + 4 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargomagall_ca.paa";
                    tooltip = "Magazines";
                };
                class OpticsLoadoutButton: LoadoutButton {
                    idc = 35;
                    x = 0.33 * CONTENT_W + 5 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\itemoptic_ca.paa";
                    tooltip = "Scopes";
                };
                class UniformLoadoutButton: LoadoutButton {
                    idc = 36;
                    x = 0.33 * CONTENT_W + 6 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\uniform_ca.paa";
                    tooltip = "Uniforms";
                };
                class VestLoadoutButton: LoadoutButton {
                    idc = 37;
                    x = 0.33 * CONTENT_W + 7 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\vest_ca.paa";
                    tooltip = "Vests";
                };

                class BackpackLoadoutButton: LoadoutButton {
                    idc = 38;
                    x = 0.33 * CONTENT_W + 8 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\backpack_ca.paa";
                    tooltip = "Backpacks";
                };

                class HeadgearLoadoutButton: LoadoutButton {
                    idc = 39;
                    x = 0.33 * CONTENT_W + 9 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\headgear_ca.paa";
                    tooltip = "Headgear";
                };

                class BinosLoadoutButton: LoadoutButton {
                    idc = 40;
                    x = 0.33 * CONTENT_W + 10 * (2.4 * L_GUI_GRID_W);
                    text = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\binoculars_ca.paa";
                    tooltip = "Items";
                };



                // Loadout NBox

                class LoadoutNBoxBG: RscFrame {
                    colorText[] = {1,1,1,1};
                    x = 0.33 * CONTENT_W - 2* pixelW;
                    y = 0.1 + 1 * L_GUI_GRID_H - pixelH;
                    w = 0.666 * CONTENT_W + 3 * pixelW;
                    h = CONTENT_H - 4 * L_GUI_GRID_H + 3 * pixelH - 0.1;
                };

                class LoadoutNBox: RscListNBox {
                    idc = 1501;
                    x = 0.33 * CONTENT_W;
                    y = 0.1 + 1 * L_GUI_GRID_H;
                    w = 0.666 * CONTENT_W;
                    h = CONTENT_H - 4 * L_GUI_GRID_H - 0.1;

                    columns[] = {0.05, 0.8};
                    colorBackground[] = {0.2,0.2,0.2,1};

                    drawSideArrows = 1;
                    idcLeft  = 1192;
                    idcRight = 1193;

                };

                // REWARD TYPE COMBO
                class AmmoBoxTypeTitle: RscText {
                    idc = -1;
                    text = "Type:";
                    sizeEx = 0.03;
                    x = 0.33 * CONTENT_W - 2* pixelW;
                    y = CONTENT_H - 2.4 * L_GUI_GRID_H ;
                    w = 0.2 * CONTENT_W;
                    h = 0.04;
                };

                class AmmoBoxType: RscXListBox {
                    idc = 1503;
                    x = 0.33 * CONTENT_W + ((CONTENT_W/3) * 0.2);
                    y = CONTENT_H - 2 * L_GUI_GRID_H ;
                    w = (CONTENT_W/3) * 0.8;
                    h = 1 * L_GUI_GRID_H;
                    sizeEx = 0.025;
                };

                class RscButtonMenuCancel_2700: RscButton {
                    idc = 1606;
                    text = "CANCEL";
                    x = CONTENT_W - 13 * L_GUI_GRID_W;
                    y = CONTENT_H - 2 * L_GUI_GRID_H ;
                    w = 6 * L_GUI_GRID_W;
                    h = 1 * L_GUI_GRID_H;
                };

                class RscButtonMenuOK_2600: RscButton {
                    idc = 1607;
                    text = "CREATE";
                    x = CONTENT_W - 6 * L_GUI_GRID_W;
                    y = CONTENT_H - 2 * L_GUI_GRID_H;
                    w = 6 * L_GUI_GRID_W;
                    h = 1 * L_GUI_GRID_H;
                };
            };
        };

        ///////////////////////////////////////////////////
        // PAGE: Rewards
        ///////////////////////////////////////////////////

        class PageRewards: RscControlsGroup {

            idc = IDC_PAGE_REWARDS;
            x = CONTENT_X;
            y = CONTENT_Y;
            w = CONTENT_W;
            h = CONTENT_H;
            onLoad = "ctrlShow [_this,false];";

            class controls {

                // Reward LB
                class RewardsLB: RscListbox {
                    idc = 1500;
                    x = 0;
                    y = 0.02 + ((SLOT_W/16)*3);
                    w = SLOT_W;
                    h = CONTENT_H - 0.01 - (0.02 + ((SLOT_W/16)*3));
                    colorText[] = {1,1,1,1};
                    colorBorder[] = {1,1,1,1};
                    sizeEx = 0.035;

                    class ListScrollBar
                    {
                        width=0;
                        height=0;
                        scrollSpeed=0.0099999998;
                        arrowEmpty="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                        arrowFull="\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                        border="\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                        thumb="\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
                        color[]={1,1,1,1};
                    };
                };

                // Buttons, buttons everywhere, as this isn't selected from a drop down
                class HeliButtonBG: RewardsBG  { idc = 50; x = 0; };
                class PlaneButtonBG: RewardsBG { idc = 51; x = (SLOT_W / 4); };
                class LandButtonBG: RewardsBG  { idc = 52; x = (SLOT_W / 2); };
                class UAVButtonBG: RewardsBG   { idc = 53; x = (SLOT_W * 3 / 4); };

                class HeliButton: RewardsButton {
                    idc = 30;
                    x = (((SLOT_W / 4) - (SLOT_W / 5)) / 2);
                    text = "\A3\Air_F_Beta\Heli_Attack_01\Data\UI\Heli_Attack_01_CA.paa";
                    tooltip = "Helicopters";
                };

                class PlaneButton: RewardsButton {
                    idc = 31;
                    x = (SLOT_W / 4) + (((SLOT_W / 4) - (SLOT_W / 5)) / 2);
                    text = "a3\air_f_epc\plane_cas_02\data\ui\plane_cas_02_f.paa";
                    tooltip = "Planes";
                };

                class LandButton: RewardsButton {
                    idc = 32;
                    x = 2 * (SLOT_W / 4) + (((SLOT_W / 4) - (SLOT_W / 5)) / 2);
                    text = "\A3\armor_f_gamma\MBT_01\Data\UI\Slammer_M2A1_Base_ca.paa";
                    tooltip = "Land Vehicles";
                };

                class UAVButton: RewardsButton {
                    idc = 33;
                    x = 3 * (SLOT_W / 4) + (((SLOT_W / 4) - (SLOT_W / 5)) / 2);
                    text = "\A3\Drones_F\Air_F_Gamma\UAV_01\Data\UI\UAV_01_CA.paa";
                    tooltip = "UAVs";
                };

                class RewardsVLineA : RscPicture {
                    style = ST_TILE_PICTURE;
                    text = "Data\Comms\linev.paa";
                    x = CONTENT_W * 0.33333;
                    y = 0.005;
                    w = 1 * pixelW;
                    h = CONTENT_H - 0.01;
                    tileH = 2;
                    tileW = 2;
                };

                class RscText_1001: RscText {
                    idc = -1;
                    text = "Asset Info";
                    sizeEx = 0.05;
                    x = CONTENT_W * 0.33333 + 0.01;
                    y = 0.015;
                    w = 0.2 * CONTENT_W;
                    h = 0.07;
                };

                class PRText: RscText {
                    idc = -1;
                    text = "Asset Preview:";
                    sizeEx = 0.03;
                    x = CONTENT_W * 0.33333 + 0.01;
                    y = 0.105;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                class AssetImage : RscPicture {
                    idc = 1101;
                    text = "";
                    style = ST_PICTURE + ST_KEEP_ASPECT_RATIO + ST_UP;
                    x = CONTENT_W * 0.33333 + 0.02;
                    y = 0.1;
                    w = (CONTENT_W * 0.33333) - 0.04;
                    h = (CONTENT_W * 0.33333) - 0.04;
                };

                class RewardsVLineB : RscPicture {
                    style = ST_TILE_PICTURE;
                    text = "Data\Comms\linev.paa";
                    x = CONTENT_W * 0.66666;
                    y = 0.005;
                    w = pixelW;
                    h = CONTENT_H - 0.01;
                    tileH = 2;
                    tileW = 2;
                };

                class PIText: RscText {
                    idc = -1;
                    text = "Purchase Info";
                    sizeEx = 0.05;
                    x = CONTENT_W * 0.66666 + 0.01;
                    y = 0.015;
                    w = 0.2 * CONTENT_W;
                    h = 0.07;
                };

                class CAText: RscText {
                    idc = -1;
                    text = "Points Available:";
                    sizeEx = 0.03;
                    x = CONTENT_W * 0.66666 + 0.01;
                    y = 0.1;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                class ACText: RscText {
                    idc = -1;
                    text = "Asset Cost:";
                    sizeEx = 0.03;
                    x = CONTENT_W * 0.66666 + 0.01;
                    y = 0.135;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                class BTText: RscText {
                    idc = -1;
                    text = "Build Time:";
                    sizeEx = 0.03;
                    x = CONTENT_W * 0.66666 + 0.01;
                    y = 0.17;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                class SPText: RscText {
                    idc = 1104;
                    text = "Can't Build:";
                    sizeEx = 0.03;
                    x = CONTENT_W * 0.66666 + 0.01;
                    y = 0.205;
                    w = 0.3 * CONTENT_W;
                    h = 0.04;
                };

                class CATextValue: RscText {
                    idc = 1201;
                    text = "1,000";
                    sizeEx = 0.03;
                    style = ST_RIGHT;
                    x = CONTENT_W - 0.3;
                    y = 0.1;
                    w = 0.3;
                    h = 0.04;
                };

                class ACTextValue: RscText {
                    idc = 1202;
                    text = "1,000";
                    sizeEx = 0.03;
                    style = ST_RIGHT;
                    x = CONTENT_W - 0.3;
                    y = 0.135;
                    w = 0.3;
                    h = 0.04;
                };

                class BTTextValue: RscText {
                    idc = 1203;
                    text = "30 seconds";
                    sizeEx = 0.03;
                    style = ST_RIGHT;
                    x = CONTENT_W - 0.3;
                    y = 0.17;
                    w = 0.3;
                    h = 0.04;
                };

                class SPTextValue: RscText {
                    idc = 1204;
                    text = "Spawn point occupied";
                    colorText[] = {1,0,0,1};
                    sizeEx = 0.03;
                    style = ST_RIGHT;
                    x = CONTENT_W - 0.3;
                    y = 0.205;
                    w = 0.3;
                    h = 0.04;
                };


                class ProBar {
                    idc = 1301;
                    type = CT_STATIC;
                    style = 0;
                    shadow=0;
                    colorBackground[] = {0.3,0.3,0.3,1};
                    colorText[] = {0.3,0.3,0.3,1};
                    text = "";
                    sizeEx = 0.03;
                    font = "RobotoCondensed";
                    y = CONTENT_H - 0.06;
                    h = 0.05 - 2 * pixelH;
                    x = CONTENT_W * 0.66666 + 0.02 + pixelW;
                    w = ((CONTENT_W * 0.33333) - 0.04 - 2 * pixelW) / 3;
                    onLoad = "ctrlShow [_this,false];";
                };

                class ProBorder {
                    idc = 1302;
                    type = CT_STATIC;
                    style=64;
                    shadow = 0;
                    colorBackground[] = {0,0,0,0};
                    colorText[] = {0.4,0.4,0.4,1};
                    font = "RobotoCondensed";
                    h = 0.05;
                    sizeEx = 0.04;
                    y = CONTENT_H - 0.06;
                    x = CONTENT_W * 0.66666 + 0.02;
                    w = (CONTENT_W * 0.33333) - 0.04;
                    onLoad = "ctrlShow [_this,false];";
                    text ="";
                };

                class ProBorderText: RscText {
                    idc = 1303;
                    colorText[] = {1,1,1,1};
                    sizeEx = 0.03;
                    text = "Building... 0%";
                    h = 0.05;
                    shadow=0;
                    y = CONTENT_H - 0.0625;
                    x = CONTENT_W * 0.66666 + 0.02;
                    w = (CONTENT_W * 0.33333) - 0.04;
                    onLoad = "ctrlShow [_this,false];";
                };

                class RewardsOrder: RscButton {
                    idc = 1600;
                    style = ST_RIGHT;
                    text = "ORDER";
                    sizeEx = 0.035;
                    colorBackground[] = {0,0,0,0};
                    colorBackgroundActive[] = {0,0,0,0};
                    colorActive[] = BUTTON_COLOR_ACTIVE;
                    shadow = 0;
                    x = CONTENT_W - 3 * L_GUI_GRID_W - 0.02;
                    y = CONTENT_H - 0.0625;
                    w = 3 * L_GUI_GRID_W;
                    h = 0.05;
                };

                class RewardsCancel: RscButton {
                    idc = 1601;
                    style = ST_RIGHT;
                    text = "CANCEL";
                    sizeEx = 0.035;
                    colorBackground[] = {0,0,0,0};
                    colorBackgroundActive[] = {0,0,0,0};
                    colorActive[] = BUTTON_COLOR_ACTIVE;
                    shadow = 0;
                    x = CONTENT_W - 3 * L_GUI_GRID_W - 0.02;
                    y = CONTENT_H - 0.0625;
                    w = 3 * L_GUI_GRID_W;
                    h = 0.05;
                    onLoad = "ctrlShow [_this,false];";
                };

            };
        };
    };
};