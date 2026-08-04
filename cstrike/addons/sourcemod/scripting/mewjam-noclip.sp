#include <sourcemod>
#include <clientprefs>
#include <entity>
#include <clients>
#include <console>
#include <string>
#include <float>
#include <dhooks>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/data>
#include <mewjam/chat>
#include <mewjam/util>

#include <mewjam/noclip/info>
#include <mewjam/noclip/cookie>
#include <mewjam/noclip/util>

#pragma newdecls required
#pragma semicolon 1

#define _MEWJAM_NOCLIP_MAX_EDICT_BITS 11
#define _MEWJAM_NOCLIP_MAX_EDICTS (1 << _MEWJAM_NOCLIP_MAX_EDICT_BITS)
#define _MEWJAM_NOCLIP_NUM_ENT_ENTRY_BITS (_MEWJAM_NOCLIP_MAX_EDICT_BITS + 1)
#define _MEWJAM_NOCLIP_NUM_ENT_ENTRIES (1 << _MEWJAM_NOCLIP_NUM_ENT_ENTRY_BITS)
#define _MEWJAM_NOCLIP_ENT_ENTRY_MASK (_MEWJAM_NOCLIP_NUM_ENT_ENTRIES - 1)
#define _MEWJAM_NOCLIP_INVALID_EHANDLE_INDEX 0xFFFFFFFF

public Plugin myinfo = {
    name = MEWJAM_NOCLIP_NAME,
    author = MEWJAM_NOCLIP_AUTHOR,
    description = MEWJAM_NOCLIP_DESCRIPTION,
    version = MEWJAM_NOCLIP_VERSION,
    url = MEWJAM_NOCLIP_URL
};

bool g_bLateLoaded = false;

int g_iCGameMovementPlayerOffset;
int g_iCBaseEntityMRefEHandleOffset;

Cookie g_ckNoclipSpeed;

float g_fNoclipSpeed[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int err_max)
{
    g_bLateLoaded = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_ReadGameData();
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
}

public void OnClientCookiesCached(int client)
{
    Mewjam_InitStateVars(client);
}

static Action Command_Noclip(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    MoveType movetype = GetEntityMoveType(client);
    if (!Mewjam_IsAlivePlayer(client))
    {
        if (movetype != MOVETYPE_NOCLIP)
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_TURN_ALIVE_ERROR, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
        }
        else
        {
            Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_SHUT_ALIVE_ERROR, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
        }
        return Plugin_Handled;
    }

    if (movetype != MOVETYPE_NOCLIP)
    {
        Mewjam_TurnNoclip(client);
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_ENABLE, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
    }
    else
    {
        Mewjam_ShutNoclip(client);
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_DISABLE, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
    }

    return Plugin_Handled;
}

static Action Command_PlusNoclip(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    if (Mewjam_TurnNoclip(client))
    {
#if 0
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_ENABLE, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
#endif
    }

    return Plugin_Handled;
}

static Action Command_MinusNoclip(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    if (Mewjam_ShutNoclip(client))
    {
#if 0
        Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_DISABLE, client, MEWJAM_MESSAGE_TOGGLE_NOCLIP_PARAMS);
#endif
    }

    return Plugin_Handled;
}

static Action Command_NoclipSpeed(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    float value = 0.0;
    if (!GetCmdArgFloatEx(1, value))
    {
        return Plugin_Handled;
    }
    if (value < 0)
    {
        value = -value;
    }
#define _MEWJAM_NOCLIP_MIN_SPEED 50.0
#define _MEWJAM_NOCLIP_MAX_SPEED 4000.0
    if (value < _MEWJAM_NOCLIP_MIN_SPEED)
    {
        value = _MEWJAM_NOCLIP_MIN_SPEED;
    }
    if (value > _MEWJAM_NOCLIP_MAX_SPEED)
    {
        value = _MEWJAM_NOCLIP_MAX_SPEED;
    }
#undef _MEWJAM_NOCLIP_MAX_SPEED
#undef _MEWJAM_NOCLIP_MIN_SPEED

    g_fNoclipSpeed[client] = Mewjam_UnitsToNoclip(value);
    ConVar cvNoclipSpeed = FindConVar(MEWJAM_CONVAR_SV_NOCLIPSPEED);

    char buff[32];
    FormatEx(buff, sizeof(buff), "%f", g_fNoclipSpeed[client]);

    cvNoclipSpeed.ReplicateToClient(client, buff);
    g_ckNoclipSpeed.SetFloat(client, g_fNoclipSpeed[client]);

    Mewjam_SayText2(client, "%s%T", MEWJAM_CHAT_PREFIX, MEWJAM_MESSAGE_NOCLIP_SET_SPEED, client, MEWJAM_MESSAGE_SET_NOCLIP_SPEED_PARAMS(Mewjam_NoclipToUnits(g_fNoclipSpeed[client])));

    return Plugin_Handled;
}

