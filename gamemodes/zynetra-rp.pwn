/*
    Zynetra Roleplay Starter
    Base: open.mp / SA-MP compatible Pawn
    Features:
    - MySQL login/register structure
    - Inventory basic
    - Admin system basic
    - Faction basic
    - House basic
    - Dealership basic
    - Job basic
    - Discord webhook log basic

    Required plugins/includes on VPS:
    - mysql plugin by pBlueG
    - sscanf
    - streamer
*/

#include <open.mp>
#include <a_mysql>
#include <sscanf2>
#include <streamer>

#define SERVER_NAME             "Zynetra Roleplay"
#define SERVER_VERSION          "0.1.0"
#define MAX_PASSWORD_LEN        65
#define MAX_INV_SLOTS           20
#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_GREEN             0x00FF00FF
#define COLOR_RED               0xFF3333FF
#define COLOR_YELLOW            0xFFFF00FF
#define COLOR_BLUE              0x33CCFFFF
#define COLOR_ADMIN             0xFF9900FF

#define DIALOG_LOGIN            1000
#define DIALOG_REGISTER         1001
#define DIALOG_INV              1002

new MySQL:g_SQL;

enum E_PLAYER
{
    pID,
    pName[MAX_PLAYER_NAME],
    pPassword[MAX_PASSWORD_LEN],
    pLogged,
    pAdmin,
    pMoney,
    pLevel,
    pFaction,
    pFactionRank,
    pJob,
    pHouse,
    pDealerCar,
    Float:pLastX,
    Float:pLastY,
    Float:pLastZ
}
new PlayerData[MAX_PLAYERS][E_PLAYER];

enum E_INV
{
    invName[32],
    invAmount
}
new Inventory[MAX_PLAYERS][MAX_INV_SLOTS][E_INV];

enum E_HOUSE
{
    hID,
    Float:hX,
    Float:hY,
    Float:hZ,
    hPrice,
    hOwnerID,
    Text3D:hLabel
}
new HouseData[50][E_HOUSE];
new TotalHouses;

enum E_DEALER
{
    dModel,
    dName[32],
    dPrice
}
new DealerCars[][E_DEALER] =
{
    {411, "Infernus", 850000},
    {560, "Sultan", 450000},
    {522, "NRG-500", 350000},
    {541, "Bullet", 700000},
    {415, "Cheetah", 650000}
};

main() {}

public OnGameModeInit()
{
    SetGameModeText("Zynetra Roleplay");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ShowNameTags(true);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);

    mysql_log(ERROR | WARNING);
    g_SQL = mysql_connect("127.0.0.1", "samp_user", "samp_password", "zynetra_rp");

    if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
    {
        print("[MYSQL] Connection failed. Check database/config.");
    }
    else
    {
        print("[MYSQL] Connected to database.");
    }

    LoadHouses();
    CreateCityMapping();

    print("==================================");
    print(" Zynetra Roleplay Loaded");
    print("==================================");
    return 1;
}

public OnGameModeExit()
{
    if (g_SQL != MYSQL_INVALID_HANDLE) mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerData(playerid);
    GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);

    SendClientMessage(playerid, COLOR_BLUE, "Selamat datang di Zynetra Roleplay.");
    CheckAccount(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (PlayerData[playerid][pLogged])
    {
        SavePlayer(playerid);
        SaveInventory(playerid);
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!PlayerData[playerid][pLogged])
    {
        Kick(playerid);
        return 1;
    }

    SetPlayerPos(playerid, 1685.8284, -2333.0125, 13.5469);
    SetPlayerFacingAngle(playerid, 90.0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_LOGIN)
    {
        if (!response) return Kick(playerid);
        if (!strlen(inputtext)) return ShowLogin(playerid);

        new query[256];
        mysql_format(g_SQL, query, sizeof query,
            "SELECT * FROM users WHERE username='%e' AND password=SHA2('%e', 256) LIMIT 1",
            PlayerData[playerid][pName], inputtext
        );
        mysql_tquery(g_SQL, query, "OnPlayerLogin", "i", playerid);
        return 1;
    }

    if (dialogid == DIALOG_REGISTER)
    {
        if (!response) return Kick(playerid);
        if (strlen(inputtext) < 5) 
        {
            SendClientMessage(playerid, COLOR_RED, "Password minimal 5 karakter.");
            return ShowRegister(playerid);
        }

        new query[512];
        mysql_format(g_SQL, query, sizeof query,
            "INSERT INTO users (username, password, money, level, admin, faction, faction_rank, job, house_id) VALUES ('%e', SHA2('%e', 256), 5000, 1, 0, 0, 0, 0, 0)",
            PlayerData[playerid][pName], inputtext
        );
        mysql_tquery(g_SQL, query, "OnPlayerRegister", "i", playerid);
        return 1;
    }

    return 1;
}

