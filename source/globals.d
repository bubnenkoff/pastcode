module globals;
import std.experimental.logger;

FileLogger fLogger;
shared static this()
{
	fLogger = new FileLogger("./logs/Error.log");
}
