#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <string>
#include <timers>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/prop>
#include <mewjam/classname>
#include <mewjam/util>
#include <mewjam/event>

#include <mewjam/equip/info>
#include <mewjam/equip/util>

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

bool g_bSilentKnife[MAXPLAYERS + 1];
bool g_bSilentEquip[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_CreateCommands();

    AddNormalSoundHook(Hook_NormalSound);

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
    g_bSilentKnife[client] = false;
    g_bSilentEquip[client] = false;

    SDKHook(client, SDKHook_PreThinkPost, Hook_PreThinkPost);
}

public void OnClientCookiesCached(int client)
{
}

public void OnEntityCreated(int entity, const char[] className)
{
    if (!IsValidEntity(entity))
    {
        return;
    }

    if (StrContains(className, "_projectile") != -1)
    {
        SDKHook(entity, SDKHook_SpawnPost, Hook_SpawnPost);
    }
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

static Action Hook_NormalSound(int clients[MAXPLAYERS], int& size, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char entry[PLATFORM_MAX_PATH], int& seed)
{
    for (int i = 0; i < size; ++i)
    {
        int client = clients[i];
        if (!Mewjam_IsPlayerInGame(client))
        {
            continue;
        }

        if (StrEqual(sample, "weapons/knife/knife_deploy1.wav") && g_bSilentKnife[client])
        {
            g_bSilentKnife[client] = false;
            return Plugin_Stop;
        }

        if (StrEqual(sample, "items/itempickup.wav") && g_bSilentEquip[client])
        {
            g_bSilentEquip[client] = false;
            return Plugin_Stop;
        }
    }

    return Plugin_Continue;
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

    if (!HasEntProp(entity, Prop_Data, MEWJAM_PROP_M_NNEXTTHINKTICK))
    {
        return;
    }

    RequestFrame(Frame_PreventExplosion, EntIndexToEntRef(entity));
    CreateTimer(1.6, Timer_RemoveProjectile, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
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

    g_bSilentKnife[client] = true;
    g_bSilentEquip[client] = true;
}

static void Frame_PreventExplosion(int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (!IsValidEntity(entity))
    {
        return;
    }

    SetEntProp(entity, Prop_Data, MEWJAM_PROP_M_NNEXTTHINKTICK, 0);
}

static void Timer_RemoveProjectile(Handle hTimer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (!IsValidEntity(entity))
    {
        return;
    }

    RemoveEntity(entity);
}

static Action Command_Flashbang(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_FLASHBANG);
    return Plugin_Handled;
}

static Action Command_Scout(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_SCOUT);
    return Plugin_Handled;
}

static Action Command_Usp(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_USP);
    return Plugin_Handled;
}

static Action Command_Glock(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_GLOCK);
    return Plugin_Handled;
}

static Action Command_Knife(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_KNIFE);
    return Plugin_Handled;
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_EQUIP_NAME);
    Mewjam_OnValidEnviron(MEWJAM_EQUIP_NAME);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_flashbang", Command_Flashbang);
    RegConsoleCmd("sm_flash", Command_Flashbang);
    RegConsoleCmd("sm_scout", Command_Scout);
    RegConsoleCmd("sm_usp", Command_Usp);
    RegConsoleCmd("sm_glock", Command_Glock);
    RegConsoleCmd("sm_knife", Command_Knife);
}
