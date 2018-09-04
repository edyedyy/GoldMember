//#include <CSGOkratos>
#include <sourcemod>
#include <clientprefs>
#include <cstrike>
#include <sdktools>

static const char SERVER[] = "your.dns.eu";

public Plugin myinfo = 
{
	name = "GOLD MEMBER",
	author = "kRatoss",
	description = "Gives Free Armor to players that have your server hostname in their Steam Name",
	version = "1.0",
	url = "https://www.kratoss.eu/"
}; 

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_Spawn);
}

public Action Event_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));	
	static char tag[PLATFORM_MAX_PATH], sName[MAX_NAME_LENGTH];
	
	GetClientName(iClient, sName, MAX_NAME_LENGTH);
	CS_GetClientClanTag(iClient, tag, sizeof(tag));
	
	if(StrContains(sName, SERVER, false) > -1)
	{
		GivePlayerItem(iClient, "item_kevlar");
		GivePlayerItem(iClient, "item_assaultsuit");
		SetEntProp(iClient, Prop_Send, "m_ArmorValue", 100);
		SetEntProp(iClient, Prop_Send, "m_bHasHelmet", true);

		PrintToChat(iClient, ">> You're\x07 Gold Member® \x01");
		PrintToChat(iClient, ">> You're getting\x04 Free Armor");
	}
	
	if (strlen(tag) < 1)
	{
		CS_SetClientClanTag(iClient, "Gold Member®");
	}
}
