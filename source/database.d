import std.stdio;
import std.string;
import mysql;
import vibe.d;
import std.uuid;
import std.typecons;
import std.datetime;
import config;
import globals;


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


	string insertCode(Json data, string userIPhandler)
	{
		string guid = to!string(randomUUID);
		string currDateTime = Clock.currTime.toISOExtString().replace("T", " ").split(".")[0]; // 2017-09-08 11:43:46
		
		try
		{
			if(data["splitView"].get!bool) // if splitview is ON. Set splitView to 1
			{
				Prepared prepared = prepare(mysqlConnection, `INSERT INTO code (guid, languageOne, codeOne, languageTwo, codeTwo, splitView, paste_date) VALUES (?,?,?,?,?,?,?)`);
				prepared.setArgs(guid, data["languageOne"].get!string, data["codeOne"].get!string, data["languageTwo"].get!string, data["codeTwo"].get!string, 1, currDateTime);
				prepared.exec();
	    	}

	    	else // if splitview is OFF. Set splitView to 0
	    	{
				Prepared prepared = prepare(mysqlConnection, `INSERT INTO code (guid, languageOne, codeOne, splitView, paste_date) VALUES (?,?,?,?,?)`);
				prepared.setArgs(guid, data["languageOne"].get!string, data["codeOne"].get!string, 0, currDateTime);
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
		Json myAnswer = Json.emptyObject();

		try
		{
			string sql = `SELECT languageOne, codeOne, languageTwo, codeTwo, splitView FROM code WHERE GUID LIKE '%` ~ guid ~ `%';`;
			auto result = queryRow(mysqlConnection, sql);
			if(result.isNull)
			{
				myAnswer["error"] = true;
				myAnswer["code"] = 404;
				myAnswer["errorText"] = format(`No entries in DB for URL /%s`, guid);
			}
			else
			{
				myAnswer["languageOne"] = result[0].coerce!string;
				myAnswer["codeOne"] = result[1].coerce!string;
				myAnswer["splitView"] = 0;
				if(result[4].coerce!int == 1)
				{
					myAnswer["splitView"] = 1;
					myAnswer["languageTwo"] = result[2].coerce!string;
					myAnswer["codeTwo"] = result[3].coerce!string;
				}

				myAnswer["error"] = false;
			}
		}

		catch(MySQLException e)
		{
			myAnswer["error"] = true;
			myAnswer["errorText"] = e.msg;
			myAnswer["code"] = 503;
		}

		//writeln(myAnswer);
		return myAnswer;

	}

}