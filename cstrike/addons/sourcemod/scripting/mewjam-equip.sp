#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <string>
#include <timers>
#include <files>
#include <keyvalues>
#include <adt_trie>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/prop>
#include <mewjam/classname>
#include <mewjam/util>
#include <mewjam/event>
#include <mewjam/menu>

#include <mewjam/equip/info>
#include <mewjam/equip/util>
#include <mewjam/equip/cookie>

#pragma newdecls required
#pragma semicolon 1

#define _MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE 128
#define _MEWJAM_EQUIP_WEAPON_NAME_SIZE 128

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

StringMap g_hWeaponNames;
StringMap g_hWeaponSlots;
ArrayList g_hWeaponOrder;

Cookie g_ckPrimaryWeapon;
Cookie g_ckPistolWeapon;
Cookie g_ckGrenadeWeapon;
Cookie g_ckKeepMenu;

char g_szPrimaryWeapon[MAXPLAYERS + 1][_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
char g_szPistolWeapon[MAXPLAYERS + 1][_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
char g_szGrenadeWeapon[MAXPLAYERS + 1][_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
int g_iKeepMenu[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_LoadKeyValues();
    Mewjam_CreateCookies();
    Mewjam_CreateCommands();
    Mewjam_HookEvents();
    Mewjam_HookCommands();

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
    Mewjam_InitStateVars(client);

    g_bSilentKnife[client] = false;
    g_bSilentEquip[client] = false;

    SDKHook(client, SDKHook_PreThinkPost, Hook_PreThinkPost);
    SDKHook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
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

static Action Hook_WeaponDrop(int client, int weapon)
{
    if (!IsValidEntity(weapon))
    {
        return Plugin_Continue;
    }

    RequestFrame(Frame_RemoveEntity, EntIndexToEntRef(weapon));
    return Plugin_Continue;
}

static void Frame_RemoveEntity(int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
    {
        return;
    }
    RemoveEntity(entity);
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

    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_KNIFE);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_FLASHBANG);

    g_bSilentKnife[client] = true;
    g_bSilentEquip[client] = true;
}

static void Frame_PreventExplosion(int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
    {
        return;
    }

    SetEntProp(entity, Prop_Data, MEWJAM_PROP_M_NNEXTTHINKTICK, 0);
}

static void Timer_RemoveProjectile(Handle hTimer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
    {
        return;
    }

    RemoveEntity(entity);
}

static void Event_PlayerSpawn(Event event, const char[] name, bool bNoBroadcast)
{
    if (event == INVALID_HANDLE)
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    if (g_szPrimaryWeapon[client][0] != '\0')
    {
        Mewjam_GiveWeapon(client, g_szPrimaryWeapon[client]);
    }
    if (g_szPistolWeapon[client][0] != '\0')
    {
        Mewjam_GiveWeapon(client, g_szPistolWeapon[client]);
    }
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_KNIFE);
    if (g_szGrenadeWeapon[client][0] != '\0')
    {
        Mewjam_GiveWeapon(client, g_szGrenadeWeapon[client]);
    }
}

static Action Listener_Kill(int client, const char[] commands, int argc)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return Plugin_Continue;
    }

    return Plugin_Handled;
}

static Action Command_Equip(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    Menu_Equip(client);
    return Plugin_Handled;
}