static MRESReturn Hook_FullNoClipMove(Handle hParams)
{
    Address pPlayer = view_as<Address>(LoadFromAddress(view_as<Address>(DHookGetParam(hParams, 1) + view_as<Address>(g_iCGameMovementPlayerOffset)), NumberType_Int32));

    int client = Mewjam_EntityToBCompatRef(pPlayer);
    if (!Mewjam_IsPlayerInGame(client))
    {
        return MRES_Ignored;
    }

    float factor = view_as<float>(DHookGetParam(hParams, 2));
    if (Mewjam_IsCloseEnough(factor, g_fNoclipSpeed[client]))
    {
        return MRES_Ignored;
    }

    DHookSetParam(hParams, 2, g_fNoclipSpeed[client]);
    return MRES_ChangedHandled;
}

static int Mewjam_EntityToBCompatRef(Address pPlayer)
{
    if (pPlayer == Address_Null)
    {
        return _MEWJAM_NOCLIP_INVALID_EHANDLE_INDEX;
    }

    int m_RefEHandle = view_as<int>(LoadFromAddress(pPlayer + view_as<Address>(g_iCBaseEntityMRefEHandleOffset), NumberType_Int32));
    if (m_RefEHandle == _MEWJAM_NOCLIP_INVALID_EHANDLE_INDEX)
    {
        return _MEWJAM_NOCLIP_INVALID_EHANDLE_INDEX;
    }

    int entity = m_RefEHandle & _MEWJAM_NOCLIP_ENT_ENTRY_MASK;
    if (entity >= _MEWJAM_NOCLIP_MAX_EDICTS)
    {
        return m_RefEHandle | (1 << 31);
    }

    return entity;
}

static void Mewjam_ReadGameData()
{
    GameData gameData = new GameData(MEWJAM_DATA_FILENAME);

    char buff[32];
    if (!gameData.GetKeyValue("CGameMovement::player", buff, sizeof(buff)))
    {
        SetFailState("Failed to find \"CGameMovement::player\" offset!");
    }
    g_iCGameMovementPlayerOffset = StringToInt(buff);

    int base = gameData.GetOffset("m_angRotation");
    if (base == -1)
    {
        SetFailState("Failed to find \"CBaseEntity::m_angRotation\" offset!");
    }

    if (!gameData.GetKeyValue("CBaseEntity::m_RefEHandle", buff, sizeof(buff)))
    {
        SetFailState("Failed to find \"CBaseEntity::m_RefEHandle\" offset!");
    }
    g_iCBaseEntityMRefEHandleOffset = base + StringToInt(buff);

    DynamicDetour dynamicDetour = DHookCreateDetour(Address_Null, CallConv_CDECL, ReturnType_Void, ThisPointer_Ignore);
    if (!DHookSetFromConf(dynamicDetour, gameData, SDKConf_Signature, "CGameMovement::FullNoClipMove"))
    {
        SetFailState("Failed to find \"CGameMovement::FullNoClipMove\" signature!");
    }

    DHookAddParam(dynamicDetour, HookParamType_Int);
    DHookAddParam(dynamicDetour, HookParamType_Float);
    DHookAddParam(dynamicDetour, HookParamType_Float);

    if (!DHookEnableDetour(dynamicDetour, false, Hook_FullNoClipMove))
    {
        SetFailState("Failed to enable \"CGameMovement::FullNoClipMove\" dynamic detour!");
    }
}

static void Mewjam_InitStateVars(int client)
{
    g_fNoclipSpeed[client] = g_ckNoclipSpeed.GetFloat(client, MEWJAM_NOCLIP_COOKIE_DEFAULT_SPEED);

    char buff[32];
    FormatEx(buff, sizeof(buff), "%f", g_fNoclipSpeed[client]);

    ConVar cvNoclipSpeed = FindConVar(MEWJAM_CONVAR_SV_NOCLIPSPEED);
    cvNoclipSpeed.ReplicateToClient(client, buff);
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_noclip", Command_Noclip);
    RegConsoleCmd("sm_nc", Command_Noclip);
    RegConsoleCmd("sm_noclipspeed", Command_NoclipSpeed);
    RegConsoleCmd("sm_ns", Command_NoclipSpeed);

    RegConsoleCmd("+noclip", Command_PlusNoclip);
    RegConsoleCmd("-noclip", Command_MinusNoclip);
    RegConsoleCmd("+nc", Command_PlusNoclip);
    RegConsoleCmd("-nc", Command_MinusNoclip);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_NOCLIP_NAME);
    Mewjam_OnValidEnviron(MEWJAM_NOCLIP_NAME);
}

static void Mewjam_CreateCookies()
{
    g_ckNoclipSpeed = RegClientCookie(MEWJAM_NOCLIP_COOKIE_NAME_SPEED, MEWJAM_NOCLIP_COOKIE_DESCRIPTION_SPEED, CookieAccess_Protected);
}

static bool Mewjam_IsCloseEnough(float x, float y, float epsilon = 1.0e-7)
{
    return FloatAbs(x - y) <= epsilon;
}
