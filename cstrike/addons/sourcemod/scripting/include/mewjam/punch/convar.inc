#if defined _mewjam_punch_convar_included_
#endinput
#endif
#define _mewjam_punch_convar_included_

#include <mewjam/punch/info>

#if defined MEWJAM_DAMAGE_CONVAR_FILENAME
#error `MEWJAM_DAMAGE_CONVAR_FILENAME` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_CONVAR_NAME_PREFIX
#error `MEWJAM_DAMAGE_CONVAR_NAME_PREFIX` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_CONVAR_NAME_IMPL
#error `MEWJAM_DAMAGE_CONVAR_NAME_IMPL` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_CONVAR_DESCRIPTION_IMPL
#error `MEWJAM_DAMAGE_CONVAR_DESCRIPTION_IMPL` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_CONVAR_NAME_ENABLED
#error `MEWJAM_DAMAGE_CONVAR_NAME_ENABLED` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_CONVAR_DESCRIPTION_ENABLED
#error `MEWJAM_DAMAGE_CONVAR_DESCRIPTION_ENABLED` is already defined _X
#endif

#define MEWJAM_PUNCH_CONVAR_FILENAME MEWJAM_PUNCH_NAME_LOWER
#define MEWJAM_PUNCH_CONVAR_NAME_PREFIX MEWJAM_PUNCH_NAME_LOWER ... "_"

#define MEWJAM_PUNCH_CONVAR_NAME_IMPL(%1) MEWJAM_PUNCH_CONVAR_NAME_PREFIX ... %1
#define MEWJAM_PUNCH_CONVAR_DESCRIPTION_IMPL(%1) "[" ... MEWJAM_PUNCH_NAME ... " @ " ... MEWJAM_PUNCH_AUTHOR ... "] " ... %1

#define MEWJAM_PUNCH_CONVAR_NAME_FALL_ENABLED MEWJAM_PUNCH_CONVAR_NAME_IMPL("fall_enabled")
#define MEWJAM_PUNCH_CONVAR_DESCRIPTION_FALL_ENABLED MEWJAM_PUNCH_CONVAR_DESCRIPTION_IMPL("Toggle the fall punch globally (`0`: Disable | `1`: Enable)")
