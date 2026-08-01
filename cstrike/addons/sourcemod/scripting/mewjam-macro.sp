#include <sourcemod>
#include <clientprefs>
#include <string>
#include <float>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/chat>
#include <mewjam/prop>
#include <mewjam/classname>
#include <mewjam/flag>
#include <mewjam/util>

#include <mewjam/macro/info>
#include <mewjam/macro/cookie>

#pragma newdecls required
#pragma semicolon 1

#define _MEWJAM_MACRO_UNKNOWN_TICK_PULL -1
#define _MEWJAM_MACRO_UNKNOWN_TICK_THROW -1

public Plugin myinfo = {
    name = MEWJAM_MACRO_NAME,
    author = MEWJAM_MACRO_AUTHOR,
    description = MEWJAM_MACRO_DESCRIPTION,
    version = MEWJAM_MACRO_VERSION,
    url = MEWJAM_MACRO_URL
};

bool g_bLateLoaded = false;

Cookie g_ckNjTickDelay;
Cookie g_ckMacroEnabled;
Cookie g_ckNjMacroEnabled;

bool g_bMacroEnabled[MAXPLAYERS + 1];
bool g_bNjMacroEnabled[MAXPLAYERS + 1];

int g_iTickPull[MAXPLAYERS + 1];

int g_iNjTickDelay[MAXPLAYERS + 1];
int g_iNjTickPull[MAXPLAYERS + 1];

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

    g_iTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
    g_iNjTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return Plugin_Continue;
    }

    int cweapon = GetEntPropEnt(client, Prop_Send, MEWJAM_PROP_M_HACTIVEWEAPON);
    if (weapon == -1 || !IsValidEntity(cweapon))
    {
        return Plugin_Continue;
    }

    char szClassName[128];
    GetEntityClassname(cweapon, szClassName, sizeof(szClassName));
    if (!StrEqual(szClassName, MEWJAM_CLASSNAME_WEAPON_FLASHBANG))
    {
        return Plugin_Continue;
    }

    int tickbase = GetEntProp(client, Prop_Send, MEWJAM_PROP_M_NTICKBASE);
    int nextattack = RoundToCeil(GetEntPropFloat(client, Prop_Send, MEWJAM_PROP_M_FLNEXTATTACK) / GetTickInterval());

    if (g_bNjMacroEnabled[client])
    {
        if (Mewjam_IsFlag(buttons, MEWJAM_BUTTON_IN_ATTACK) && nextattack <= tickbase)
        {
            if (g_iNjTickPull[client] == _MEWJAM_MACRO_UNKNOWN_TICK_PULL)
            {
                g_iNjTickPull[client] = tickbase;
            }
        }

        if (g_iNjTickPull[client] != _MEWJAM_MACRO_UNKNOWN_TICK_PULL)
        {
            if (g_iNjTickPull[client] + g_iNjTickDelay[client] <= tickbase)
            {
                buttons &= ~MEWJAM_BUTTON_IN_ATTACK;
                g_iNjTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
            }
        }
    }
    else
    {
        g_iNjTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
    }

    if (g_bMacroEnabled[client])
    {
        int flags = GetEntProp(client, Prop_Send, MEWJAM_PROP_M_FFLAGS);
        int throwTick = RoundToCeil(GetEntPropFloat(cweapon, Prop_Send, MEWJAM_PROP_M_FTHROWTIME) / GetTickInterval() - 0.001);

        if (Mewjam_IsFlag(flags, MEWJAM_FLAG_ON_GROUND) && Mewjam_IsFlag(buttons, MEWJAM_BUTTON_IN_ATTACK2) && nextattack <= tickbase)
        {
            if (g_iTickPull[client] == _MEWJAM_MACRO_UNKNOWN_TICK_PULL && throwTick <= 0)
            {
                buttons |= MEWJAM_BUTTON_IN_ATTACK;
                buttons &= ~MEWJAM_BUTTON_IN_ATTACK2;
                g_iTickPull[client] = tickbase;
            }
        }

        if (g_iTickPull[client] != _MEWJAM_MACRO_UNKNOWN_TICK_PULL)
        {
            if (g_iTickPull[client] + 1 <= tickbase)
            {
                buttons &= ~MEWJAM_BUTTON_IN_ATTACK;
                g_iTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
            }
        }

        if (throwTick > 0 && throwTick <= tickbase)
        {
            buttons |= MEWJAM_BUTTON_IN_JUMP;
        }
    }
    else
    {
        g_iTickPull[client] = _MEWJAM_MACRO_UNKNOWN_TICK_PULL;
    }

    return Plugin_Continue;
}

static Action Command_Macro(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    g_bMacroEnabled[client] = !g_bMacroEnabled[client];
    g_ckMacroEnabled.SetInt(client, view_as<int>(g_bMacroEnabled[client]));

    if (g_bMacroEnabled[client])
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_MACRO_ENABLE, client, MEWJAM_MESSAGE_TOGGLE_MACRO_PARAMS);
    }
    else
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_MACRO_DISABLE, client, MEWJAM_MESSAGE_TOGGLE_MACRO_PARAMS);
    }

    return Plugin_Handled;
}

static Action Command_NjMacro(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    g_bNjMacroEnabled[client] = !g_bNjMacroEnabled[client];
    g_ckNjMacroEnabled.SetInt(client, view_as<int>(g_bNjMacroEnabled[client]));

    if (g_bNjMacroEnabled[client])
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NJ_MACRO_ENABLE, client, MEWJAM_MESSAGE_TOGGLE_MACRO_PARAMS);
    }
    else
    {
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NJ_MACRO_DISABLE, client, MEWJAM_MESSAGE_TOGGLE_MACRO_PARAMS);
    }

    return Plugin_Handled;
}

static void Mewjam_InitStateVars(int client)
{
    g_bMacroEnabled[client] = view_as<bool>(g_ckMacroEnabled.GetInt(client, MEWJAM_MACRO_COOKIE_DEFAULT_MACRO_ENABLED));
    g_iNjTickDelay[client] = g_ckNjTickDelay.GetInt(client, MEWJAM_MACRO_COOKIE_DEFAULT_NJ_TICK_DELAY);
    g_bNjMacroEnabled[client] = view_as<bool>(g_ckNjMacroEnabled.GetInt(client, MEWJAM_MACRO_COOKIE_DEFAULT_NJ_MACRO_ENABLED));
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_MACRO_NAME);
    Mewjam_OnValidEnviron(MEWJAM_MACRO_NAME);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_macro", Command_Macro);
    RegConsoleCmd("sm_nj", Command_NjMacro);
}

static void Mewjam_CreateCookies()
{
    g_ckMacroEnabled = RegClientCookie(MEWJAM_MACRO_COOKIE_NAME_MACRO_ENABLED, MEWJAM_MACRO_COOKIE_DESCRIPTION_MACRO_ENABLED, CookieAccess_Protected);
    g_ckNjTickDelay = RegClientCookie(MEWJAM_MACRO_COOKIE_NAME_NJ_TICK_DELAY, MEWJAM_MACRO_COOKIE_DESCRIPTION_NJ_TICK_DELAY, CookieAccess_Protected);
    g_ckNjMacroEnabled = RegClientCookie(MEWJAM_MACRO_COOKIE_NAME_NJ_MACRO_ENABLED, MEWJAM_MACRO_COOKIE_DESCRIPTION_NJ_MACRO_ENABLED, CookieAccess_Protected);
}
