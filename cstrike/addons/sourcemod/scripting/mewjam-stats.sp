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
#include <mewjam/classname>
#include <mewjam/flag>
#include <mewjam/menu>
#include <mewjam/color>

#include <mewjam/stats/info>
#include <mewjam/stats/cookie>

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

Cookie g_ckThrowSpeed;
Cookie g_ckThrowAngle;
Cookie g_ckThrowTime;
Cookie g_ckShortNames;
Cookie g_ckColorValues;

int g_iThrowSpeed[MAXPLAYERS + 1];
int g_iThrowAngle[MAXPLAYERS + 1];
int g_iThrowTime[MAXPLAYERS + 1];
int g_iShortNames[MAXPLAYERS + 1];
int g_iColorValues[MAXPLAYERS + 1];

int g_iThrowReleaseTick[MAXPLAYERS + 1];
int g_iThrowJumpTick[MAXPLAYERS + 1];

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
    g_iThrowReleaseTick[client] = -1;
    g_iThrowJumpTick[client] = -1;

    Mewjam_InitStateVars(client);
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    int flags = GetEntProp(client, Prop_Data, MEWJAM_PROP_M_FFLAGS);
    if (Mewjam_IsFlag(flags, MEWJAM_FLAG_ON_GROUND))
    {
        g_iThrowJumpTick[client] = -1;
    }
}

public void OnEntityCreated(int entity, const char[] className)
{
    if (!IsValidEntity(entity))
    {
        return;
    }

    char szClassName[128];
    GetEntityClassname(entity, szClassName, sizeof(szClassName));
    if (!StrEqual(szClassName, MEWJAM_CLASSNAME_PROJECTILE_FLASHBANG))
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
    if (!StrEqual(szClassName, MEWJAM_CLASSNAME_PROJECTILE_FLASHBANG))
    {
        return;
    }

    float angles[3];
    GetClientEyeAngles(client, angles);
    float pitch = FloatAbs(angles[0]);

    float velocity[3];
    GetEntPropVector(client, Prop_Data, MEWJAM_PROP_M_VECVELOCITY, velocity);
    velocity[2] = 0.0;
    float speed = GetVectorLength(velocity);

    int tick = 0;
    if (g_iThrowJumpTick[client] != -1)
    {
        tick = GetEntProp(client, Prop_Send, MEWJAM_PROP_M_NTICKBASE) - g_iThrowJumpTick[client];
        if (tick <= 1)
        {
            tick = 0;
        }
        else
        {
            tick -= 1;
        }
    }
    float time = tick * GetTickInterval();

#define _MEWJAM_STATS_ELEMENT_SIZE 64
    char szThrowSpeed[_MEWJAM_STATS_ELEMENT_SIZE] = "";
    char szThrowAngle[_MEWJAM_STATS_ELEMENT_SIZE] = "";
    char szThrowTime[_MEWJAM_STATS_ELEMENT_SIZE] = "";

    bool bShortNames = view_as<bool>(g_iShortNames[client]);
    bool bColorValues = view_as<bool>(g_iColorValues[client]);
    if (view_as<bool>(g_iThrowSpeed[client]))
    {
        bool bDucked = view_as<bool>(GetEntProp(client, Prop_Data, MEWJAM_PROP_M_BDUCKED));
        if (bDucked)
        {
            if (bColorValues)
            {
                int color[3];
                TransColor(speed / 85.0 * 100.0, color);

                char szColor[16];
                FormatEx(szColor, sizeof(szColor), "\x07%02X%02X%02X", color[0], color[1], color[2]);

                if (bShortNames)
                {
                    FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_SHORT_CROUCH_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, speed));
                }
                else
                {
                    FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_CROUCH_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, speed));
                }
            }
            else if (bShortNames)
            {
                FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_SHORT_CROUCH_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(speed));
            }
            else
            {
                FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_CROUCH_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(speed));
            }
        }
        else if (bColorValues)
        {
            int color[3];
            TransColor(speed / 250.0 * 100.0, color);

            char szColor[16];
            FormatEx(szColor, sizeof(szColor), "\x07%02X%02X%02X", color[0], color[1], color[2]);

            if (bShortNames)
            {
                FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_SHORT_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, speed));
            }
            else
            {
                FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, speed));
            }
        }
        else if (bShortNames)
        {
            FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_SHORT_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(speed));
        }
        else
        {
            FormatEx(szThrowSpeed, sizeof(szThrowSpeed), "%T", MEWJAM_MESSAGE_THROW_SPEED, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(speed));
        }
    }
    if (view_as<bool>(g_iThrowAngle[client]))
    {
        if (bColorValues)
        {
            int color[3];
            TransColor(100.0, color);

            char szColor[16];
            FormatEx(szColor, sizeof(szColor), "\x07%02X%02X%02X", color[0], color[1], color[2]);

            if (bShortNames)
            {
                FormatEx(szThrowAngle, sizeof(szThrowAngle), "%T", MEWJAM_MESSAGE_SHORT_THROW_ANGLE, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, pitch));
            }
            else
            {
                FormatEx(szThrowAngle, sizeof(szThrowAngle), "%T", MEWJAM_MESSAGE_THROW_ANGLE, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, pitch));
            }
        }
        else if (bShortNames)
        {
            FormatEx(szThrowAngle, sizeof(szThrowAngle), "%T", MEWJAM_MESSAGE_SHORT_THROW_ANGLE, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(pitch));
        }
        else
        {
            FormatEx(szThrowAngle, sizeof(szThrowAngle), "%T", MEWJAM_MESSAGE_THROW_ANGLE, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(pitch));
        }
    }
    if (view_as<bool>(g_iThrowTime[client]))
    {
        if (bColorValues)
        {
            int color[3];
            TransColor(100.0 - time / 0.1 * 100.0, color);

            char szColor[16];
            FormatEx(szColor, sizeof(szColor), "\x07%02X%02X%02X", color[0], color[1], color[2]);

            if (bShortNames)
            {
                FormatEx(szThrowTime, sizeof(szThrowTime), "%T", MEWJAM_MESSAGE_SHORT_THROW_TIME, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, time));
            }
            else
            {
                FormatEx(szThrowTime, sizeof(szThrowTime), "%T", MEWJAM_MESSAGE_THROW_TIME, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS_EX(szColor, time));
            }
        }
        else if (bShortNames)
        {
            FormatEx(szThrowTime, sizeof(szThrowTime), "%T", MEWJAM_MESSAGE_SHORT_THROW_TIME, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(time));
        }
        else
        {
            FormatEx(szThrowTime, sizeof(szThrowTime), "%T", MEWJAM_MESSAGE_THROW_TIME, client, MEWJAM_MESSAGE_THROW_STAT_PARAMS(time));
        }
    }

    char elements[3][_MEWJAM_STATS_ELEMENT_SIZE];

    int length = 0;
    if (szThrowSpeed[0] != '\0')
    {
        strcopy(elements[length++], _MEWJAM_STATS_ELEMENT_SIZE, szThrowSpeed);
    }
    if (szThrowAngle[0] != '\0')
    {
        strcopy(elements[length++], _MEWJAM_STATS_ELEMENT_SIZE, szThrowAngle);
    }
    if (szThrowTime[0] != '\0')
    {
        strcopy(elements[length++], _MEWJAM_STATS_ELEMENT_SIZE, szThrowTime);
    }
