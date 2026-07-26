#if defined _mewjam_util_included_
#endinput
#endif
#define _mewjam_util_included_

#include <clients>

stock bool Mewjam_IsFlag(int val, int flag)
{
    return view_as<bool>(val & flag);
}

stock bool Mewjam_IsAlivePlayerInGame(int client)
{
    return Mewjam_IsPlayerInGame(client) && IsPlayerAlive(client);
}

stock bool Mewjam_IsPlayerInGame(int client)
{
    return Mewjam_IsPlayer(client) && IsClientInGame(client);
}

stock bool Mewjam_IsAlivePlayer(int client)
{
    return Mewjam_IsPlayer(client) && IsPlayerAlive(client);
}

stock bool Mewjam_IsPlayer(int client)
{
    return Mewjam_IsClient(client) && !IsFakeClient(client);
}

stock bool Mewjam_IsAliveClientInGame(int client)
{
    return Mewjam_IsClientInGame(client) && IsPlayerAlive(client);
}

stock bool Mewjam_IsClientInGame(int client)
{
    return Mewjam_IsClient(client) && IsClientInGame(client);
}

stock bool Mewjam_IsAliveClient(int client)
{
    return Mewjam_IsClient(client) && IsPlayerAlive(client);
}

stock bool Mewjam_IsClient(int client)
{
    return client >= 1 && client <= MaxClients;
}