static void Menu_Equip(int client)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    Menu menu = new Menu(MenuHandler_Equip);
    menu.SetTitle("[%s @ %s]\n ", MEWJAM_EQUIP_NAME, MEWJAM_EQUIP_AUTHOR);

    char szPrimaryWeapon[_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
    strcopy(szPrimaryWeapon, sizeof(szPrimaryWeapon), g_szPrimaryWeapon[client]);
    bool bHasPrimaryWeapon = szPrimaryWeapon[0] != '\0';
    char szPrimaryWeaponName[_MEWJAM_EQUIP_WEAPON_NAME_SIZE];
    g_hWeaponNames.GetString(szPrimaryWeapon, szPrimaryWeaponName, sizeof(szPrimaryWeaponName));

    char szItem[64];
    FormatEx(szItem, sizeof(szItem), "Primary Weapon [%s]", bHasPrimaryWeapon ? szPrimaryWeaponName : MEWJAM_MENU_ITEM_NONE);
    menu.AddItem("primary", szItem);

    char szPistolWeapon[_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
    strcopy(szPistolWeapon, sizeof(szPistolWeapon), g_szPistolWeapon[client]);
    bool bHasPistolWeapon = szPistolWeapon[0] != '\0';
    char szPistolWeaponName[_MEWJAM_EQUIP_WEAPON_NAME_SIZE];
    g_hWeaponNames.GetString(szPistolWeapon, szPistolWeaponName, sizeof(szPistolWeaponName));

    FormatEx(szItem, sizeof(szItem), "Pistol Weapon [%s]", bHasPistolWeapon ? szPistolWeaponName : MEWJAM_MENU_ITEM_NONE);
    menu.AddItem("pistol", szItem);

    char szGrenadeWeapon[_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
    strcopy(szGrenadeWeapon, sizeof(szGrenadeWeapon), g_szGrenadeWeapon[client]);
    bool bHasGrenadeWeapon = szGrenadeWeapon[0] != '\0';
    char szGrenadeWeaponName[_MEWJAM_EQUIP_WEAPON_NAME_SIZE];
    g_hWeaponNames.GetString(szGrenadeWeapon, szGrenadeWeaponName, sizeof(szGrenadeWeaponName));

    FormatEx(szItem, sizeof(szItem), "Grenade Weapon [%s]\n ", bHasGrenadeWeapon ? szGrenadeWeaponName : MEWJAM_MENU_ITEM_NONE);
    menu.AddItem("grenade", szItem);

    FormatEx(szItem, sizeof(szItem), "Keep Menu [%s]", view_as<bool>(g_iKeepMenu[client]) ? MEWJAM_MENU_ITEM_TRUE : MEWJAM_MENU_ITEM_FALSE);
    menu.AddItem("keep", szItem);

    menu.ExitBackButton = false;
    menu.ExitButton = true;

    menu.Display(client, MENU_TIME_FOREVER);
}

static void MenuHandler_Equip(Menu menu, MenuAction action, int client, int index)
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

    if (StrEqual(szInfo, "primary"))
    {
        Menu_SubEquip(client, "0");
        return;
    }
    if (StrEqual(szInfo, "pistol"))
    {
        Menu_SubEquip(client, "1");
        return;
    }
    if (StrEqual(szInfo, "grenade"))
    {
        Menu_SubEquip(client, "3");
        return;
    }

    if (StrEqual(szInfo, "keep"))
    {
        g_iKeepMenu[client] = view_as<int>(!(g_iKeepMenu[client] == 1));
        g_ckKeepMenu.SetInt(client, g_iKeepMenu[client]);
    }

    Menu_Equip(client);
}

static void Menu_SubEquip(int client, const char[] slot)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return;
    }

    Menu menu = new Menu(MenuHandler_SubEquip);
    menu.SetTitle("[%s @ %s]\n ", MEWJAM_EQUIP_NAME, MEWJAM_EQUIP_AUTHOR);

    for (int i = 0; i < g_hWeaponOrder.Length; ++i)
    {
        char szWeaponClass[_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
        g_hWeaponOrder.GetString(i, szWeaponClass, sizeof(szWeaponClass));

        char szSlot[8];
        if (!g_hWeaponSlots.GetString(szWeaponClass, szSlot, sizeof(szSlot)))
        {
            continue;
        }

        if (!StrEqual(szSlot, slot))
        {
            continue;
        }

        char szWeaponName[_MEWJAM_EQUIP_WEAPON_NAME_SIZE];
        if (!g_hWeaponNames.GetString(szWeaponClass, szWeaponName, sizeof(szWeaponName)))
        {
            continue;
        }

        if (StrEqual(szWeaponClass, g_szPrimaryWeapon[client]) || StrEqual(szWeaponClass, g_szPistolWeapon[client]) || StrEqual(szWeaponClass, g_szGrenadeWeapon[client]))
        {
            char szItem[_MEWJAM_EQUIP_WEAPON_NAME_SIZE + 2];
            FormatEx(szItem, sizeof(szItem), "%s *", szWeaponName);

            menu.AddItem(szWeaponClass, szItem);
        }
        else
        {
            menu.AddItem(szWeaponClass, szWeaponName);
        }
    }

    menu.ExitBackButton = true;
    menu.ExitButton = true;

    menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
}

