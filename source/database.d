import std.stdio;
import std.string;
import mysql;
import vibe.d;
import std.uuid;
import config;

Connection mysqlConnection;

class Database
{
	Config config;

	this(Config config)
	{
		this.config = config;	
	}

	void MySQLConnect()
	{
		auto pool = new MySQLPool(config.dbhost, config.dbuser, config.dbpassword, config.dbname, config.dbport); 
		try
		{
			mysqlConnection =  pool.lockConnection();
		}
		catch(MySQLException e)
		{
			throw new MySQLException(e.msg);
		}
	}


	string insertCode(Json data)
	{
		string guid = to!string(randomUUID);
		//writeln(data["languageOne"].get!string);
		//writeln(data["codeOne"].get!string);
		////writeln("guid: ", guid);
		////writeln(guid);
		//writeln(data);
		
		try
		{
			if(data["splitView"].get!bool) // if splitview is ON. Set splitView to 1
			{
				Prepared prepared = prepare(mysqlConnection, `INSERT INTO code (guid, languageOne, codeOne, languageTwo, codeTwo, splitView) VALUES (?,?,?,?,?,?)`);
				prepared.setArgs(guid, data["languageOne"].get!string, data["codeOne"].get!string, data["languageTwo"].get!string, data["codeTwo"].get!string, 1);
				prepared.exec();
	    	}

	    	else // if splitview is OFF. Set splitView to 0
	    	{
				Prepared prepared = prepare(mysqlConnection, `INSERT INTO code (guid, languageOne, codeOne, splitView) VALUES (?,?,?,?)`);
				prepared.setArgs(guid, data["languageOne"].get!string, data["codeOne"].get!string, 0);
				prepared.exec();
	    	}
	    		
	    }
    	catch(Exception e)
    	{
    		writeln(e.msg);
    	}

      	  return guid.split("-")[0] ~ "-"~ guid.split("-")[1];

	}


	Json getCode(string guid)
	{
		string sql = `SELECT languageOne, codeOne, languageTwo, codeTwo, splitView FROM code WHERE GUID LIKE '%` ~ guid ~ `%';`;
		auto result = queryRow(mysqlConnection, sql);
		Json myAnswer = Json.emptyObject();
		myAnswer["languageOne"] = result[0].coerce!string;
		myAnswer["codeOne"] = result[1].coerce!string;
		myAnswer["splitView"] = 0;
		if(result[4].coerce!int == 1)
		{
			myAnswer["splitView"] = 1;
			myAnswer["languageTwo"] = result[2].coerce!string;
			myAnswer["codeTwo"] = result[3].coerce!string;
		}
		
		return myAnswer;
	}

}