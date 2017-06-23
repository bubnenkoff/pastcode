module router;
import vibe.d;
import database;
import std.stdio;

//@rootPathFromName
interface API
{
    @path("post")  @method(HTTPMethod.POST)    string insertCode(Json data); 
}

class MyRouter : API
{
     Database db;
     this(Database db)
     {
      this.db = db;
     }
   
    string insertCode(Json data) // we should return only GUID
    {
       return db.insertCode(data["language"].get!string, data["code"].get!string);
    }


}



