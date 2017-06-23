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


	string insertCode(string language, string code)
	{
		string guid = to!string(randomUUID);
		//writeln("language: ", language);
		//writeln("code: ", code);
		//writeln("guid: ", guid);
		//writeln(guid);
		try{
		Prepared prepared = prepare(mysqlConnection, `INSERT INTO code (guid, language, code) VALUES (?,?,?)`);
		prepared.setArgs(guid, language, code);
        prepared.exec();
    	}
    	catch(Exception e)
    	{
    		writeln(e.msg);
    	}

        return guid.split("-")[0] ~ "-"~ guid.split("-")[1];
	}


	Json getCode(string guid)
	{
		string sql = `SELECT language, code FROM code WHERE GUID LIKE '%` ~ guid ~ `%';`;
		auto result = queryRow(mysqlConnection, sql);
		Json myAnswer = Json.emptyObject();
		myAnswer["language"] = result[0].coerce!string;
		myAnswer["code"] = result[1].coerce!string;
		return myAnswer;
	}

}