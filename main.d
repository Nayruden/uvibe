module uvibe.main;

import tango.net.SocketConduit;
import tango.net.InternetAddress;
import tango.io.Console;
import tango.io.Stdout;
import tango.text.Util;
import callback;
import ircconnection;
import ctcp;

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

	CTCP REQUEST Erlie-chan CLIENTINFO
	Erlie-chan CTCP REPLY CLIENTINFO CLIENTINFO ACTION FINGER TIME VERSION SOURCE OS HOST PING DCC
	
	CTCP REPLY Nayruden VERSION Colloquy 2.1 (3761) - Mac OS X 10.5.5 (Intel) - http://colloquy.info
*/

void main()
{
	auto conn = new CTCP!(IRCConnection);
	conn.connect( "irc.freenode.net", 8000 );
	conn.join( "#daydream" );
	
	conn.onRawLine ~= function void( char[] line ) 
	{
		Stdout( line ~ "\n" ); 
	};
	
	while ( conn.isConnected ) {
		conn.read();
	}
}

