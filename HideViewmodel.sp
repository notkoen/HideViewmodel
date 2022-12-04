#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>

bool g_bShowViewmodel[MAXPLAYERS + 1] = {true, ...};
Handle g_hCookie = INVALID_HANDLE;

ConVar g_cvEnableHide;
bool g_bEnable;

public Plugin myinfo =
{
    name = "Hide Viewmodel",
    author = "koen",
    description = "Hide viewmodel with clientprefs",
    version = "1.3",
    url = "https://github.com/notkoen"
}

public void OnPluginStart()
{
    // Declare ConVars
    g_cvEnableHide = CreateConVar("sm_enable_hideVM", "1", "Enable hide viewmodel (0 - Disable, 1 - Enable)", _, true, 0.0, true, 1.0);
    g_bEnable = g_cvEnableHide.BoolValue;
    HookConVarChange(g_cvEnableHide, OnConvarChange);
    
    // Execute plugin config
    AutoExecConfig(true);
    
    // Register console commands
    RegConsoleCmd("sm_viewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
    RegConsoleCmd("sm_hideviewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");

    // Register admin command
    RegAdminCmd("sm_togglevm", Command_Toggle, ADMFLAG_BAN, "Toggle viewmodel hide feature globally");
    
    // Register viewmodel cookie
    g_hCookie = RegClientCookie("viewmodel_cookie", "Viewmodel hide cookie", CookieAccess_Private);
    
    // Set cookie menu option
    SetCookieMenuItem(CookieHandler, INVALID_HANDLE, "Viewmodel Visibility");
    
    // Hook player spawn event
    HookEvent("player_spawn", Hook_OnSpawn);
    
    // Loadcookies for late plugin load
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && AreClientCookiesCached(client))
        {
            OnClientCookiesCached(client);
        }
    }
}

public void OnConvarChange(Handle cvar, const char[] oldValue, const char[] newVaule)
{
    g_bEnable = g_cvEnableHide.BoolValue;
    
    // If viewmodel hide is disabled, need to force all clients to have their viewmodels back
    if (g_bEnable) return;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!g_bShowViewmodel[client]) SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
    }
}

public void CookieHandler(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
    switch (action)
    {
        case CookieMenuAction_DisplayOption:
        {
            Format(buffer, maxlen, "Viewmodel: %s", g_bShowViewmodel[client] ? "Visible" : "Hidden");
        }
        case CookieMenuAction_SelectOption:
        {
            ToggleViewmodelVisibility(client);
            ShowCookieMenu(client);
        }
    }
}

public void OnClientCookiesCached(int client)
{
    char cookie[2];
    GetClientCookie(client, g_hCookie, cookie, sizeof(cookie));
    
    if (cookie[0] == '\0')
    {
        g_bShowViewmodel[client] = true;
        SetClientCookie(client, g_hCookie, "1");
        return;
    }

    g_bShowViewmodel[client] = StrEqual(cookie, "1");
}

public Action Toggle_Viewmodel(int client, int args)
{
    if (client == 0) return Plugin_Handled;
    if (!IsClientInGame(client)) return Plugin_Handled;
    
    if (!g_bEnable)
    {
        PrintToChat(client, " \x04[SM] \x01Viewmodel hide is currently disabled.");
        return Plugin_Handled;
    }
    ToggleViewmodelVisibility(client);
    return Plugin_Handled;
}

public Action Command_Toggle(int client, int args)
{
    g_bEnable = !g_bEnable;
    PrintToChatAll(" \x04[SM] \x01Viewmodel hiding is now %s \x01globally.", g_bEnable ? "\x04enabled" : "\x02disabled");
    return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
    g_bShowViewmodel[client] = true;
}

public void ToggleViewmodelVisibility(int client)
{
    g_bShowViewmodel[client] = !g_bShowViewmodel[client];
    SetClientCookie(client, g_hCookie, g_bShowViewmodel[client] ? "1" : "0");
    SetEntProp(client, Prop_Send, "m_bDrawViewmodel", g_bShowViewmodel[client]);
    PrintToChat(client, " \x04[SM] \x01Your viewmodel is now %s\x01.", g_bShowViewmodel[client] ? "\x04visible" : "\x02hidden");
}

public void Hook_OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client == 0) return;
    if (!IsClientInGame(client)) return;
    SetEntProp(client, Prop_Send, "m_bDrawViewmodel", g_bShowViewmodel[client]);
    return;
}