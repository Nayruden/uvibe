module uvibe.callback;

import tango.io.Stdout;

// Converts a function to a delegate. Stolen from http://dsource.org/projects/tango/ticket/1174
// Note that it doesn't handle ref or out though
R delegate(T) toDg(R, T...)(R function(T) fp) {
    struct dg {
        R opCall(T t) {
            return (cast(R function(T)) this) (t);
        }
    }
    R delegate(T) t;
    t.ptr = fp;
    t.funcptr = &dg.opCall;
    return t;
}

class SimpleCallback(R, P...)
{
	alias R delegate(P) callbacktype;
	alias R function(P) function_callbacktype;
	
	private callbacktype[] callback_list;
	
	typeof( this ) opCatAssign( in callbacktype callback )
	{
		callback_list ~= callback;
		return this;
	}
	
	typeof( this ) opCatAssign( in function_callbacktype callback )
	{
		auto dg = toDg!(R, P)( callback );
		return this ~= dg;
	}
	
	R emit( P p )
	{
		static if ( !is( R == void ) )
			R last;

		foreach( callback; callback_list )
		{
			static if ( !is( R == void ) )
				last = callback( p );
			else
				callback( p );
		}
		
		static if ( !is( R == void ) )
			return last;
	}
	
	alias emit opCall;
}

/*void main() 
{
	SimpleCallback!( void ) sc = new SimpleCallback!( void );
	SimpleCallback!( bool, char[] ) sc2 = new SimpleCallback!( bool, char[] );
	sc ~= function void() { Stdout.formatln( "#1" ); };
	sc ~= function void() { Stdout.formatln( "#2" ); };
	sc2 ~= function bool( char[] str ) { Stdout.formatln( "#1 called with {}, returning false", str ); return false; };
	sc2 ~= function bool( char[] str ) { Stdout.formatln( "#2 called with {}, returning true", str ); return true; };
	sc();
	Stdout.formatln( "Last sc2 callback returned {}", sc2( "coffee" ) );
}*/