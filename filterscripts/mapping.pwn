#include <open.mp>
#include <streamer>

public OnFilterScriptInit()
{
    print("[FS] Zynetra mapping loaded.");

    CreateDynamicObject(19379, 1500.0, -1700.0, 13.0, 0.0, 90.0, 0.0);
    CreateDynamic3DTextLabel("Zynetra Kota RP\nArea Mapping Starter", 0x33CCFFFF, 1500.0, -1700.0, 15.0, 30.0);
    return 1;
}
