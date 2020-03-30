/*
	These elements are copied and pasted from
	a3\ui_f\config.cpp as they are used in other
	sections
*/

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
