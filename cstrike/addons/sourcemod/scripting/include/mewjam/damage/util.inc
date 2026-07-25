#if defined _mewjam_damage_util_included_
#endinput
#endif
#define _mewjam_damage_util_included_

#include <mewjam/util>
#include <mewjam/damage/flag>

stock bool Mewjam_IsBulletDamage(int val)
{
    return Mewjam_IsFlag(val, MEWJAM_DAMAGE_TYPE_BULLET);
}

stock bool Mewjam_IsBurnDamage(int val)
{
    return Mewjam_IsFlag(val, MEWJAM_DAMAGE_TYPE_BURN);
}

stock bool Mewjam_IsFallDamage(int val)
{
    return Mewjam_IsFlag(val, MEWJAM_DAMAGE_TYPE_FALL);
}

stock bool Mewjam_IsBlastDamage(int val)
{
    return Mewjam_IsFlag(val, MEWJAM_DAMAGE_TYPE_BLAST);
}

stock bool Mewjam_IsDrownDamage(int val)
{
    return Mewjam_IsFlag(val, MEWJAM_DAMAGE_TYPE_DROWN);
}
