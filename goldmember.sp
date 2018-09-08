#include <sourcemod>
//#include <clientprefs>
//#include <mostactive>
#include <cstrike>
#include <sdktools>
#include <vip_core>

public Plugin myinfo = 
{
	name = "GOLD MEMBER",
	author = "kRatoss",
	description = "DNS BENEFITS",
	version = "1.3",
	url = "kratoss.eu"
}; 

//CONSOLE VARIABLES
ConVar g_cvFirstRound,
		g_cvDNS,
		g_cvArmorValue,
		g_cvTagType,
		ConVar_Restart,
		g_cvGiveHelmet,
		g_cvMoney,
		g_cvMoneyProcent
		
bool b_IsGoldMember[MAXPLAYERS + 1];

int g_iNumRound;

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_Spawn);
	
	g_cvFirstRound = CreateConVar("sm_goldmember_first_round", "1", \
		"Enable Plugin in Pistol Rounds?");
	
	g_cvArmorValue = CreateConVar("sm_goldmember_armor_value", "100", \
		"Armor value");
	
	g_cvDNS = CreateConVar("sm_goldmember_host", "kratoss.eu", \
		"The DNS that players need to have in steam name to get gold memer.");
	
	g_cvTagType = CreateConVar("sm_goldmember_tag_type", "1", \
		"Tab tag type? 0 = Disable, 1 = Set Tag only if the player doesn't have any tag, 2 = Overide curent tag");

	g_cvGiveHelmet = CreateConVar("sm_goldmember_give_helmet", "1", \
		"0 = Don't give helmet, 1 = Give helmet'");
	
	g_cvMoney = CreateConVar("sm_goldmember_give_money", "1", \
		"Give % of GoldMember's Money back.");
		
	g_cvMoneyProcent = CreateConVar("sm_goldmember_procent", "0.2", \
		"% of GoldMember's Money to give back. (0.2 = 20%, 0.5 = 50%)");
		
	
	//Do not change this!!
	ConVar_Restart = FindConVar("mp_restartgame");
	ConVar_Restart.AddChangeHook(ConVarChange_Restart);
	
	RegConsoleCmd("sm_checkname", Cmd_Check);
}

public void OnMapStart()
{
   g_iNumRound = 0;
}

public Action Event_RoundPreStart(Event event, const char[] name, bool dontBroadcast)
{   
   if(!GameRules_GetProp("m_bWarmupPeriod"))
   {
      g_iNumRound++;
   }
}

public void ConVarChange_Restart(ConVar convar, const char[] oldValue, const char[] newValue)
{
   g_iNumRound = 0;
}

public void OnClientPutInServer(int iClient)
{
	char sName[MAX_NAME_LENGTH], g_sDNS[MAX_NAME_LENGTH];
	
	GetConVarString(g_cvDNS, g_sDNS, sizeof(g_sDNS));
	GetClientName(iClient, sName, MAX_NAME_LENGTH);
	
	if(StrContains(sName, g_sDNS, false) > -1)
	{
		b_IsGoldMember[iClient] = true;
	}
}

public Action Event_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(b_IsGoldMember[iClient] == true)
	{
		if(GetConVarInt(g_cvFirstRound) == 1)
		{
			GiveArmor(iClient);
		
			if(GetConVarInt(g_cvMoney) == 1)
			{
				int iAccount = GetEntProp(iClient, Prop_Send, "m_iAccount");
				float fBonus = (GetConVarFloat(g_cvMoneyProcent) * iAccount)
				
				SetEntProp(iClient, Prop_Send, "m_iAccount", iAccount + fBonus);
				
				PrintToChat(iClient, "\x0B THANKS FOR ADVERTISING. \x06 YOU HAVE \x09 %f \x02 $ \x06BONUS", fBonus);
			}				
		}
		else if(GetConVarInt(g_cvFirstRound) == 0)
		{
			if(g_iNumRound == 1 || g_iNumRound == 16)
			{
				return Plugin_Handled;
			}
			else
			{
				GiveArmor(iClient);
			}
		}
		
		if(GetConVarInt(g_cvTagType) != 0)
		{
			if(!CheckCommandAccess(iClient, "sm_test", ADMFLAG_GENERIC, true) && !VIP_IsClientVIP(iClient))
				SetClanTag(iClient);
		}
	}
	
	return Plugin_Handled;
}

void GiveArmor(iClient)
{
	int iValue = GetConVarInt(g_cvArmorValue);
	
	GivePlayerItem(iClient, "item_kevlar");
	GivePlayerItem(iClient, "item_assaultsuit");
	SetEntProp(iClient, Prop_Send, "m_ArmorValue", iValue);
	
	if(GetConVarInt(g_cvGiveHelmet) == 1)
		SetEntProp(iClient, Prop_Send, "m_bHasHelmet", true);

	PrintToChat(iClient, ">> You're\x07 Gold Member® \x01");
	PrintToChat(iClient, ">> You're getting\x04 Free Armor");
}

void SetClanTag(int iClient)
{
	char sTag[MAX_NAME_LENGTH];
	CS_GetClientClanTag(iClient, sTag, sizeof(sTag));
	
	if(GetConVarInt(g_cvTagType) == 1)
	{
		if(strlen(sTag) < 1)
			CS_SetClientClanTag(iClient, "Gold Member®");
	}
	else if (GetConVarInt(g_cvTagType) == 2)
	{
		CS_SetClientClanTag(iClient, "Gold Member®");
	}
}

public Action Cmd_Check(int iClient, int iArgs)
{
	char sNewName[MAX_NAME_LENGTH], 
		 sDNS[MAX_NAME_LENGTH];
		 
	GetClientName(iClient, sNewName, MAX_NAME_LENGTH);
	GetConVarString(g_cvDNS, sDNS, sizeof(sDNS));
	
	if(StrContains(sNewName, sDNS, false) > -1)
	{
		b_IsGoldMember[iClient] = true;
		
		PrintToChat(iClient, "\x04* \x01 Your are /x03 Gold Member® /x01 Now")
	}
	else
	{
		b_IsGoldMember[iClient] = false;
	}
}
