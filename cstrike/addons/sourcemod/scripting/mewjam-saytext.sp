#include <sourcemod>
#include <string>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/chat>
#include <mewjam/util>

#include <mewjam/saytext/info>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_SAYTEXT_NAME,
    author = MEWJAM_SAYTEXT_AUTHOR,
    description = MEWJAM_SAYTEXT_DESCRIPTION,
    version = MEWJAM_SAYTEXT_VERSION,
    url = MEWJAM_SAYTEXT_URL
};

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();
    Mewjam_CreateCommands();
}

static Action Command_SayText(int client, int argc)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return Plugin_Handled;
    }
    if (argc < 1)
    {
        return Plugin_Handled;
    }

    char message[256];
    GetCmdArgString(message, sizeof(message));

    ReplaceString(message, sizeof(message), "^", "\x07", _);
    Mewjam_SayText2(client, "%s", message);

    return Plugin_Handled;
}

static void Mewjam_CreateCommands()
{
    RegConsoleCmd("sm_saytext", Command_SayText);
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_SAYTEXT_NAME);
    Mewjam_OnValidEnviron(MEWJAM_SAYTEXT_NAME);
}
