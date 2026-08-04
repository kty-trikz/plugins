#if defined _mewjam_noclip_util_included_
#endinput
#endif
#define _mewjam_noclip_util_included_

#include <entity>
#include <convars>
#include <timers>

#include <mewjam/util>
#include <mewjam/convar>

stock bool Mewjam_TurnNoclip(int client)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return false;
    }

    MoveType movetype = GetEntityMoveType(client);
    if (movetype == MOVETYPE_NOCLIP)
    {
        return false;
    }

    SetEntityMoveType(client, MOVETYPE_NOCLIP);
    return true;
}

stock bool Mewjam_ShutNoclip(int client, MoveType type = MOVETYPE_WALK)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return false;
    }

    MoveType movetype = GetEntityMoveType(client);
    if (movetype != MOVETYPE_NOCLIP)
    {
        return false;
    }

    SetEntityMoveType(client, type);
    return true;
}

stock float Mewjam_UnitsToNoclip(float value)
{
    return value / Mewjam_NoclipFactor();
}

stock float Mewjam_NoclipToUnits(float value)
{
    return value * Mewjam_NoclipFactor();
}

stock float Mewjam_NoclipFactor()
{
    ConVar cvMaxSpeed = FindConVar(MEWJAM_CONVAR_SV_MAXSPEED);
    ConVar cvFriction = FindConVar(MEWJAM_CONVAR_SV_FRICTION);

    float interval = GetTickInterval();
    return cvMaxSpeed.FloatValue - cvMaxSpeed.FloatValue * cvFriction.FloatValue * interval;
}
