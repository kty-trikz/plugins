#if defined _mewjam_equip_util_included_
#endinput
#endif
#define _mewjam_equip_util_included_

#include <sourcemod>
#include <string>

#include <mewjam/util>
#include <mewjam/classname>

stock void Mewjam_GiveWeapon(int client, const char[] classname)
{
    if (!Mewjam_IsAlivePlayerInGame(client))
    {
        return;
    }

    int slot = Mewjam_WeaponSlot(classname);
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

        if (RemovePlayerItem(client, weapon))
        {
            AcceptEntityInput(weapon, "kill");
        }
    }

    GivePlayerItem(client, classname);
    FakeClientCommand(client, "use %s", classname);
}

stock int Mewjam_WeaponSlot(const char[] classname)
{
    if (StrEqual(classname, MEWJAM_CLASSNAME_WEAPON_SCOUT))
    {
        return 0;
    }

    if (StrEqual(classname, MEWJAM_CLASSNAME_WEAPON_GLOCK) || StrEqual(classname, MEWJAM_CLASSNAME_WEAPON_USP))
    {
        return 1;
    }

    if (StrEqual(classname, MEWJAM_CLASSNAME_WEAPON_KNIFE))
    {
        return 2;
    }

    if (StrEqual(classname, MEWJAM_CLASSNAME_WEAPON_FLASHBANG))
    {
        return 3;
    }

    return -1;
}
