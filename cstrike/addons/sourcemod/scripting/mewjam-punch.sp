#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/util>
#include <mewjam/chat>

#include <mewjam/damage/util>

#include <mewjam/punch/info>
#include <mewjam/punch/convar>
#include <mewjam/punch/cookie>
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

ConVar g_cvPunchFallEnabled;

Cookie g_ckPunchFallEnabled;

int g_iPunchFallEnabled[MAXPLAYERS + 1];

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

    Mewjam_CreateCookies();
    Mewjam_CreateCommands();

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
    SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

static void Hook_OnTakeDamagePost(int client, int attacker, int inflictor, float damage, int type)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    bool bFallPunch = g_iPunchFallEnabled[client] == 1;
    if (g_iPunchFallEnabled[client] == MEWJAM_PUNCH_COOKIE_UNKNOWN_FALL_ENABLED)
    {
        bFallPunch = g_cvPunchFallEnabled.IntValue == 1;
    }
    if (bFallPunch || !Mewjam_IsFallDamage(type))
    {
        return;
    }

    RequestFrame(Frame_ResetViewPunch, GetClientSerial(client));
}

static void Frame_ResetViewPunch(int serial)
{
    int client = GetClientFromSerial(serial);
    Mewjam_ResetViewPunch(client);
}

static Action Command_Punch(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    int iPunchFall = g_iPunchFallEnabled[client];
    if (iPunchFall == MEWJAM_PUNCH_COOKIE_UNKNOWN_FALL_ENABLED)
    {
        iPunchFall = g_cvPunchFallEnabled.IntValue;
    }
    g_iPunchFallEnabled[client] = view_as<int>(!(iPunchFall == 1));
    g_ckPunchFallEnabled.SetInt(client, g_iPunchFallEnabled[client]);

    if (view_as<bool>(g_iPunchFallEnabled[client]))
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_FALL_PUNCH_ENABLE, client, MEWJAM_MESSAGE_TYPE_PUNCH_PARAMS);
    }
    else
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_FALL_PUNCH_DISABLE, client, MEWJAM_MESSAGE_TYPE_PUNCH_PARAMS);
    }

    return Plugin_Handled;
}

static void Mewjam_InitStateVars(int client)
{
    g_iPunchFallEnabled[client] = g_ckPunchFallEnabled.GetInt(client, MEWJAM_PUNCH_COOKIE_UNKNOWN_FALL_ENABLED);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_PUNCH_NAME);
    Mewjam_OnValidEnviron(MEWJAM_PUNCH_NAME);
}

static void Mewjam_CreateConVars()
{
    g_cvPunchFallEnabled = CreateConVar(MEWJAM_PUNCH_CONVAR_NAME_FALL_ENABLED, "0", MEWJAM_PUNCH_CONVAR_DESCRIPTION_FALL_ENABLED, _, true, 0.0, true, 1.0);
}

static void Mewjam_CreateCookies()
{
    g_ckPunchFallEnabled = RegClientCookie(MEWJAM_PUNCH_COOKIE_NAME_FALL_ENABLED, MEWJAM_PUNCH_COOKIE_DESCRIPTION_FALL_ENABLED, CookieAccess_Protected);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_punch", Command_Punch);
}
