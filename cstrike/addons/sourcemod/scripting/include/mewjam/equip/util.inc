#if defined _mewjam_equip_util_included_
#endinput
#endif
#define _mewjam_equip_util_included_

#include <sourcemod>
#include <string>
#include <adt_trie>

#include <mewjam/util>

stock void Mewjam_GiveWeapon(int client, const char[] classname)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    int slot = Mewjam_WeaponSlot(null, classname);
    if (slot == -1)
    {
        return;
    }

    int weapon = -1;
    for (;;)
    {
        weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon == -1)
        {
            break;
        }

        if (!RemovePlayerItem(client, weapon))
        {
            continue;
        }

        if (IsValidEntity(weapon))
        {
            RemoveEntity(weapon);
        }
    }

    GivePlayerItem(client, classname);
}

stock int Mewjam_WeaponSlot(StringMap map, const char[] classname)
{
    static StringMap hWeaponSlots = null;
    if (hWeaponSlots == null)
    {
        hWeaponSlots = map;
    }

    if (hWeaponSlots == null)
    {
        return -1;
    }
    if (classname[0] == '\0')
    {
        return -1;
    }

    char szWeaponSlot[8];
    if (hWeaponSlots.GetString(classname, szWeaponSlot, sizeof(szWeaponSlot)))
    {
        return StringToInt(szWeaponSlot);
    }
    return -1;
}
