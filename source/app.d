import std.stdio;
import database;
import router; 
import config;
import vibe.d;


Database mydatabase;
void main()
{
	Config config = new Config();
	auto settings = new HTTPServerSettings;
	settings.port = 8081;
	settings.bindAddresses = ["::1", "0.0.0.0"];

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
	//if(req.path.length > 10)
	//writeln(req.path);
	Json answer = mydatabase.getCode(req.path[1..$]); // because first is slash
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
	//writeln(req.path); // getting URL that was request on server
	// here I need access to DB methods to do processing and return some DB data
}