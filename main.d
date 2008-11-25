module uvibe.main;

import tango.net.SocketConduit;
import tango.net.InternetAddress;
import tango.io.Console;
import tango.io.Stdout;
import tango.text.Util;
import callback;
import ircconnection;

/*
Msg to channel:
:Nayruden!n=Nayruden@64.87.9.88 PRIVMSG #uvibe :Hi UVibe :)
:<nick>!<username>@<hostname> PRIVMSG <channel> :<msg>

:Erlie-chan!n=erieri@121.120.232.227 PRIVMSG UVibe :PING 1227541893367
:<nick>!<username>@<hostname> PRIVMSG <myname> :PING <data>
NOTICE <space> <target> <space> : <marker> <command> [<arg> [...]] <marker>

Join:
:UVibe!n=UVibe@220.149.109.71 JOIN :#daydream
:wolfe.freenode.net 353 UVibe = #daydream :UVibe Erlange Ortzinator th0br0 CIA-6 Nayruden @ChanServ

Ping:
PING :<args>
to be answered with:
PONG :<args>
*/

void main()
{	
	auto conn = new IRCConnection( "irc.freenode.net", 8000 );
	conn.connect();
	conn.join( "#daydream" );
	
	// TODO, move these listeners elsewhere
	conn.onRawLine ~= function void( char[] line ) { Stdout.formatln( line ); };
	
	conn.onPrivMsg ~= delegate void( UserInfo userinfo, char[] target, char[] msg )
	{
		static const ping = conn.marker ~ "PING";
		if ( target == conn.nick && msg[ 0 .. ping.length ] == ping && msg[ $-1 ] == conn.marker ) {
			char[] challenge = "";
			if ( msg.length > ping.length + 1 )
				challenge = msg[ ping.length + 1 .. $-1 ];
			if ( challenge.length > 16 )
				return; // RFC: If challenge > 16 then silently ignore
			conn.writeln( "NOTICE " ~ userinfo.nick ~ " :" ~ ping ~ " " ~ challenge ~ conn.marker );
		}
	};
	
	while ( conn.isConnected ) {
		conn.read();
	}
}

