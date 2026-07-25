#if defined _mewjam_damage_flag_included_
#endinput
#endif
#define _mewjam_damage_flag_included_

#if defined MEWJAM_DAMAGE_TYPE_BULLET
#error `MEWJAM_DAMAGE_TYPE_BULLET` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_TYPE_BURN
#error `MEWJAM_DAMAGE_TYPE_BURN` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_TYPE_FALL
#error `MEWJAM_DAMAGE_TYPE_FALL` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_TYPE_BLAST
#error `MEWJAM_DAMAGE_TYPE_BLAST` is already defined _X
#endif
#if defined MEWJAM_DAMAGE_TYPE_DROWN
#error `MEWJAM_DAMAGE_TYPE_DROWN` is already defined _X
#endif

#define MEWJAM_DAMAGE_TYPE_BULLET (1 << 1)
#define MEWJAM_DAMAGE_TYPE_BURN (1 << 3)
#define MEWJAM_DAMAGE_TYPE_FALL (1 << 5)
#define MEWJAM_DAMAGE_TYPE_BLAST (1 << 6)
#define MEWJAM_DAMAGE_TYPE_DROWN (1 << 14)