static void MenuHandler_SubEquip(Menu menu, MenuAction action, int client, int index)
{
    if (action == MenuAction_End)
    {
        delete menu;
        return;
    }
    if (action == MenuAction_Cancel && index == MenuCancel_ExitBack)
    {
        Menu_Equip(client);
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

    char szWeaponClass[_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE];
    menu.GetItem(index, szWeaponClass, sizeof(szWeaponClass));

    int slot = Mewjam_WeaponSlot(null, szWeaponClass);
    if (slot == 0)
    {
        strcopy(g_szPrimaryWeapon[client], sizeof(g_szPrimaryWeapon[]), szWeaponClass);
        g_ckPrimaryWeapon.Set(client, g_szPrimaryWeapon[client]);
    }
    else if (slot == 1)
    {
        strcopy(g_szPistolWeapon[client], sizeof(g_szPistolWeapon[]), szWeaponClass);
        g_ckPistolWeapon.Set(client, g_szPistolWeapon[client]);
    }
    else if (slot == 3)
    {
        strcopy(g_szGrenadeWeapon[client], sizeof(g_szGrenadeWeapon[]), szWeaponClass);
        g_ckGrenadeWeapon.Set(client, g_szGrenadeWeapon[client]);
    }

    Mewjam_GiveWeapon(client, szWeaponClass);
    FakeClientCommand(client, "use %s", szWeaponClass);

    if (view_as<bool>(g_iKeepMenu[client]))
    {
        char szSlot[8];
        IntToString(slot, szSlot, sizeof(szSlot));

        Menu_SubEquip(client, szSlot);
    }
    else
    {
        Menu_Equip(client);
    }
}

static Action Command_Flashbang(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_FLASHBANG);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_FLASHBANG);
    return Plugin_Handled;
}

static Action Command_Scout(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_SCOUT);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_SCOUT);
    return Plugin_Handled;
}

static Action Command_Usp(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_USP);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_USP);
    return Plugin_Handled;
}

static Action Command_Glock(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_GLOCK);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_GLOCK);
    return Plugin_Handled;
}

static Action Command_Knife(int client, int argc)
{
    Mewjam_GiveWeapon(client, MEWJAM_CLASSNAME_WEAPON_KNIFE);
    FakeClientCommand(client, "use %s", MEWJAM_CLASSNAME_WEAPON_KNIFE);
    return Plugin_Handled;
}

static void Mewjam_InitStateVars(int client)
{
    g_ckPrimaryWeapon.Get(client, g_szPrimaryWeapon[client], sizeof(g_szPrimaryWeapon[]));
    g_ckPistolWeapon.Get(client, g_szPistolWeapon[client], sizeof(g_szPistolWeapon[]));
    g_ckGrenadeWeapon.Get(client, g_szGrenadeWeapon[client], sizeof(g_szGrenadeWeapon[]));
    g_iKeepMenu[client] = g_ckKeepMenu.GetInt(client, MEWJAM_EQUIP_COOKIE_DEFAULT_KEEP_MENU);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_EQUIP_NAME);
    Mewjam_OnValidEnviron(MEWJAM_EQUIP_NAME);
}

