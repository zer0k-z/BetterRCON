#include <sourcemod>
#include <dhooks>
#pragma newdecls required
#pragma semicolon 1

#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN

#include <PTaH>

public Plugin myinfo =
{
	name = "BetterRCON",
	author = "zer0.k",
	description = "RCON with full console output",
	version = "1.3.0",
	url = "github.com/zer0k-z/BetterRCON"
};

char gC_ResponseBuffer[MAXPLAYERS + 1][65536];

public void OnClientConnected(int client)
{
	gC_ResponseBuffer[client][0] = '\0';
}

public void OnPluginStart()
{
	RegAdminCmd("sm_rcon2", Command_Rcon, ADMFLAG_RCON, "sm_rcon2 <args>");
	if (GetExtensionFileStatus("PTaH.ext") == 1)
	{
		PTaH(PTaH_ConsolePrintPre, Hook, OnClientPrint);
	}
}

public Action OnClientPrint(int client, char message[1024])
{
	if (gC_ResponseBuffer[client][0] == '\0') 
	{
		return Plugin_Continue;
	}
	String_Trim(gC_ResponseBuffer[client], gC_ResponseBuffer[client], sizeof(gC_ResponseBuffer[]));
	String_Trim(message, message, sizeof(message));
	if (StrContains(gC_ResponseBuffer[client], message) != -1)
	{
		if (String_EndsWith(gC_ResponseBuffer[client], message))
		{
			Format(message, sizeof(message), "%s\n", message);
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
	
}

Action Command_Rcon(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_rcon2 <args>");
		return Plugin_Handled;
	}

	char argstring[255];
	GetCmdArgString(argstring, sizeof(argstring));
 
	LogAction(client, -1, "\"%L\" console command (cmdline \"%s\")", client, argstring);

	if (client == 0) // They will already see the response in the console.
	{
		ServerCommand("%s", argstring);
	}
	else
	{
		char consoleBuffer[1021];
		
		ServerCommandEx(gC_ResponseBuffer[client], sizeof(gC_ResponseBuffer[]), "%s", argstring);
		for (int i = 0; i < sizeof(gC_ResponseBuffer[]); i += sizeof(consoleBuffer))
		{
			bool end;
			if (!IsClientConnected(client))
			{
				break;
			}
			for (int j = 0; j < sizeof(consoleBuffer); j++)
			{
				if (i+j == sizeof(gC_ResponseBuffer[]))
				{
					consoleBuffer[j] = '\0';
				}
				else
				{
					consoleBuffer[j] = gC_ResponseBuffer[client][i+j];
				}
				if (consoleBuffer[j] == '\0')
				{
					end = true;
					break;
				}
			}
			PrintToConsole(client, consoleBuffer);
			consoleBuffer = "";
			if (end) 
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}

stock void String_Trim(const char[] str, char[] output, int size, const char[] chrs="\t\r\n")
{
	int x=0;
	while (str[x] != '\0' && FindCharInString(chrs, str[x]) != -1) {
		x++;
	}

	x = strcopy(output, size, str[x]);
	x--;

	while (x >= 0 && FindCharInString(chrs, output[x]) != -1) {
		x--;
	}

	output[++x] = '\0';
}

stock bool String_EndsWith(const char[] str, const char[] subString)
{
	int n_str = strlen(str) - 1;
	int n_subString = strlen(subString) - 1;

	if (n_str < n_subString || strlen(str) == 0) 
	{
		return false;
	}
	else if (strlen(subString) == 0)
	{
		return true;
	}

	while (n_str != 0 && n_subString != 0) {

		if (str[n_str--] != subString[n_subString--]) {
			return false;
		}
	}

	return true;
}