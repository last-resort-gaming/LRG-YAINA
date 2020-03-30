/*
	These elements are copied and pasted from
	a3\ui_f\config.cpp as they are used in other
	sections
*/

#define GUI_GRID_X	(0)
#define GUI_GRID_Y	(0)
#define GUI_GRID_W	(0.025)
#define GUI_GRID_H	(0.04)
#define GUI_GRID_WAbs	(1)
#define GUI_GRID_HAbs	(1)

// Control types
#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_EDIT             2
#define CT_SLIDER           3
#define CT_COMBO            4
#define CT_LISTBOX          5
#define CT_TOOLBOX          6
#define CT_CHECKBOXES       7
#define CT_PROGRESS         8
#define CT_HTML             9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT       11
#define CT_TREE             12
#define CT_STRUCTURED_TEXT  13
#define CT_CONTEXT_MENU     14
#define CT_CONTROLS_GROUP   15
#define CT_SHORTCUTBUTTON   16
#define CT_XKEYDESC         40
#define CT_XBUTTON          41
#define CT_XLISTBOX         42
#define CT_XSLIDER          43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT           80
#define CT_OBJECT_ZOOM      81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK        98
#define CT_USER             99
#define CT_MAP              100
#define CT_MAP_MAIN         101
#define CT_LISTNBOX         102

// Static styles
#define ST_POS            0x0F
#define ST_HPOS           0x03
#define ST_VPOS           0x0C
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_DOWN           0x04
#define ST_UP             0x08
#define ST_VCENTER        0x0C

#define ST_TYPE           0xF0
#define ST_SINGLE         0x00
#define ST_MULTI          0x10
#define ST_TITLE_BAR      0x20
#define ST_PICTURE        0x30
#define ST_FRAME          0x40
#define ST_BACKGROUND     0x50
#define ST_GROUP_BOX      0x60
#define ST_GROUP_BOX2     0x70
#define ST_HUD_BACKGROUND 0x80
#define ST_TILE_PICTURE   0x90
#define ST_WITH_RECT      0xA0
#define ST_LINE           0xB0

#define ST_SHADOW         0x100
#define ST_NO_RECT        0x200
#define ST_KEEP_ASPECT_RATIO  0x800

#define ST_TITLE          ST_TITLE_BAR + ST_CENTER

// Slider styles
#define SL_DIR            0x400
#define SL_VERT           0
#define SL_HORZ           0x400

#define SL_TEXTURES       0x10

// progress bar 
#define ST_VERTICAL       0x01
#define ST_HORIZONTAL     0

// Listbox styles
#define LB_TEXTURES       0x10
#define LB_MULTI          0x20

// Tree styles
#define TR_SHOWROOT       1
#define TR_AUTOCOLLAPSE   2

// MessageBox styles
#define MB_BUTTON_OK      1
#define MB_BUTTON_CANCEL  2
#define MB_BUTTON_USER    4

class ScrollBar
{
	color[]={1,1,1,0.60000002};
	colorActive[]={1,1,1,1};
	colorDisabled[]={1,1,1,0.30000001};
	thumb="\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
	arrowEmpty="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	arrowFull="\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	border="\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	shadow=0;
	scrollSpeed=0.059999999;
	width=0;
	height=0;
	autoScrollEnabled=0;
	autoScrollSpeed=-1;
	autoScrollDelay=5;
	autoScrollRewind=0;
};

class RscText
{
	type = 0;
	x=0;
	y=0;
	h=0.037;
	w=0.30000001;
	style=0;
	shadow=1;
	colorShadow[]={0,0,0,0.5};
	font="RobotoCondensed";
	SizeEx="(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorText[]={1,1,1,1};
	colorBackground[]={0,0,0,0};
	linespacing=1;
	tooltipColorText[]={1,1,1,1};
	tooltipColorBox[]={1,1,1,1};
	tooltipColorShade[]={0,0,0,0.64999998};
};

