module router;
import vibe.d;
import database;
import std.stdio;

//@rootPathFromName
interface API
{
    @path("post")  @method(HTTPMethod.POST)    string insertCode(Json data, string userIPhandler);
}


string userIPhandler(HTTPServerRequest req, HTTPServerResponse res)
{
    return req.peer;
}

class MyRouter : API
{
    Database db;
    this(Database db)
    {
      this.db = db;
    }

    @before!userIPhandler("userIPhandler")
    string insertCode(Json data, string userIPhandler) // we should return only GUID
    {
       //writeln(userIPhandler);
       return db.insertCode(data, userIPhandler); 
    }

}



