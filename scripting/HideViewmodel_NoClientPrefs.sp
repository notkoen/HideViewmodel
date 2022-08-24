#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <csgocolors_fix>

bool g_bHideViewmodel[MAXPLAYERS + 1] = {false, ...};

ConVar g_cvEnable_HideVM;
bool g_bEnable;

public Plugin myinfo =
{
    name = "Hide Viewmodel (No ClientPrefs)",
    author = "koen",
    description = "Hide viewmodel without clientprefs",
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

    // Register admin command
    RegConsoleCmd("sm_togglevm", Command_Toggle, "Enable/disable viewmodel hide feature globally");
    
    // Register console commands
    RegConsoleCmd("sm_viewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
    RegConsoleCmd("sm_hideviewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
    RegConsoleCmd("sm_hidevm", Toggle_Viewmodel, "Toggle viewmodel visibility");
}

public void OnConvarChange(Handle cvar, const char[] oldValue, const char[] newVaule)
{
    if (cvar == g_cvEnable_HideVM)
        g_bEnable = g_cvEnable_HideVM.BoolValue;
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
            SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
        }
        else
        {
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