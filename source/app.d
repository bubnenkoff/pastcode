import std.stdio;
import database;
import router; 
import config;
import vibe.d;

//static this()
//{
	
//}
Database mydatabase;
void main()
{
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
	//if(req.path.length > 10)
	//writeln(req.path);
	Json answer = mydatabase.getCode(req.path[1..$]); // because first is slash
	int LineNumber = 1;
	string [] arrayOfLines;
	string language = answer["language"].get!string;
	//writeln(answer["code"].get!string);
	foreach(line; answer["code"].get!string.splitLines)
	{
		arrayOfLines ~= line;
		LineNumber++;
	}
	writeln("LineNumber: ", LineNumber);
	//writeln(answer);
	//writeln("^^^^^^^^");
	//res.writeJsonBody(answer);
	//writeln(language);
	res.render!("code.dt", arrayOfLines, language);

	//writeln(req.path); // getting URL that was request on server
	// here I need access to DB methods to do processing and return some DB data
}