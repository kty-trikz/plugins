#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <string>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/prop>
#include <mewjam/classname>
#include <mewjam/util>

#include <mewjam/equip/info>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_EQUIP_NAME,
    author = MEWJAM_EQUIP_AUTHOR,
    description = MEWJAM_EQUIP_DESCRIPTION,
    version = MEWJAM_EQUIP_VERSION,
    url = MEWJAM_EQUIP_URL
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
    SDKHook(client, SDKHook_PreThinkPost, Hook_PreThinkPost);
}

public void OnClientCookiesCached(int client)
{
}

static void Hook_PreThinkPost(int client)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    int weapon = GetEntPropEnt(client, Prop_Send, MEWJAM_PROP_M_HACTIVEWEAPON);
    if (weapon == -1 || !IsValidEntity(weapon))
    {
        return;
    }

    char szClassName[128];
    GetEntityClassname(weapon, szClassName, sizeof(szClassName));
    if (!StrEqual(szClassName, MEWJAM_CLASSNAME_WEAPON_FLASHBANG))
    {
        return;
    }

    if (!HasEntProp(weapon, Prop_Send, MEWJAM_PROP_M_FTHROWTIME))
    {
        return;
    }

    float throwTime = GetEntPropFloat(weapon, Prop_Send, MEWJAM_PROP_M_FTHROWTIME);
    if (throwTime <= 0 || throwTime >= GetGameTime())
    {
        return;
    }

    GivePlayerItem(client, MEWJAM_CLASSNAME_WEAPON_FLASHBANG);
    RequestFrame(Frame_EquipFlashbang, GetClientSerial(client));
}

static void Frame_EquipFlashbang(int serial)
{
    int client = GetClientFromSerial(serial);
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    FakeClientCommand(client, "use weapon_knife");
    FakeClientCommand(client, "use weapon_flashbang");
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_EQUIP_NAME);
    Mewjam_OnValidEnviron(MEWJAM_EQUIP_NAME);
}
