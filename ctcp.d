module uvibe.ctcp;

import tango.io.Stdout;
import ircconnection;

class CTCP(T) : T {
	static const marker = "\x01";
		
	version (Win32)
	{
		static const OS = "Windows";
	}
	else version (darwin)
	{
		static const OS = "Mac";
	}
	else
	{
		static const OS = "Posix";
	}
	
	this()
	{		
		onPrivMsg ~= &checkCTCP;
	}
	
	void checkCTCP( UserInfo userinfo, char[] target, char[] msg )
	{
		if ( msg[ 0 .. marker.length ] != marker || msg[ $-marker.length .. $ ] != marker )
			return; // Not interested		
		msg = msg[ marker.length .. $-marker.length ]; // Remove prefix and postfix markers
		auto mlen = msg.length;
		
		static const ver = "VERSION";
		static const ping = "PING";
		static const clientinfo = "CLIENTINFO";
		static const action = "ACTION";
		if ( mlen == ver.length && msg[ 0 .. ver.length ] == ver ) { // RFC: Not valid if it has arguments
			writeln( "NOTICE " ~ userinfo.nick ~ " :" ~ marker ~ ver ~ " UVibe 0.1 - " ~ OS ~ " - http://daydreamonline.net/" ~ marker ); // TODO, abstract
		}
		else if ( mlen >= ping.length && msg[ 0 .. ping.length ] == ping ) {
			char[] challenge = "";
			if ( mlen > ping.length + 1 )
				challenge = msg[ ping.length + 1 .. $ ];
			if ( challenge.length > 16 )
				return; // RFC: If challenge length > 16 then silently ignore
			writeln( "NOTICE " ~ userinfo.nick ~ " :" ~ marker ~ ping ~ " " ~ challenge ~ marker );
		}
		else if ( mlen >= clientinfo.length && msg[ 0 .. clientinfo.length ] == clientinfo ) {
			writeln( "NOTICE " ~ userinfo.nick ~ " :" ~ marker ~ clientinfo ~ " " ~ clientinfo ~ " " ~ ver ~ " " ~ ping ~ " " ~ action ); // TODO, abstract?
		}
		else if ( mlen >= action.length && msg[ 0 .. action.length ] == action ) {
			//TODO, actually do something with this?
		}
	}
}