#include <sourcemod>
#include <clients>
#include <cstrike>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/chat>
#include <mewjam/util>
#include <mewjam/event>

#include <mewjam/respawn/info>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_RESPAWN_NAME,
    author = MEWJAM_RESPAWN_AUTHOR,
    description = MEWJAM_RESPAWN_DESCRIPTION,
    version = MEWJAM_RESPAWN_VERSION,
    url = MEWJAM_RESPAWN_URL
};

bool g_bLateLoaded = false;

bool g_bNoRespawn[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_HookEvents();

    if (!g_bLateLoaded)
    {
        return;
    }
    for (int client = 1; client <= MaxClients; ++client)
    {
        if (IsClientInGame(client))
        {
            OnClientPutInServer(client);
        }
    }
}

public void OnClientPutInServer(int client)
{
    g_bNoRespawn[client] = false;
}

static void Event_PlayerTeam(Event event, const char[] name, bool bNoBroadcast)
{
    if (event == INVALID_HANDLE)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Mewjam_IsPlayerInGame(client))
    {
        return;
    }

    g_bNoRespawn[client] = true;
}

static void Event_PlayerDeath(Event event, const char[] name, bool bNoBroadcast)
{
    if (event == INVALID_HANDLE)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Mewjam_IsPlayerInGame(client))
    {
        return;
    }

    int team = GetClientTeam(client);
    if (team != 2 && team != 3)
    {
        return;
    }

    RequestFrame(Frame_RespawnPlayer, GetClientUserId(client));
}

static void Frame_RespawnPlayer(int userid)
{
    int client = GetClientOfUserId(userid);
    if (!Mewjam_IsPlayerInGame(client))
    {
        return;
    }

    if (!g_bNoRespawn[client])
    {
        CS_RespawnPlayer(client);
    }
    g_bNoRespawn[client] = false;
}

static void Mewjam_HookEvents()
{
    HookEvent(MEWJAM_EVENT_PLAYER_TEAM, Event_PlayerTeam, EventHookMode_Post);
    HookEvent(MEWJAM_EVENT_PLAYER_DEATH, Event_PlayerDeath, EventHookMode_Post);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_RESPAWN_NAME);
    Mewjam_OnValidEnviron(MEWJAM_RESPAWN_NAME);
}
