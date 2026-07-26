#if defined _mewjam_punch_cookie_included_
#endinput
#endif
#define _mewjam_punch_cookie_included_

#include <mewjam/punch/info>

#define MEWJAM_PUNCH_COOKIE_NAME_PREFIX MEWJAM_PUNCH_NAME_LOWER ... "_"

#define MEWJAM_PUNCH_COOKIE_NAME_IMPL(%1) MEWJAM_PUNCH_COOKIE_NAME_PREFIX ... %1
#define MEWJAM_PUNCH_COOKIE_DESCRIPTION_IMPL(%1) "[" ... MEWJAM_PUNCH_NAME ... " @ " ... MEWJAM_PUNCH_AUTHOR ... "] " ... %1

#define MEWJAM_PUNCH_COOKIE_NAME_FALL_ENABLED MEWJAM_PUNCH_COOKIE_NAME_IMPL("fall_enabled")
#define MEWJAM_PUNCH_COOKIE_DESCRIPTION_FALL_ENABLED MEWJAM_PUNCH_COOKIE_DESCRIPTION_IMPL("View Punch/Fall Damage")
#define MEWJAM_PUNCH_COOKIE_UNKNOWN_FALL_ENABLED -1
