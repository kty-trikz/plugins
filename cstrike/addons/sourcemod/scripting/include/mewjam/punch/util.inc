#if defined _mewjam_punch_util_included_
#endinput
#endif
#define _mewjam_punch_util_included_

#include <sourcemod>

#include <mewjam/punch/prop>
#include <mewjam/util>

stock bool Mewjam_ResetViewPunch(int client)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return false;
    }
    if (!HasEntProp(client, Prop_Send, MEWJAM_PUNCH_VEC_ANGLE))
    {
        return false;
    }
    if (!HasEntProp(client, Prop_Send, MEWJAM_PUNCH_VEC_ANGLE_VEL))
    {
        return false;
    }

    static float zero[3] = {0.0, 0.0, 0.0};

    SetEntPropVector(client, Prop_Send, MEWJAM_PUNCH_VEC_ANGLE, zero);
    SetEntPropVector(client, Prop_Send, MEWJAM_PUNCH_VEC_ANGLE_VEL, zero);
    return true;
}