forward OnAccountCheck(playerid);
public OnAccountCheck(playerid)
{
    if (cache_num_rows() > 0) ShowLogin(playerid);
    else ShowRegister(playerid);
    return 1;
}

forward OnPlayerLogin(playerid);
public OnPlayerLogin(playerid)
{
    if (cache_num_rows() == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "Password salah.");
        return ShowLogin(playerid);
    }

    cache_get_value_name_int(0, "id", PlayerData[playerid][pID]);
    cache_get_value_name_int(0, "money", PlayerData[playerid][pMoney]);
    cache_get_value_name_int(0, "level", PlayerData[playerid][pLevel]);
    cache_get_value_name_int(0, "admin", PlayerData[playerid][pAdmin]);
    cache_get_value_name_int(0, "faction", PlayerData[playerid][pFaction]);
    cache_get_value_name_int(0, "faction_rank", PlayerData[playerid][pFactionRank]);
    cache_get_value_name_int(0, "job", PlayerData[playerid][pJob]);
    cache_get_value_name_int(0, "house_id", PlayerData[playerid][pHouse]);

    PlayerData[playerid][pLogged] = 1;
    LoadInventory(playerid);

    SendClientMessage(playerid, COLOR_GREEN, "Login berhasil. Selamat bermain!");
    SpawnPlayer(playerid);
    DiscordLog("Player login.");
    return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
    SendClientMessage(playerid, COLOR_GREEN, "Register berhasil. Silakan login ulang.");
    ShowLogin(playerid);
    return 1;
}

stock CheckAccount(playerid)
{
    new query[160];
    mysql_format(g_SQL, query, sizeof query,
        "SELECT id FROM users WHERE username='%e' LIMIT 1",
        PlayerData[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "OnAccountCheck", "i", playerid);
    return 1;
}

stock ShowLogin(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
        "Login Zynetra RP",
        "Akun ditemukan.\nMasukkan password:",
        "Login", "Keluar"
    );
    return 1;
}

stock ShowRegister(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
        "Register Zynetra RP",
        "Akun belum ada.\nBuat password baru:",
        "Daftar", "Keluar"
    );
    return 1;
}

stock ResetPlayerData(playerid)
{
    PlayerData[playerid][pID] = 0;
    PlayerData[playerid][pLogged] = 0;
    PlayerData[playerid][pAdmin] = 0;
    PlayerData[playerid][pMoney] = 0;
    PlayerData[playerid][pLevel] = 1;
    PlayerData[playerid][pFaction] = 0;
    PlayerData[playerid][pFactionRank] = 0;
    PlayerData[playerid][pJob] = 0;
    PlayerData[playerid][pHouse] = 0;
    return 1;
}

