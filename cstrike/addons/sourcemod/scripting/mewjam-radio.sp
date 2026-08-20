#include <sourcemod>
#include <string>

#include <mewjam/environ>
#include <mewjam/phrases>
#include <mewjam/umsg>

#include <mewjam/radio/info>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = MEWJAM_RADIO_NAME,
    author = MEWJAM_RADIO_AUTHOR,
    description = MEWJAM_RADIO_DESCRIPTION,
    version = MEWJAM_RADIO_VERSION,
    url = MEWJAM_RADIO_URL
};

public void OnPluginStart()
{
    LoadTranslations(MEWJAM_MESSAGE_FILENAME);

    Mewjam_ValidateEnviron();

    HookUserMessage(GetUserMessageId(MEWJAM_RADIO_TEXT_MESSAGE_NAME), Hook_RadioText, true);
    HookUserMessage(GetUserMessageId(MEWJAM_SEND_AUDIO_MESSAGE_NAME), Hook_SendAudio, true);
}

static Action Hook_RadioText(UserMsg msg, BfRead buff, const int[] players, int size, bool bReliable, bool bInit)
{
    buff.ReadByte();
    buff.ReadByte();

    char szLocationToken[128];
    buff.ReadString(szLocationToken, sizeof(szLocationToken));

    char szPlayerName[MAX_NAME_LENGTH];
    buff.ReadString(szPlayerName, sizeof(szPlayerName));

    char szLocation[128];
    buff.ReadString(szLocation, sizeof(szLocation));

    char szMessageToken[128];
    buff.ReadString(szMessageToken, sizeof(szMessageToken));

    if (StrEqual(szLocation, MEWJAM_RADIO_TOKEN_FIRE_IN_THE_HOLE))
    {
        return Plugin_Handled;
    }
    if (StrEqual(szMessageToken, MEWJAM_RADIO_TOKEN_FIRE_IN_THE_HOLE))
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

static Action Hook_SendAudio(UserMsg msg, BfRead buff, const int[] players, int size, bool bReliable, bool bInit)
{
    char szAudioSample[128];
    buff.ReadString(szAudioSample, sizeof(szAudioSample));

    if (StrEqual(szAudioSample, MEWJAM_AUDIO_TOKEN_FIRE_IN_THE_HOLE))
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

static void Mewjam_ValidateEnviron()
{
    Mewjam_OnInvalidEnviron(MEWJAM_RADIO_NAME);
    Mewjam_OnValidEnviron(MEWJAM_RADIO_NAME);
}
