#include <open.mp>

new Text:SpeedoText[MAX_PLAYERS];

public OnFilterScriptInit()
{
    print("[FS] Zynetra speedometer loaded.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    SpeedoText[playerid] = TextDrawCreate(520.0, 390.0, "Speed: 0 KMH");
    TextDrawFont(SpeedoText[playerid], 2);
    TextDrawLetterSize(SpeedoText[playerid], 0.25, 1.2);
    TextDrawSetOutline(SpeedoText[playerid], 1);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    TextDrawDestroy(SpeedoText[playerid]);
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if (IsPlayerInAnyVehicle(playerid))
    {
        new Float:vx, Float:vy, Float:vz, str[40];
        GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
        new speed = floatround(floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0);
        format(str, sizeof str, "Speed: %d KMH", speed);
        TextDrawSetString(SpeedoText[playerid], str);
        TextDrawShowForPlayer(playerid, SpeedoText[playerid]);
    }
    else TextDrawHideForPlayer(playerid, SpeedoText[playerid]);

    return 1;
}
