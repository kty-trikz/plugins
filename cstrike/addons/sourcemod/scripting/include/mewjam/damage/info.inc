#if defined _mewjam_damage_info_included_
#endinput
#endif
#define _mewjam_damage_info_included_

#include <mewjam/version>

#if defined MEWJAM_DAMAGE_NAME
#error `MEWJAM_DAMAGE_NAME` is already defined _X
#endif
#if defined MEWJMA_DAMAGE_NAME_LOWER
#error `MEWJAM_DAMAGE_NAME_LOWER` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_AUTHOR
#error `MEWJAM_DAMAGE_AUTHOR` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_DESCRIPTION
#error `MEWJAM_DAMAGE_DESCRIPTION` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_URL
#error `MEWJAM_DAMAGE_URL` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_MAJOR
#error `MEWJAM_DAMAGE_VERSION_MAJOR` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_MINOR
#error `MEWJAM_DAMAGE_VERSION_MINOR` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_PATCH
#error `MEWJAM_DAMAGE_VERSION_PATCH` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_MAJOR_STRING
#error `MEWJAM_DAMAGE_VERSION_MAJOR_STRING` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_MINOR_STRING
#error `MEWJAM_DAMAGE_VERSION_MINOR_STRING` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION_PATCH_STRING
#error `MEWJAM_DAMAGE_VERSION_PATCH_STRING` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_VERSION
#error `MEWJAM_DAMAGE_VERSION` is already defined _X
#endif

#define MEWJAM_DAMAGE_NAME "Mewjam/Damage"
#define MEWJAM_DAMAGE_NAME_LOWER "mewjam_damage"
#define MEWJAM_DAMAGE_AUTHOR "Mee;w"
#define MEWJAM_DAMAGE_DESCRIPTION "Removes damage by its type"
#define MEWJAM_DAMAGE_URL "https://github.com/kty-trikz/plugins"

#define MEWJAM_DAMAGE_VERSION_MAJOR 0
#define MEWJAM_DAMAGE_VERSION_MINOR 2
#define MEWJAM_DAMAGE_VERSION_PATCH 0

#define MEWJAM_DAMAGE_VERSION_MAJOR_STRING "0"
#define MEWJAM_DAMAGE_VERSION_MINOR_STRING "2"
#define MEWJAM_DAMAGE_VERSION_PATCH_STRING "0"

#define MEWJAM_DAMAGE_VERSION MEWJAM_VERSION_IMPL(MEWJAM_DAMAGE_VERSION_MAJOR_STRING, MEWJAM_DAMAGE_VERSION_MINOR_STRING, MEWJAM_DAMAGE_VERSION_PATCH_STRING)
