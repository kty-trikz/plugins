#if defined _mewjam_info_included_
#endinput
#endif
#define _mewjam_info_included_

#include <mewjam/version>

#if defined MEWJAM_NAME
#error `MEWJAM_NAME` is already defined _X
#endif
#if defined MEWJAM_NAME_LOWER
#error `MEWJAM_NAME_LOWER` is already defined _X
#endif
#if defined MEWJAM_AUTHOR
#error `MEWJAM_AUTHOR` is already defined _X
#endif
#if defined MEWJAM_DESCRIPTION
#error `MEWJAM_DESCRIPTION` is already defined _X
#endif
#if defined MEWJAM_URL
#error `MEWJAM_URL` is already defined _X
#endif
#if defined MEWJAM_VERSION_MAJOR
#error `MEWJAM_VERSION_MAJOR` is already defined _X
#endif
#if defined MEWJAM_VERSION_MINOR
#error `MEWJAM_VERSION_MINOR` is already defined _X
#endif
#if defined MEWJAM_VERSION_PATCH
#error `MEWJAM_VERSION_PATCH` is already defined _X
#endif
#if defined MEWJAM_VERSION_MAJOR_STRING
#error `MEWJAM_VERSION_MAJOR_STRING` is already defined _X
#endif
#if defined MEWJAM_VERSION_MINOR_STRING
#error `MEWJAM_VERSION_MINOR_STRING` is already defined _X
#endif
#if defined MEWJAM_VERSION_PATCH_STRING
#error `MEWJAM_VERSION_PATCH_STRING` is already defined _X
#endif
#if defined MEWJAM_VERSION
#error `MEWJAM_VERSION` is already defined _X
#endif

#define MEWJAM_NAME "Mewjam"
#define MEWJAM_NAME_LOWER "mewjam"
#define MEWJAM_AUTHOR "Mee;w"
#define MEWJAM_DESCRIPTION "Trikz"
#define MEWJAM_URL "https://github.com/kty-trikz/plugins"

#define MEWJAM_VERSION_MAJOR 0
#define MEWJAM_VERSION_MINOR 1
#define MEWJAM_VERSION_PATCH 2

#define MEWJAM_VERSION_MAJOR_STRING "0"
#define MEWJAM_VERSION_MINOR_STRING "1"
#define MEWJAM_VERSION_PATCH_STRING "2"

#define MEWJAM_VERSION MEWJAM_VERSION_IMPL(MEWJAM_VERSION_MAJOR_STRING, MEWJAM_VERSION_MINOR_STRING, MEWJAM_VERSION_PATCH_STRING)
