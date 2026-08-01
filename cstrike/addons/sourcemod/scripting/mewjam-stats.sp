#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <halflife>
#include <console>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/prop>
#include <mewjam/event>
#include <mewjam/chat>
#include <mewjam/util>

#include <mewjam/stats/info>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_STATS_NAME,
    author = MEWJAM_STATS_AUTHOR,
    description = MEWJAM_STATS_DESCRIPTION,
    version = MEWJAM_STATS_VERSION,
    url = MEWJAM_STATS_URL
};

bool g_bLateLoaded = false;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_CreateCookies();
    Mewjam_CreateCommands();
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
        if (AreClientCookiesCached(client))
        {
            OnClientCookiesCached(client);
        }
    }
}

public void OnClientPutInServer(int client)
{
    Mewjam_InitStateVars(client);
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

public void OnEntityCreated(int entity, const char[] className)
{
    if (!IsValidEntity(entity))
    {
        return;
    }

    SDKHook(entity, SDKHook_SpawnPost, Hook_SpawnPost);
}

static void Hook_SpawnPost(int entity)
{
    if (!IsValidEntity(entity))
    {
        return;
    }

    if (!HasEntProp(entity, Prop_Send, MEWJAM_PROP_M_HOWNERENTITY))
    {
        return;
    }

    int client = GetEntPropEnt(entity, Prop_Send, MEWJAM_PROP_M_HOWNERENTITY);
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    char szClassName[128];
    GetEntityClassname(entity, szClassName, sizeof(szClassName));

    Mewjam_SayText2(client, "[#%i @ %i] Hook_SpawnPost :: %s", client, GetGameTickCount(), szClassName);
}

static void Event_WeaponFire(Event event, const char[] name, bool bNoBroadcast)
{
    if (event == INVALID_HANDLE)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    char szWeapon[128];
    event.GetString("weapon", szWeapon, sizeof(szWeapon));

    Mewjam_SayText2(client, "[#%i @ %i] Event_WeaponFire :: %s", client, GetGameTickCount(), szWeapon);
}

static void Event_PlayerJump(Event event, const char[] name, bool bNoBroadcast)
{
    if (event == INVALID_HANDLE)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    Mewjam_SayText2(client, "[#%i @ %i] Event_PlayerJump", client, GetGameTickCount());
}

static void Mewjam_InitStateVars(int client)
{

}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_STATS_NAME);
    Mewjam_OnValidEnviron(MEWJAM_STATS_NAME);
}

static void Mewjam_CreateCookies()
{
}

static void Mewjam_CreateCommands()
{
}

static void Mewjam_HookEvents()
{
    HookEvent(MEWJAM_EVENT_WEAPON_FIRE, Event_WeaponFire, EventHookMode_Post);
    HookEvent(MEWJAM_EVENT_PLAYER_JUMP, Event_PlayerJump, EventHookMode_Post);
}
