#if defined _mewjam_punch_info_included_
#endinput
#endif
#define _mewjam_punch_info_included_

#include <mewjam/version>

#if defined MEWJAM_PUNCH_NAME
#error `MEWJAM_PUNCH_NAME` is already defined _X
#endif
#if defined MEWJAM_PUNCH_NAME_LOWER
#error `MEWJAM_PUNCH_NAME_LOWER` is already defined _X
#endif
#if defined MEWJAM_PUNCH_AUTHOR
#error `MEWJAM_PUNCH_AUTHOR` is already defined _X
#endif
#if defined MEWJAM_PUNCH_DESCRIPTION
#error `MEWJAM_PUNCH_DESCRIPTION` is already defined _X
#endif
#if defined MEWJAM_PUNCH_URL
#error `MEWJAM_PUNCH_URL` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_MAJOR
#error `MEWJAM_PUNCH_VERSION_MAJOR` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_MINOR
#error `MEWJAM_PUNCH_VERSION_MINOR` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_PATCH
#error `MEWJAM_PUNCH_VERSION_PATCH` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_MAJOR_STRING
#error `MEWJAM_PUNCH_VERSION_MAJOR_STRING` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_MINOR_STRING
#error `MEWJAM_PUNCH_VERSION_MINOR_STRING` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION_PATCH_STRING
#error `MEWJAM_PUNCH_VERSION_PATCH_STRING` is already defined _X
#endif
#if defined MEWJAM_PUNCH_VERSION
#error `MEWJAM_PUNCH_VERSION` is already defined _X
#endif

#define MEWJAM_PUNCH_NAME "Mewjam/Punch"
#define MEWJAM_PUNCH_NAME_LOWER "mewjam_punch"
#define MEWJAM_PUNCH_AUTHOR "Mee;w"
#define MEWJAM_PUNCH_DESCRIPTION "Removes player fall view punch"
#define MEWJAM_PUNCH_URL "https://github.com/kty-trikz/plugins"

#define MEWJAM_PUNCH_VERSION_MAJOR 0
#define MEWJAM_PUNCH_VERSION_MINOR 1
#define MEWJAM_PUNCH_VERSION_PATCH 0

#define MEWJAM_PUNCH_VERSION_MAJOR_STRING "0"
#define MEWJAM_PUNCH_VERSION_MINOR_STRING "1"
#define MEWJAM_PUNCH_VERSION_PATCH_STRING "0"

#define MEWJAM_PUNCH_VERSION MEWJAM_VERSION_IMPL(MEWJAM_PUNCH_VERSION_MAJOR_STRING, MEWJAM_PUNCH_VERSION_MINOR_STRING, MEWJAM_PUNCH_VERSION_PATCH_STRING)
