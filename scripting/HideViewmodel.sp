#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <clientprefs>
#include <csgocolors_fix>

bool g_bHideViewmodel[MAXPLAYERS + 1] = {false, ...};
Handle g_hClientViewmodelCookie = INVALID_HANDLE;

ConVar g_cvEnable_HideVM;
bool g_bEnable;

public Plugin myinfo =
{
    name = "Hide Viewmodel",
    author = "koen",
    description = "Hide viewmodel with clientprefs",
    version = "1.2.0",
    url = "https://github.com/notkoen"
}

public void OnPluginStart()
{
    // Load Translations
    LoadTranslations("hide_viewmodel.phrases");
    
    // Declare ConVars
    g_cvEnable_HideVM = CreateConVar("sm_enable_hideVM", "1", "Enable hide viewmodel (0 - Disable, 1 - Enable)", _, true, 0.0, true, 1.0);
    g_bEnable = g_cvEnable_HideVM.BoolValue;
    HookConVarChange(g_cvEnable_HideVM, OnConvarChange);
    
    // Execute plugin config
    AutoExecConfig(true, "hide_viewmodel");
    
    // Register console commands
    RegConsoleCmd("sm_viewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
    RegConsoleCmd("sm_hideviewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
    RegConsoleCmd("sm_hidevm", Toggle_Viewmodel, "Toggle viewmodel visibility");

    // Register admin command
    RegConsoleCmd("sm_togglevm", Command_Toggle, "Enable/disable viewmodel hide feature globally");
    
    // Register viewmodel cookie
    g_hClientViewmodelCookie = RegClientCookie("viewmodel_cookie", "Cookie to check if viewmodel is disabled", CookieAccess_Private);
    
    // Loadcookies for late plugin load
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && AreClientCookiesCached(client))
        {
            LoadCookies(client);
        }
    }
}

public void OnConvarChange(Handle cvar, const char[] oldValue, const char[] newVaule)
{
    if (cvar == g_cvEnable_HideVM)
        g_bEnable = g_cvEnable_HideVM.BoolValue;
}

void LoadCookies(int client)
{
    // Load client cookies
    char cookie[8];
    GetClientCookie(client, g_hClientViewmodelCookie, cookie, sizeof(cookie));

    if (cookie[0] != '\0')
    {
        char temp[2];

        Format(temp, sizeof(temp), "%c", cookie[0]);
        g_bHideViewmodel[client] = StrEqual(temp, "1");
    }
    else
    {
        g_bHideViewmodel[client] = false;
    }

    // Use loaded cookies to set client settings
    SetEntProp(client, Prop_Send, "m_bDrawViewmodel", !g_bHideViewmodel[client]);
}

// IsValidClient check function
stock bool IsValidClient(int client)
{
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
        return false;
    return true;
}

public Action Toggle_Viewmodel(int client, int args)
{
    if (!IsValidClient(client))
    {
        return Plugin_Handled;
    }
    else if (!g_bEnable)
    {
        CPrintToChat(client, "%t %t", "Plugin Tag", "Hide Viewmodel Disabled");
        return Plugin_Handled;
    }
    else
    {
        g_bHideViewmodel[client] = !g_bHideViewmodel[client];
        if (g_bHideViewmodel[client])
        {
            SetClientCookie(client, g_hClientViewmodelCookie, "1");
            SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
        }
        else
        {
            SetClientCookie(client, g_hClientViewmodelCookie, "0");
            SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
        }
        CPrintToChat(client, "%t %t", "Plugin Tag", "Viewmodel Change", g_bHideViewmodel[client] ? "{green}hidden" : "{red}visible");
        return Plugin_Handled;
    }
}

public Action Command_Toggle(int client, int args)
{
    g_bEnable = !g_bEnable;
    CPrintToChatAll("%t %t", "Plugin Tag", "Viewmodel Toggle", g_bEnable ? "{green}enabled" : "{red}disabled");
    return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
    g_bHideViewmodel[client] = false;
}