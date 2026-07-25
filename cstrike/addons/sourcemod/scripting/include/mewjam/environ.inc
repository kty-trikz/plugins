#if defined _mewjam_environ_included_
#endinput
#endif
#define _mewjam_environ_included_

#include <mewjam/phrases>
#include <mewjam/info>

#if defined MEWJAM_SERVER_MESSAGE_SIZE
#error `MEWJAM_SERVER_MESSAGE_SIZE` is already defined _X
#endif
#define MEWJAM_SERVER_MESSAGE_SIZE 1024

stock void Mewjam_OnInvalidEnviron(const char[] plugin)
{
    if (Mewjam_IsEnvironValid())
    {
        return;
    }

    char buff[MEWJAM_SERVER_MESSAGE_SIZE];
    FormatEx(buff, sizeof(buff), "%T", MEWJAM_MESSAGE_POISONED_ENVIRONMENT, LANG_SERVER, plugin, MEWJAM_AUTHOR);
    SetFailState(buff);
}

stock void Mewjam_OnValidEnviron(const char[] plugin)
{
    if (!Mewjam_IsEnvironValid())
    {
        return;
    }

    PrintToServer("%T", MEWJAM_MESSAGE_HEARTBEAT_STARTED, LANG_SERVER, plugin, MEWJAM_AUTHOR);
}

stock bool Mewjam_IsEnvironValid()
{
    return GetEngineVersion() == Engine_CSS;
}