stock SavePlayer(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    PlayerData[playerid][pMoney] = GetPlayerMoney(playerid);

    new query[512];
    mysql_format(g_SQL, query, sizeof query,
        "UPDATE users SET money=%d, level=%d, admin=%d, faction=%d, faction_rank=%d, job=%d, house_id=%d, last_x=%f, last_y=%f, last_z=%f WHERE id=%d",
        PlayerData[playerid][pMoney],
        PlayerData[playerid][pLevel],
        PlayerData[playerid][pAdmin],
        PlayerData[playerid][pFaction],
        PlayerData[playerid][pFactionRank],
        PlayerData[playerid][pJob],
        PlayerData[playerid][pHouse],
        x, y, z,
        PlayerData[playerid][pID]
    );
    mysql_tquery(g_SQL, query);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!PlayerData[playerid][pLogged]) return 0;

    if (!strcmp(cmdtext, "/help", true))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "Commands: /stats /inv /job /work /faction /buycar /buyhouse /myhouse");
        SendClientMessage(playerid, COLOR_YELLOW, "Admin: /ahelp");
        return 1;
    }

    if (!strcmp(cmdtext, "/stats", true))
    {
        new str[160];
        format(str, sizeof str, "ID DB: %d | Money: $%d | Level: %d | Admin: %d | Faction: %d | Job: %d",
            PlayerData[playerid][pID],
            GetPlayerMoney(playerid),
            PlayerData[playerid][pLevel],
            PlayerData[playerid][pAdmin],
            PlayerData[playerid][pFaction],
            PlayerData[playerid][pJob]
        );
        SendClientMessage(playerid, COLOR_WHITE, str);
        return 1;
    }

    if (!strcmp(cmdtext, "/inv", true))
    {
        ShowInventory(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/job", true))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "Job tersedia: /joinjob courier atau /joinjob mechanic");
        return 1;
    }

    if (!strcmp(cmdtext, "/joinjob courier", true))
    {
        PlayerData[playerid][pJob] = 1;
        SendClientMessage(playerid, COLOR_GREEN, "Kamu sekarang bekerja sebagai Courier.");
        return 1;
    }

    if (!strcmp(cmdtext, "/joinjob mechanic", true))
    {
        PlayerData[playerid][pJob] = 2;
        SendClientMessage(playerid, COLOR_GREEN, "Kamu sekarang bekerja sebagai Mechanic.");
        return 1;
    }

    if (!strcmp(cmdtext, "/work", true))
    {
        if (PlayerData[playerid][pJob] == 1)
        {
            GivePlayerMoney(playerid, 750);
            AddItem(playerid, "Package", 1);
            SendClientMessage(playerid, COLOR_GREEN, "Courier selesai. Dapat $750 dan Package.");
        }
        else if (PlayerData[playerid][pJob] == 2)
        {
            GivePlayerMoney(playerid, 1000);
            AddItem(playerid, "RepairKit", 1);
            SendClientMessage(playerid, COLOR_GREEN, "Mechanic selesai. Dapat $1000 dan RepairKit.");
        }
        else SendClientMessage(playerid, COLOR_RED, "Kamu belum punya job. Pakai /job.");
        return 1;
    }

    if (!strcmp(cmdtext, "/faction", true))
    {
        if (PlayerData[playerid][pFaction] == 1) SendClientMessage(playerid, COLOR_BLUE, "Faction kamu: Police Department.");
        else if (PlayerData[playerid][pFaction] == 2) SendClientMessage(playerid, COLOR_BLUE, "Faction kamu: EMS.");
        else SendClientMessage(playerid, COLOR_RED, "Kamu belum masuk faction.");
        return 1;
    }

    if (!strcmp(cmdtext, "/buycar", true))
    {
        new price = DealerCars[0][dPrice];
        if (GetPlayerMoney(playerid) < price) return SendClientMessage(playerid, COLOR_RED, "Uang kurang untuk beli Infernus.");

        GivePlayerMoney(playerid, -price);
        PlayerData[playerid][pDealerCar] = DealerCars[0][dModel];
        SendClientMessage(playerid, COLOR_GREEN, "Kamu membeli Infernus dari dealership.");
        return 1;
    }

    if (!strcmp(cmdtext, "/veh", true))
    {
        if (!PlayerData[playerid][pDealerCar]) return SendClientMessage(playerid, COLOR_RED, "Kamu belum punya kendaraan.");
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        CreateVehicle(PlayerData[playerid][pDealerCar], x + 2.0, y, z, a, -1, -1, 600);
        SendClientMessage(playerid, COLOR_GREEN, "Kendaraan pribadi dikeluarkan.");
        return 1;
    }

    if (!strcmp(cmdtext, "/buyhouse", true))
    {
        if (TotalHouses < 1) return SendClientMessage(playerid, COLOR_RED, "Belum ada rumah.");
        if (PlayerData[playerid][pHouse] != 0) return SendClientMessage(playerid, COLOR_RED, "Kamu sudah punya rumah.");
        if (GetPlayerMoney(playerid) < HouseData[0][hPrice]) return SendClientMessage(playerid, COLOR_RED, "Uang kurang.");

        GivePlayerMoney(playerid, -HouseData[0][hPrice]);
        PlayerData[playerid][pHouse] = HouseData[0][hID];
        HouseData[0][hOwnerID] = PlayerData[playerid][pID];
        SendClientMessage(playerid, COLOR_GREEN, "Rumah berhasil dibeli.");
        return 1;
    }

    if (!strcmp(cmdtext, "/myhouse", true))
    {
        if (!PlayerData[playerid][pHouse]) return SendClientMessage(playerid, COLOR_RED, "Kamu belum punya rumah.");
        SendClientMessage(playerid, COLOR_GREEN, "Rumah kamu aktif. Fitur interior bisa ditambah nanti.");
        return 1;
    }

    if (!strcmp(cmdtext, "/ahelp", true))
    {
        if (PlayerData[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Khusus admin.");
        SendClientMessage(playerid, COLOR_ADMIN, "Admin commands: /setadmin /setfaction /goto /gethere /aduty");
        return 1;
    }

    if (!strcmp(cmdtext, "/aduty", true))
    {
        if (PlayerData[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Khusus admin.");
        SetPlayerHealth(playerid, 99999.0);
        SendClientMessageToAll(COLOR_ADMIN, "Admin sedang duty.");
        return 1;
    }

    return 0;
}

stock AddItem(playerid, const item[], amount)
{
    for (new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if (!strcmp(Inventory[playerid][i][invName], item, true))
        {
            Inventory[playerid][i][invAmount] += amount;
            return 1;
        }
    }

    for (new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if (Inventory[playerid][i][invAmount] == 0)
        {
            format(Inventory[playerid][i][invName], 32, "%s", item);
            Inventory[playerid][i][invAmount] = amount;
            return 1;
        }
    }
    return 0;
}

stock ShowInventory(playerid)
{
    new text[1024], line[80];
    strcat(text, "Inventory kamu:\n\n");

    for (new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if (Inventory[playerid][i][invAmount] > 0)
        {
            format(line, sizeof line, "%d. %s x%d\n", i + 1, Inventory[playerid][i][invName], Inventory[playerid][i][invAmount]);
            strcat(text, line);
        }
    }

    ShowPlayerDialog(playerid, DIALOG_INV, DIALOG_STYLE_MSGBOX, "Inventory", text, "Tutup", "");
    return 1;
}

stock LoadInventory(playerid)
{
    for (new i = 0; i < MAX_INV_SLOTS; i++)
    {
        Inventory[playerid][i][invName][0] = EOS;
        Inventory[playerid][i][invAmount] = 0;
    }

    new query[160];
    mysql_format(g_SQL, query, sizeof query, "SELECT item_name, amount FROM inventory WHERE user_id=%d", PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query, "OnInventoryLoad", "i", playerid);
    return 1;
}

forward OnInventoryLoad(playerid);
public OnInventoryLoad(playerid)
{
    new rows = cache_num_rows();
    for (new i = 0; i < rows && i < MAX_INV_SLOTS; i++)
    {
        cache_get_value_name(i, "item_name", Inventory[playerid][i][invName], 32);
        cache_get_value_name_int(i, "amount", Inventory[playerid][i][invAmount]);
    }
    return 1;
}

stock SaveInventory(playerid)
{
    new query[256];
    mysql_format(g_SQL, query, sizeof query, "DELETE FROM inventory WHERE user_id=%d", PlayerData[playerid][pID]);
    mysql_tquery(g_SQL, query);

    for (new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if (Inventory[playerid][i][invAmount] > 0)
        {
            mysql_format(g_SQL, query, sizeof query,
                "INSERT INTO inventory (user_id, item_name, amount) VALUES (%d, '%e', %d)",
                PlayerData[playerid][pID],
                Inventory[playerid][i][invName],
                Inventory[playerid][i][invAmount]
            );
            mysql_tquery(g_SQL, query);
        }
    }
    return 1;
}

stock LoadHouses()
{
    TotalHouses = 1;
    HouseData[0][hID] = 1;
    HouseData[0][hX] = 1684.9;
    HouseData[0][hY] = -2240.2;
    HouseData[0][hZ] = 13.5;
    HouseData[0][hPrice] = 100000;
    HouseData[0][hOwnerID] = 0;

    HouseData[0][hLabel] = CreateDynamic3DTextLabel(
        "Rumah Dijual\nHarga: $100000\n/buyhouse",
        COLOR_GREEN,
        HouseData[0][hX], HouseData[0][hY], HouseData[0][hZ],
        15.0
    );
    return 1;
}

stock CreateCityMapping()
{
    CreateDynamicObject(970, 1688.5928, -2334.9150, 13.2700, 0.0, 0.0, 0.0);
    CreateDynamicObject(970, 1692.5928, -2334.9150, 13.2700, 0.0, 0.0, 0.0);
    CreateDynamicObject(1237, 1686.1928, -2334.9150, 13.0000, 0.0, 0.0, 0.0);
    CreateDynamic3DTextLabel("Zynetra City Hall\nSpawn Area", COLOR_BLUE, 1685.8284, -2333.0125, 14.5469, 20.0);
    CreateDynamic3DTextLabel("Dealership\n/buycar lalu /veh", COLOR_YELLOW, 1670.0000, -2320.0000, 13.5469, 20.0);
    CreateDynamicPickup(1239, 1, 1670.0000, -2320.0000, 13.5469);
    return 1;
}

stock DiscordLog(const msg[])
{
    printf("[DISCORD LOG] %s", msg);
    // Real Discord webhook lebih bagus dipasang via discord-bot/index.js
    return 1;
}
