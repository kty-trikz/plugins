#include <sourcemod>
#include <sdkhooks>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/util>

#include <mewjam/damage/util>

#include <mewjam/punch/info>
#include <mewjam/punch/convar>
#include <mewjam/punch/prop>
#include <mewjam/punch/util>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_PUNCH_NAME,
    author = MEWJAM_PUNCH_AUTHOR,
    description = MEWJAM_PUNCH_DESCRIPTION,
    version = MEWJAM_PUNCH_VERSION,
    url = MEWJAM_PUNCH_URL
};

bool g_bLateLoaded = false;
ConVar g_cvMewjamPunchFallEnabled;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_CreateConVars();

    AutoExecConfig(true, MEWJAM_PUNCH_CONVAR_FILENAME);

    if (!g_bLateLoaded)
    {
        return;
    }
    for (int client = 1; client <= MaxClients; ++client)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }
        OnClientPutInServer(client);
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
}

static void Hook_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int type)
{
    if (!Mewjam_IsAlivePlayerInGame(victim))
    {
        return;
    }
    if (g_cvMewjamPunchFallEnabled.IntValue != 0)
    {
        return;
    }
    if (!Mewjam_IsFallDamage(type))
    {
        return;
    }

    RequestFrame(Frame_ResetViewPunch, GetClientSerial(victim));
}

static void Frame_ResetViewPunch(int serial)
{
    int client = GetClientFromSerial(serial);
    Mewjam_ResetViewPunch(client);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_PUNCH_NAME);
    Mewjam_OnValidEnviron(MEWJAM_PUNCH_NAME);
}

static void Mewjam_CreateConVars()
{
    g_cvMewjamPunchFallEnabled = CreateConVar(MEWJAM_PUNCH_CONVAR_NAME_FALL_ENABLED, "0", MEWJAM_PUNCH_CONVAR_DESCRIPTION_FALL_ENABLED, _, true, 0.0, true, 1.0);
}
