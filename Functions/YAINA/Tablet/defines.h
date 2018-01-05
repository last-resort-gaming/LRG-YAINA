
#include "..\defines.h"

#define PREFIX  YAINA_TABLET
#define FNC(s)  ##PREFIX##_fnc_##s
#define GVAR(s) ##PREFIX##_##s
#define QVAR(s) Q(GVAR(s))

///////////////////////////////////////////////////////////
// CONFIGURE dialog IDD + page IDCs
///////////////////////////////////////////////////////////

#define IDD_TABLET        90210

#define IDC_PAGE_REQUESTS 90211
#define IDC_PAGE_MESSAGE  90212
#define IDC_PAGE_AMMOBOX  90213
#define IDC_PAGE_REWARDS  90214
#define IDC_PAGES         [IDC_PAGE_REQUESTS, IDC_PAGE_MESSAGE, IDC_PAGE_AMMOBOX, IDC_PAGE_REWARDS]
