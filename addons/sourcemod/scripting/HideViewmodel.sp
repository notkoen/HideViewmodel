#include <sourcemod>
#include <clientprefs>
#include <csgocolors_fix>

#pragma semicolon 1
#pragma newdecls required

bool g_bHideViewmodel[MAXPLAYERS + 1] = {false, ...};
ConVar g_cvar_Enable_HideViewmodel;
Handle g_hClientViewmodelCookie = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "Simple Hide Viewmodel",
	author = "koen",
	description = "Simple way of hiding player viewmodel (Allow clients to change r_drawviewmodel)",
	version = "1.0.0",
	url = "https://steamcommunity.com/id/fungame1224/"
}

public void OnPluginStart()
{
	LoadTranslations("hide_viewmodel.phrases");
	
	g_cvar_Enable_HideViewmodel = CreateConVar("sm_enable_hideVM", "0", "Allow players to hide viewmodel? (0 - Disable | 1 - Enable)", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "hide_viewmodel");
	
	RegConsoleCmd("sm_viewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
	RegConsoleCmd("sm_hideviewmodel", Toggle_Viewmodel, "Toggle viewmodel visibility");
	RegConsoleCmd("sm_hidevm", Toggle_Viewmodel, "Toggle viewmodel visibility");
	
	g_hClientViewmodelCookie = RegClientCookie("viewmodel_cookie", "Cookie to check if viewmodel is disabled", CookieAccess_Private);
	
	for (int i=MaxClients; i>0; --i)
	{
		if (!AreClientCookiesCached(i))
		{
			continue;
		}
		OnClientCookiesCached(i);
	}
}

public void OnClientCookiesCached(int client)
{
	char sValue[8];
	GetClientCookie(client, g_hClientViewmodelCookie, sValue, sizeof(sValue));
	
	g_bHideViewmodel[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

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
			SetClientCookie(client, g_hClientViewmodelCookie, "0");
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", false);
		}
		else
		{
			CPrintToChat(client, "%t", "Viewmodel Unhidden", "Plugin Tag");
			SetClientCookie(client, g_hClientViewmodelCookie, "1");
			SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
		}
		return Plugin_Handled;
	}
}

public void OnClientDisconnect(int client)
{
	g_bHideViewmodel[client] = false;
}