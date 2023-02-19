#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "BetterRCON",
	author = "zer0.k",
	description = "RCON with full console output",
	version = "1.1",
	url = "github.com/zer0k-z/BetterRCON"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_rcon2", Command_Rcon, ADMFLAG_RCON, "sm_rcon2 <args>");
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
		char responseBuffer[16384];
		ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", argstring);
		if (IsClientConnected(client))
		{
			char buffer[1024];
			for (int i = 0; i < sizeof(responseBuffer); i += 1024)
			{
				if (responseBuffer[i] == '\0')
				{
					return Plugin_Handled;
				}
				for (int j = 0; j < 1024; j++)
				{
					buffer[j] = responseBuffer[i+j];
					if (buffer[j] == '\0')
					{
						break;
					}
				}
				PrintToConsole(client, buffer);
			}
		}
	}

	return Plugin_Handled;
}