#undef _MEWJAM_STATS_ELEMENT_SIZE

    char szMessage[256] = "";
    for (int i = 0; i < length; ++i)
    {
        if (i >= 1)
        {
            Format(szMessage, sizeof(szMessage), "%s%s | ", szMessage, MEWJAM_CHAT_COLOR_GRAY);
        }
        Format(szMessage, sizeof(szMessage), "%s%s", szMessage, elements[i]);
    }

    if (szMessage[0] == '\0')
    {
        return;
    }

    Format(szMessage, sizeof(szMessage), "%s%s", MEWJAM_CHAT_PREFIX, szMessage);
    Mewjam_SayText2(client, szMessage);

    g_iThrowReleaseTick[client] = -1;
    g_iThrowJumpTick[client] = -1;
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
    if (!StrEqual(szWeapon, MEWJAM_EVENT_WEAPON_FLASHBANG))
    {
        return;
    }

    g_iThrowReleaseTick[client] = GetEntProp(client, Prop_Send, MEWJAM_PROP_M_NTICKBASE);
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

    g_iThrowJumpTick[client] = GetEntProp(client, Prop_Send, MEWJAM_PROP_M_NTICKBASE);
}

static Action Command_Stats(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    Menu_Stats(client);
    return Plugin_Handled;
}

