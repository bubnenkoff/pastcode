module config;
import std.string;
import std.stdio;
import std.path;
import std.file;
import std.experimental.logger;

import dini;
import globals;

class Config
{
	string dbname;
	string dbuser;
	string dbpassword;
	string dbhost;
	ushort dbport;

	this()
	{
		string configPath = buildPath((thisExePath[0..((thisExePath.lastIndexOf("\\"))+1)]), "config.ini");
		if (!exists(configPath))
		{
			fLogger.critical("config.ini do not exists");
			throw new Exception("config.ini do not exists");
		}
		auto ini = Ini.Parse(configPath);

		dbname = ini["database"].getKey("dbname");
		dbuser = ini["database"].getKey("dbuser");
		dbpassword = ini["database"].getKey("dbpassword");
		dbhost = ini["database"].getKey("dbhost");
		dbport = to!(ushort)(ini["database"].getKey("dbport"));
	}
}