#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/menu>
#include <mewjam/chat>
#include <mewjam/util>

#include <mewjam/damage/info>
#include <mewjam/damage/convar>
#include <mewjam/damage/cookie>
#include <mewjam/damage/util>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_DAMAGE_NAME,
    author = MEWJAM_DAMAGE_AUTHOR,
    description = MEWJAM_DAMAGE_DESCRIPTION,
    version = MEWJAM_DAMAGE_VERSION,
    url = MEWJAM_DAMAGE_URL
};

bool g_bLateLoaded = false;

ConVar g_cvDamageBulletEnabled;
ConVar g_cvDamageBurnEnabled;
ConVar g_cvDamageFallEnabled;
ConVar g_cvDamageBlastEnabled;
ConVar g_cvDamageDrownEnabled;

Cookie g_ckDamageBulletEnabled;
Cookie g_ckDamageBurnEnabled;
Cookie g_ckDamageFallEnabled;
Cookie g_ckDamageBlastEnabled;
Cookie g_ckDamageDrownEnabled;

int g_iDamageBulletEnabled[MAXPLAYERS + 1];
int g_iDamageBurnEnabled[MAXPLAYERS + 1];
int g_iDamageFallEnabled[MAXPLAYERS + 1];
int g_iDamageBlastEnabled[MAXPLAYERS + 1];
int g_iDamageDrownEnabled[MAXPLAYERS + 1];

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

    AutoExecConfig(true, MEWJAM_DAMAGE_CONVAR_FILENAME);

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

    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