static void Menu_Stats(int client)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    Menu menu = new Menu(MenuHandler_Stats);
    menu.SetTitle("[%s @ %s]\n ", MEWJAM_STATS_NAME, MEWJAM_STATS_AUTHOR);

    char szItem[64];
    FormatEx(szItem, sizeof(szItem), "Throw Speed [%s]", view_as<bool>(g_iThrowSpeed[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("speed", szItem);

    FormatEx(szItem, sizeof(szItem), "Throw Angle [%s]", view_as<bool>(g_iThrowAngle[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("angle", szItem);

    FormatEx(szItem, sizeof(szItem), "Throw Time [%s]\n ", view_as<bool>(g_iThrowTime[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("time", szItem);

    FormatEx(szItem, sizeof(szItem), "Short Names [%s]", view_as<bool>(g_iShortNames[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("short", szItem);

    FormatEx(szItem, sizeof(szItem), "Color Values [%s]", view_as<bool>(g_iColorValues[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("color", szItem);

    menu.ExitBackButton = false;
    menu.ExitButton = true;

    menu.Display(client, MENU_TIME_FOREVER);
}

static void MenuHandler_Stats(Menu menu, MenuAction action, int client, int index)
{
    if (action == MenuAction_End)
    {
        delete menu;
        return;
    }
    if (action != MenuAction_Select)
    {
        return;
    }
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    char szInfo[16];
    if (!menu.GetItem(index, szInfo, sizeof(szInfo)))
    {
        return;
    }

    if (StrEqual(szInfo, "speed"))
    {
        g_iThrowSpeed[client] = view_as<int>(!(g_iThrowSpeed[client] == 1));
        g_ckThrowSpeed.SetInt(client, g_iThrowSpeed[client]);
    }
    else if (StrEqual(szInfo, "angle"))
    {
        g_iThrowAngle[client] = view_as<int>(!(g_iThrowAngle[client] == 1));
        g_ckThrowAngle.SetInt(client, g_iThrowAngle[client]);
    }
    else if (StrEqual(szInfo, "time"))
    {
        g_iThrowTime[client] = view_as<int>(!(g_iThrowTime[client] == 1));
        g_ckThrowTime.SetInt(client, g_iThrowTime[client]);
    }
    else if (StrEqual(szInfo, "short"))
    {
        g_iShortNames[client] = view_as<int>(!(g_iShortNames[client] == 1));
        g_ckShortNames.SetInt(client, g_iShortNames[client]);
    }
    else if (StrEqual(szInfo, "color"))
    {
        g_iColorValues[client] = view_as<int>(!(g_iColorValues[client] == 1));
        g_ckColorValues.SetInt(client, g_iColorValues[client]);
    }

    Menu_Stats(client);
}

static void Mewjam_InitStateVars(int client)
{
    g_iThrowSpeed[client] = g_ckThrowSpeed.GetInt(client, MEWJAM_STATS_COOKIE_DEFAULT_THROW_SPEED);
    g_iThrowAngle[client] = g_ckThrowAngle.GetInt(client, MEWJAM_STATS_COOKIE_DEFAULT_THROW_ANGLE);
    g_iThrowTime[client] = g_ckThrowTime.GetInt(client, MEWJAM_STATS_COOKIE_DEFAULT_THROW_TIME);
    g_iShortNames[client] = g_ckShortNames.GetInt(client, MEWJAM_STATS_COOKIE_DEFAULT_SHORT_NAMES);
    g_iColorValues[client] = g_ckColorValues.GetInt(client, MEWJAM_STATS_COOKIE_DEFAULT_COLOR_VALUES);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_STATS_NAME);
    Mewjam_OnValidEnviron(MEWJAM_STATS_NAME);
}

static void Mewjam_CreateCookies()
{
    g_ckThrowSpeed = RegClientCookie(MEWJAM_STATS_COOKIE_NAME_THROW_SPEED, MEWJAM_STATS_COOKIE_DESCRIPTION_THROW_SPEED, CookieAccess_Protected);
    g_ckThrowAngle = RegClientCookie(MEWJAM_STATS_COOKIE_NAME_THROW_ANGLE, MEWJAM_STATS_COOKIE_DESCRIPTION_THROW_ANGLE, CookieAccess_Protected);
    g_ckThrowTime = RegClientCookie(MEWJAM_STATS_COOKIE_NAME_THROW_TIME, MEWJAM_STATS_COOKIE_DESCRIPTION_THROW_TIME, CookieAccess_Protected);
    g_ckShortNames = RegClientCookie(MEWJAM_STATS_COOKIE_NAME_SHORT_NAMES, MEWJAM_STATS_COOKIE_DESCRIPTION_SHORT_NAMES, CookieAccess_Protected);
    g_ckColorValues = RegClientCookie(MEWJAM_STATS_COOKIE_NAME_COLOR_VALUES, MEWJAM_STATS_COOKIE_DESCRIPTION_COLOR_VALUES, CookieAccess_Protected);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_stats", Command_Stats);
    RegConsoleCmd("sm_stat", Command_Stats);
}

static void Mewjam_HookEvents()
{
    HookEvent(MEWJAM_EVENT_WEAPON_FIRE, Event_WeaponFire, EventHookMode_Post);
    HookEvent(MEWJAM_EVENT_PLAYER_JUMP, Event_PlayerJump, EventHookMode_Post);
}
