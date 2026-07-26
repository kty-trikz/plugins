#if defined _mewjam_chat_included_
#endinput
#endif
#define _mewjam_chat_included_

#include <string>
#include <usermessages>

#include <mewjam/util>

#define MEWJAM_CHAT_TAG ">^<"
#define MEWJAM_CHAT_SEPARATOR "|"

#define MEWJAM_CHAT_COLOR_HEX "\x7"
#define MEWJAM_CHAT_COLOR_GRAY MEWJAM_CHAT_COLOR_HEX ... "C9C0BB"
#define MEWJAM_CHAT_COLOR_PINK MEWJAM_CHAT_COLOR_HEX ... "FFC0CB"
#define MEWJAM_CHAT_COLOR_THISTLE MEWJAM_CHAT_COLOR_HEX ... "D8BFD8"
#define MEWJAM_CHAT_COLOR_BRIGHT_THISTLE MEWJAM_CHAT_COLOR_HEX ... "ECC5F7"

#define MEWJAM_CHAT_PREFIX MEWJAM_CHAT_COLOR_PINK ... MEWJAM_CHAT_TAG ... " " ... MEWJAM_CHAT_COLOR_GRAY ... MEWJAM_CHAT_SEPARATOR ... " "

stock bool Mewjam_SayText2(int client, const char[] szFormat, any ...)
{
    if (!Mewjam_IsClientInGame(client))
    {
        return false;
    }

    char szMessage[256];
    VFormat(szMessage, sizeof(szMessage), szFormat, 3);

    Handle hSayText2 = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
    if (hSayText2 == INVALID_HANDLE)
    {
        return false;
    }

    BfWrite bfMsg = UserMessageToBfWrite(hSayText2);
    bfMsg.WriteByte(client);
    bfMsg.WriteByte(1); // Sound
    bfMsg.WriteString(szMessage);

    EndMessage()
    return true;
}