static Action Hook_OnTakeDamage(int client, int& attacker, int& inflictor, float& damage, int& type)
{
    bool bBulletDamage = g_iDamageBulletEnabled[client] == 1;
    if (g_iDamageBulletEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BULLET_ENABLED)
    {
        bBulletDamage = g_cvDamageBulletEnabled.IntValue == 1;
    }
    if (!bBulletDamage && Mewjam_IsBulletDamage(type))
    {
        return Plugin_Handled;
    }

    bool bBurnDamage = g_iDamageBurnEnabled[client] == 1;
    if (g_iDamageBurnEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BURN_ENABLED)
    {
        bBurnDamage = g_cvDamageBurnEnabled.IntValue == 1;
    }
    if (!bBurnDamage && Mewjam_IsBurnDamage(type))
    {
        return Plugin_Handled;
    }

    bool bFallDamage = g_iDamageFallEnabled[client] == 1;
    if (g_iDamageFallEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_FALL_ENABLED)
    {
        bFallDamage = g_cvDamageFallEnabled.IntValue == 1;
    }
    if (!bFallDamage && Mewjam_IsFallDamage(type))
    {
        return Plugin_Handled;
    }

    bool bBlastDamage = g_iDamageBlastEnabled[client] == 1;
    if (g_iDamageBlastEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BLAST_ENABLED)
    {
        bBlastDamage = g_cvDamageBlastEnabled.IntValue == 1;
    }
    if (!bBlastDamage && Mewjam_IsBlastDamage(type))
    {
        return Plugin_Handled;
    }

    bool bDrownDamage = g_iDamageDrownEnabled[client] == 1;
    if (g_iDamageDrownEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_DROWN_ENABLED)
    {
        bDrownDamage = g_cvDamageDrownEnabled.IntValue == 1;
    }
    if (!bDrownDamage && Mewjam_IsDrownDamage(type))
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

static Action Command_Damage(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    Menu_Damage(client);
    return Plugin_Handled;
}

static void Menu_Damage(int client)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    bool bBulletDamage = g_iDamageBulletEnabled[client] == 1;
    if (g_iDamageBulletEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BULLET_ENABLED)
    {
        bBulletDamage = g_cvDamageBulletEnabled.IntValue == 1;
    }

    bool bBurnDamage = g_iDamageBurnEnabled[client] == 1;
    if (g_iDamageBurnEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BURN_ENABLED)
    {
        bBurnDamage = g_cvDamageBurnEnabled.IntValue == 1;
    }

    bool bFallDamage = g_iDamageFallEnabled[client] == 1;
    if (g_iDamageFallEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_FALL_ENABLED)
    {
        bFallDamage = g_cvDamageFallEnabled.IntValue == 1;
    }

    bool bBlastDamage = g_iDamageBlastEnabled[client] == 1;
    if (g_iDamageBlastEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BLAST_ENABLED)
    {
        bBlastDamage = g_cvDamageBlastEnabled.IntValue == 1;
    }

    bool bDrownDamage = g_iDamageDrownEnabled[client] == 1;
    if (g_iDamageDrownEnabled[client] == MEWJAM_DAMAGE_COOKIE_UNKNOWN_DROWN_ENABLED)
    {
        bDrownDamage = g_cvDamageDrownEnabled.IntValue == 1;
    }

    Menu menu = new Menu(MenuHandler_Damage);
    menu.SetTitle("[%s @ %s]\n ", MEWJAM_DAMAGE_NAME, MEWJAM_DAMAGE_AUTHOR);

    char szItem[64];
    FormatEx(szItem, sizeof(szItem), "Bullet Damage [%s]", bBulletDamage ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("bullet", szItem);

    FormatEx(szItem, sizeof(szItem), "Burn Damage [%s]", bBurnDamage ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("burn", szItem);

    FormatEx(szItem, sizeof(szItem), "Fall Damage [%s]", bFallDamage ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("fall", szItem);

    FormatEx(szItem, sizeof(szItem), "Blast Damage [%s]", bBlastDamage ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("blast", szItem);

    FormatEx(szItem, sizeof(szItem), "Drown Damage [%s]", bDrownDamage ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("drown", szItem);

    menu.ExitBackButton = false;
    menu.ExitButton = true;

    menu.Display(client, MENU_TIME_FOREVER);
}

static void MenuHandler_Damage(Menu menu, MenuAction action, int client, int index)
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
    bool bFound = menu.GetItem(index, szInfo, sizeof(szInfo));
    if (!bFound)
    {
        return;
    }

    if (StrEqual(szInfo, "bullet"))
    {
        int iDamageBullet = g_iDamageBulletEnabled[client];
        if (iDamageBullet == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BULLET_ENABLED)
        {
            iDamageBullet = g_cvDamageBulletEnabled.IntValue;
        }
        g_iDamageBulletEnabled[client] = view_as<int>(!(iDamageBullet == 1));
        g_ckDamageBulletEnabled.SetInt(client, g_iDamageBulletEnabled[client]);

        if (view_as<bool>(g_iDamageBulletEnabled[client]))
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BULLET_DAMAGE_ENABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BULLET_DAMAGE_DISABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
    }
    else if (StrEqual(szInfo, "burn"))
    {
        int iDamageBurn = g_iDamageBurnEnabled[client];
        if (iDamageBurn == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BURN_ENABLED)
        {
            iDamageBurn = g_cvDamageBurnEnabled.IntValue;
        }
        g_iDamageBurnEnabled[client] = view_as<int>(!(iDamageBurn == 1));
        g_ckDamageBurnEnabled.SetInt(client, g_iDamageBurnEnabled[client]);

        if (view_as<bool>(g_iDamageBurnEnabled[client]))
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BURN_DAMAGE_ENABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BURN_DAMAGE_DISABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
    }
    else if (StrEqual(szInfo, "fall"))
    {
        int iDamageFall = g_iDamageFallEnabled[client];
        if (iDamageFall == MEWJAM_DAMAGE_COOKIE_UNKNOWN_FALL_ENABLED)
        {
            iDamageFall = g_cvDamageFallEnabled.IntValue;
        }
        g_iDamageFallEnabled[client] = view_as<int>(!(iDamageFall == 1));
        g_ckDamageFallEnabled.SetInt(client, g_iDamageFallEnabled[client]);

        if (view_as<bool>(g_iDamageFallEnabled[client]))
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_FALL_DAMAGE_ENABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_FALL_DAMAGE_DISABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
    }
    else if (StrEqual(szInfo, "blast"))
    {
        int iDamageBlast = g_iDamageBlastEnabled[client];
        if (iDamageBlast == MEWJAM_DAMAGE_COOKIE_UNKNOWN_BLAST_ENABLED)
        {
            iDamageBlast = g_cvDamageBlastEnabled.IntValue;
        }
        g_iDamageBlastEnabled[client] = view_as<int>(!(iDamageBlast == 1));
        g_ckDamageBlastEnabled.SetInt(client, g_iDamageBlastEnabled[client]);

        if (view_as<bool>(g_iDamageBlastEnabled[client]))
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BLAST_DAMAGE_ENABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_BLAST_DAMAGE_DISABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
    }
    else if (StrEqual(szInfo, "drown"))
    {
        int iDamageDrown = g_iDamageDrownEnabled[client];
        if (iDamageDrown == MEWJAM_DAMAGE_COOKIE_UNKNOWN_DROWN_ENABLED)
        {
            iDamageDrown = g_cvDamageDrownEnabled.IntValue;
        }
        g_iDamageDrownEnabled[client] = view_as<int>(!(iDamageDrown == 1));
        g_ckDamageDrownEnabled.SetInt(client, g_iDamageDrownEnabled[client]);

        if (view_as<bool>(g_iDamageDrownEnabled[client]))
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_DROWN_DAMAGE_ENABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_DROWN_DAMAGE_DISABLE, client, MEWJAM_MESSAGE_TYPE_DAMAGE_PARAMS);
        }
    }

    Menu_Damage(client);
}

static void Mewjam_InitStateVars(int client)
{
    g_iDamageBulletEnabled[client] = g_ckDamageBulletEnabled.GetInt(client, MEWJAM_DAMAGE_COOKIE_UNKNOWN_BULLET_ENABLED);
    g_iDamageBurnEnabled[client] = g_ckDamageBurnEnabled.GetInt(client, MEWJAM_DAMAGE_COOKIE_UNKNOWN_BURN_ENABLED);
    g_iDamageFallEnabled[client] = g_ckDamageFallEnabled.GetInt(client, MEWJAM_DAMAGE_COOKIE_UNKNOWN_FALL_ENABLED);
    g_iDamageBlastEnabled[client] = g_ckDamageBlastEnabled.GetInt(client, MEWJAM_DAMAGE_COOKIE_UNKNOWN_BLAST_ENABLED);
    g_iDamageDrownEnabled[client] = g_ckDamageDrownEnabled.GetInt(client, MEWJAM_DAMAGE_COOKIE_UNKNOWN_DROWN_ENABLED);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_DAMAGE_NAME);
    Mewjam_OnValidEnviron(MEWJAM_DAMAGE_NAME);
}

static void Mewjam_CreateConVars()
{
    g_cvDamageBulletEnabled = CreateConVar(MEWJAM_DAMAGE_CONVAR_NAME_BULLET_ENABLED, "0", MEWJAM_DAMAGE_CONVAR_DESCRIPTION_BULLET_ENABLED, _, true, 0.0, true, 1.0);
    g_cvDamageBurnEnabled = CreateConVar(MEWJAM_DAMAGE_CONVAR_NAME_BURN_ENABLED, "0", MEWJAM_DAMAGE_CONVAR_DESCRIPTION_BURN_ENABLED, _, true, 0.0, true, 1.0);
    g_cvDamageFallEnabled = CreateConVar(MEWJAM_DAMAGE_CONVAR_NAME_FALL_ENABLED, "0", MEWJAM_DAMAGE_CONVAR_DESCRIPTION_FALL_ENABLED, _, true, 0.0, true, 1.0);
    g_cvDamageBlastEnabled = CreateConVar(MEWJAM_DAMAGE_CONVAR_NAME_BLAST_ENABLED, "0", MEWJAM_DAMAGE_CONVAR_DESCRIPTION_BLAST_ENABLED, _, true, 0.0, true, 1.0);
    g_cvDamageDrownEnabled = CreateConVar(MEWJAM_DAMAGE_CONVAR_NAME_DROWN_ENABLED, "0", MEWJAM_DAMAGE_CONVAR_DESCRIPTION_DROWN_ENABLED, _, true, 0.0, true, 1.0);
}

static void Mewjam_CreateCookies()
{
    g_ckDamageBulletEnabled = RegClientCookie(MEWJAM_DAMAGE_COOKIE_NAME_BULLET_ENABLED, MEWJAM_DAMAGE_COOKIE_DESCRIPTION_BULLET_ENABLED, CookieAccess_Protected);
    g_ckDamageBurnEnabled = RegClientCookie(MEWJAM_DAMAGE_COOKIE_NAME_BURN_ENABLED, MEWJAM_DAMAGE_COOKIE_DESCRIPTION_BURN_ENABLED, CookieAccess_Protected);
    g_ckDamageFallEnabled = RegClientCookie(MEWJAM_DAMAGE_COOKIE_NAME_FALL_ENABLED, MEWJAM_DAMAGE_COOKIE_DESCRIPTION_FALL_ENABLED, CookieAccess_Protected);
    g_ckDamageBlastEnabled = RegClientCookie(MEWJAM_DAMAGE_COOKIE_NAME_BLAST_ENABLED, MEWJAM_DAMAGE_COOKIE_DESCRIPTION_BLAST_ENABLED, CookieAccess_Protected);
    g_ckDamageDrownEnabled = RegClientCookie(MEWJAM_DAMAGE_COOKIE_NAME_DROWN_ENABLED, MEWJAM_DAMAGE_COOKIE_DESCRIPTION_DROWN_ENABLED, CookieAccess_Protected);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_damage", Command_Damage);
}
