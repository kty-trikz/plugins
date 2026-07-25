#if defined _mewjam_menu_included_
#endinput
#endif
#define _mewjam_menu_included_

#if defined MEWJAM_MENU_ITEM_TRUE
#error `MEWJAM_MENU_ITEM_TRUE` is already defined _X
#endif
#if defined MEWJAM_MENU_ITEM_FALSE
#error `MEWJAM_MENU_ITEM_FALSE` is already defined _X
#endif

#define MEWJAM_MENU_ITEM_TRUE "Enabled"
#define MEWJAM_MENU_ITEM_FALSE "Disabled"
