#include <sourcemod>
#include <csgocolors_fix>

#pragma semicolon 1
#pragma newdecls required

bool g_bHideViewmodel[MAXPLAYERS + 1] = {false, ...};
ConVar g_cvar_Enable_HideViewmodel;

public Plugin myinfo =
{
	name = "Simple Hide Viewmodel",
	author = "koen",
	description = "Simple way of hiding player viewmodel (Allow clients to change r_drawviewmodel)",
	version = "1.1.0",
	url = "https://steamcommunity.com/id/fungame1224/"
}

public void OnPluginStart()
{
	LoadTranslations("hide_viewmodel.phrases");
	
	g_cvar_Enable_HideViewmodel = CreateConVar("sm_enable_hideVM", "1", "Allow players to hide viewmodel? (0 - Disable | 1 - Enable)", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "hide_viewmodel");
	
	RegConsoleCmd("sm_viewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
	RegConsoleCmd("sm_hideviewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
	RegConsoleCmd("sm_hidevm", Toggle_Viewmodel, "Toggle viewmodel visibility");
}

// IsValidClient Check
bool IsValidClient(int client, bool bAllowBots = true, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

public Action Toggle_Viewmodel(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	else if(!g_cvar_Enable_HideViewmodel.BoolValue)
	{
		CPrintToChat(client, "%t", "Hide Viewmodel Disabled", "Plugin Tag");
		return Plugin_Handled;
	}
	else
	{
		g_bHideViewmodel[client] = !g_bHideViewmodel[client];
		if(g_bHideViewmodel[client])
		{
			CPrintToChat(client, "%t", "Viewmodel Hidden", "Plugin Tag");
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
		}
		else
		{
			CPrintToChat(client, "%t", "Viewmodel Unhidden", "Plugin Tag");
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
		}
		return Plugin_Handled;
	}
}

public void OnClientDisconnect(int client)
{
	g_bHideViewmodel[client] = false;
}