class RscButton
{
	type = 1;
	idc=-1;
	style=2;
	x=0;
	y=0;
	w=0.095588997;
	h=0.039216001;
	shadow=2;
	font="RobotoCondensed";
	sizeEx="(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	url="";
	colorText[]={1,1,1,1};
	colorDisabled[]={1,1,1,0.25};
	colorBackground[]={0,0,0,0.5};
	colorBackgroundActive[]={0,0,0,1};
	colorBackgroundDisabled[]={0,0,0,0.5};
	colorFocused[]={0,0,0,1};
	colorShadow[]={0,0,0,0};
	offsetX=0;
	offsetY=0;
	offsetPressedX=0;
	offsetPressedY=0;
	colorBorder[]={0,0,0,1};
	borderSize=0;
	soundEnter[]=
	{
		"\A3\ui_f\data\sound\RscButton\soundEnter",
		0.090000004,
		1
	};
	soundPush[]=
	{
		"\A3\ui_f\data\sound\RscButton\soundPush",
		0.090000004,
		1
	};
	soundClick[]=
	{
		"\A3\ui_f\data\sound\RscButton\soundClick",
		0.090000004,
		1
	};
	soundEscape[]=
	{
		"\A3\ui_f\data\sound\RscButton\soundEscape",
		0.090000004,
		1
	};
};

class RscControlsGroup
{
	type=15;
	idc=-1;
	x=0;
	y=0;
	w=1;
	h=1;
	shadow=0;
	style=16;
	class VScrollbar: ScrollBar
	{
		width=0.021;
		autoScrollEnabled=1;
	};
	class HScrollbar: ScrollBar
	{
		height=0.028000001;
	};
	class Controls
	{
	};
};

class IGUIBack
{
	type=0;
	idc=124;
	style=128;
	text="";
	colorText[]={0,0,0,0};
	font="RobotoCondensed";
	sizeEx=0;
	shadow=0;
	x=0.1;
	y=0.1;
	w=0.1;
	h=0.1;
	colorbackground[]=
	{
		"(profilenamespace getvariable ['IGUI_BCG_RGB_R',0])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_G',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_B',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_A',0.8])"
	};
};

class RscFrame
{
	type=0;
	idc=-1;
	deletable=0;
	style=64;
	shadow=2;
	colorBackground[]={0,0,0,0};
	colorText[]={1,1,1,1};
	font="RobotoCondensed";
	sizeEx=0.02;
	text="";
	x=0;
	y=0;
	w=0.30000001;
	h=0.30000001;
};

class RscPicture
{
	type=0;
	idc=-1;
	shadow=0;
	colorText[]={1,1,1,1};
	x=0;
	y=0;
	w=0.2;
	h=0.15000001;
	style=48;
	tooltipColorText[]={1,1,1,1};
	tooltipColorBox[]={1,1,1,1};
	tooltipColorShade[]={0,0,0,0.64999998};
	font = "TahomaB";
	sizeEx = 0;
	colorBackground[] = {0,0,0,0.3};
	colorDisabled[] = {1,1,1,0.25};
};

class RscListBox
{
	idc=-1;
	rowHeight = 0;
	type=5;
	x=0;
	y=0;
	w=0.30000001;
	h=0.30000001;
	style=16;
	font="RobotoCondensed";
	sizeEx="(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	shadow=0;
	colorShadow[]={0,0,0,0.5};
	colorText[]={1,1,1,1};
	colorDisabled[]={1,1,1,0.25};
	colorScrollbar[]={1,0,0,0};
	colorSelect[]={0,0,0,1};
	colorSelect2[]={0,0,0,1};
	colorSelectBackground[]={0.94999999,0.94999999,0.94999999,1};
	colorSelectBackground2[]={1,1,1,0.5};
	period=1.2;
	colorBackground[]={0,0,0,0.30000001};
	maxHistoryDelay=1;
	colorPicture[]={1,1,1,1};
	colorPictureSelected[]={1,1,1,1};
	colorPictureDisabled[]={1,1,1,0.25};
	colorPictureRight[]={1,1,1,1};
	colorPictureRightSelected[]={1,1,1,1};
	colorPictureRightDisabled[]={1,1,1,0.25};
	colorTextRight[]={1,1,1,1};
	colorSelectRight[]={0,0,0,1};
	colorSelect2Right[]={0,0,0,1};
	tooltipColorText[]={1,1,1,1};
	tooltipColorBox[]={1,1,1,1};
	tooltipColorShade[]={0,0,0,0.64999998};
	soundSelect[]=
	{
		"\A3\ui_f\data\sound\RscListbox\soundSelect",
		0.090000004,
		1
	};
	class ListScrollBar: ScrollBar
	{
		color[]={1,1,1,1};
		autoScrollEnabled=1;
	};
};
