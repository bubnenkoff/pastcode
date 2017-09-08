import std.stdio;
import database;
import router; 
import globals; 
import config;
import vibe.d;


Database mydatabase;
void main()
{
	//logInfo("test");
	Config config = new Config();
	auto settings = new HTTPServerSettings;
	settings.port = 8081;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto router = new URLRouter();
	router.get("/*", serveStaticFiles("./html"));
	
	mydatabase = new Database(config);
	mydatabase.MySQLConnect(); // all DB methods are declared here

	router.registerRestInterface(new MyRouter(mydatabase));
	router.get("*", &myStuff); // all other request
	listenHTTP(settings, router);
	
	logInfo("Please open http://127.0.0.1:8081/ in your browser.");
	runApplication();

}

void myStuff(HTTPServerRequest req, HTTPServerResponse res) // I need this to handle any accessed URLs
{
	int error_code;
	string error_text;
	if(req.path.length > 10) // prevent lookup for to short URLs
	{
		
		Json answer = mydatabase.getCode(req.path[1..$]); // because first is slash
		if(answer["error"].get!bool == true)
		{

			if(answer["code"].get!int == 404)
			{
				error_text = answer["errorText"].get!string;
				error_code = 404;
				res.render!("error.dt", error_text, error_code);	
			}
			else // 503 and other
			{
				error_text = answer["errorText"].get!string;
				error_code = 503;
				res.render!("error.dt", error_text, error_code);	
				fLogger.log(answer);
			}
		}
		else
		{
			int LineNumber = 1;
			string [] arrayOfLinesOne;
			string [] arrayOfLinesTwo;
			string languageOne = answer["languageOne"].get!string;
			string languageTwo;

			foreach(line; answer["codeOne"].get!string.splitLines)
			{
				arrayOfLinesOne ~= line;
				LineNumber++;
			}

			if(answer["splitView"].get!int == 1)
			{
				languageTwo = answer["languageTwo"].get!string;
				foreach(line; answer["codeTwo"].get!string.splitLines)
				{
					arrayOfLinesTwo ~= line;
					//LineNumber++;
				}
			}

			if(answer["splitView"].get!int == 0)
			{
				res.render!("codeone.dt", arrayOfLinesOne, languageOne);
			}

			if(answer["splitView"].get!int == 1)
				res.render!("codetwo.dt", arrayOfLinesOne, languageOne, arrayOfLinesTwo, languageTwo);
		}

	}


	else
	{
		error_text = "404 Requested URL is too short!";
		error_code = 404;
		res.render!("error.dt", error_text, error_code); 
	}
}