static void Mewjam_LoadKeyValues()
{
    char szPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szPath, sizeof(szPath), "configs/mewjam/weapons.kv");

    if (!FileExists(szPath))
    {
        SetFailState("Invalid \"weapons.kv\" Path");
        return;
    }

    KeyValues kv = new KeyValues("Weapons");
    if (!kv.ImportFromFile(szPath))
    {
        SetFailState("Invalid \"weapons.kv\" File");
        return;
    }

    g_hWeaponNames = new StringMap();
    g_hWeaponSlots = new StringMap();
    g_hWeaponOrder = new ArrayList(_MEWJAM_EQUIP_WEAPON_CLASSNAME_SIZE);

    if (kv.GotoFirstSubKey())
    {
        do
        {
            if (kv.GotoFirstSubKey())
            {
                char szWeaponClass[128];
                char szWeaponName[128];
                char szWeaponSlot[8];

                do
                {
                    kv.GetSectionName(szWeaponClass, sizeof(szWeaponClass));
                    kv.GetString("name", szWeaponName, sizeof(szWeaponName), "");
                    kv.GetString("slot", szWeaponSlot, sizeof(szWeaponSlot), "");

                    if (szWeaponName[0] == '\0' || szWeaponSlot[0] == '\0')
                    {
                        continue;
                    }

                    g_hWeaponNames.SetString(szWeaponClass, szWeaponName);
                    g_hWeaponSlots.SetString(szWeaponClass, szWeaponSlot);

                    g_hWeaponOrder.PushString(szWeaponClass);
                } while (kv.GotoNextKey());

                kv.GoBack();
            }
        } while (kv.GotoNextKey());

        kv.GoBack();
    }

    // Initializing internal StringMap for weapon slots
    Mewjam_WeaponSlot(g_hWeaponSlots, "");
}

static void Mewjam_CreateCookies()
{
    g_ckPrimaryWeapon = RegClientCookie(MEWJAM_EQUIP_COOKIE_NAME_PRIMARY_WEAPON, MEWJAM_EQUIP_COOKIE_DESCRIPTION_PRIMARY_WEAPON, CookieAccess_Protected);
    g_ckPistolWeapon = RegClientCookie(MEWJAM_EQUIP_COOKIE_NAME_PISTOL_WEAPON, MEWJAM_EQUIP_COOKIE_DESCRIPTION_PISTOL_WEAPON, CookieAccess_Protected);
    g_ckGrenadeWeapon = RegClientCookie(MEWJAM_EQUIP_COOKIE_NAME_GRENADE_WEAPON, MEWJAM_EQUIP_COOKIE_DESCRIPTION_GRENADE_WEAPON, CookieAccess_Protected);
    g_ckKeepMenu = RegClientCookie(MEWJAM_EQUIP_COOKIE_NAME_KEEP_MENU, MEWJAM_EQUIP_COOKIE_DESCRIPTION_KEEP_MENU, CookieAccess_Protected);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_equip", Command_Equip);
    RegConsoleCmd("sm_guns", Command_Equip);
    RegConsoleCmd("sm_gun", Command_Equip);
    RegConsoleCmd("sm_weapons", Command_Equip);
    RegConsoleCmd("sm_weapon", Command_Equip);
    RegConsoleCmd("sm_flashbang", Command_Flashbang);
    RegConsoleCmd("sm_flash", Command_Flashbang);
    RegConsoleCmd("sm_scout", Command_Scout);
    RegConsoleCmd("sm_usp", Command_Usp);
    RegConsoleCmd("sm_glock", Command_Glock);
    RegConsoleCmd("sm_knife", Command_Knife);
}

static void Mewjam_HookEvents()
{
    HookEvent(MEWJAM_EVENT_PLAYER_SPAWN, Event_PlayerSpawn, EventHookMode_Post);
}

static void Mewjam_HookCommands()
{
    AddCommandListener(Listener_Kill, "kill");
    AddCommandListener(Listener_Kill, "explode");
}
