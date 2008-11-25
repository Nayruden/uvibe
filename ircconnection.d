module uvibe.ircconnection;

import tango.net.SocketConduit;
import tango.net.InternetAddress;
import tango.io.Console;
import tango.io.Stdout;
import tango.text.Util;
import callback;

struct UserInfo
{
	char[] nick;
	char[] username;
	char[] hostname;
}

class IRCConnection
{	
	InternetAddress addr;
	private SocketConduit conn;
	private char[] buf;
	char[] nick;
	bool isConnected = false;
	
	SimpleCallback!(void, char[]) onRawLine;
	SimpleCallback!(void, UserInfo, char[], char[]) onPrivMsg;
	
	this()
	{		
		setup();
	}
	
	private void setup()
	{
		onRawLine = new SimpleCallback!(void, char[]);
		onPrivMsg = new SimpleCallback!(void, UserInfo, char[], char[]);
		
		buf = "";
	}
	
	void connect( in char[] saddr, in ushort port )
	{
		auto addr = new InternetAddress( saddr, port );
		connect( addr );
	}
	
	void connect( InternetAddress addr )
	{
		this.addr = addr;
		conn = new SocketConduit;
		conn.connect( addr );
		conn.setTimeout( 0.5 ); // TODO, abstract
		isConnected = true;
		
		nick = "UVibe";
		writeln( "NICK " ~ nick ); // TODO, abstract
		writeln( "USER UVibe 0 * :Test thing" );
	}
	
	void writeln( char[] str ) {
		conn.write( str ~ "\n" );
		Stdout( "> " ~ str ~ "\n" ); // For debugging
	}
	
	void join( in char[] room ) {
		writeln( "JOIN " ~ room );
	}
	
	void read()
	{
		char[ 1024 ] rcvd;
		int bytes = conn.read( rcvd );
		if ( bytes > 0 ) {
			auto trimmed = rcvd[ 0 .. bytes ];
			buf ~= trimmed;
			auto lines = splitLines!(char)( buf );
			if ( lines.length > 1 ) {
				buf = lines[ $-1 ];
				lines = lines[ 0 .. $-1 ];
				foreach( line; lines ) {
					onRawLine( line );
					parseRawLine( line );
				}
				Stdout.flush(); // Otherwise it waits till next loop sometimes
			}
		}
	}
	
	void parseRawLine( char[] line )
	{
		static const ping = "PING :";
		
		if ( line[ 0 .. ping.length ] == ping )
			writeln( "PONG :" ~ line[ ping.length .. $ ] );
			
		else if ( line[ 0 ] == ':' ) { // Probably a regular message (need to verify with RFC)
			line = line[ 1 .. $ ];
			uint separation_point = locate!(char)( line, ':' );
			if ( separation_point == line.length ) return; // TODO, messages during startup
			auto msg_info = line[ 0 .. separation_point ];
			auto msg = line[ separation_point + 1 .. $ ];
			auto info = delimit!(char)( msg_info, " " ); // Should be 2-3 peices to this. 1-usermask, 2-command, 3-target
			
			if ( !contains!(char)( info[ 0 ], '@' ) ) return; // TODO, message from server in special format
			auto user = parseUserMask( info[ 0 ] );
			if ( info[ 1 ] == "PRIVMSG" ) {
				onPrivMsg( user, info[ 2 ], msg );
			}
		}
	}
	
	UserInfo parseUserMask( char[] mask )
	{
		UserInfo userinfo;
		uint exclamation_pos = locate!(char)( mask, '!' );
		uint at_pos = locate!(char)( mask, '@' );
		userinfo.nick = mask[ 0 .. exclamation_pos ];
		userinfo.username = mask[ exclamation_pos + 1 .. at_pos ];
		userinfo.hostname = mask[ at_pos + 1 .. $ ];
		
		return userinfo;
	}
}