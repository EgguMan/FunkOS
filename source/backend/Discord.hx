package backend;

import Sys.sleep;
#if (sys && cpp)
import discord_rpc.DiscordRpc;
#end


using StringTools;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	public static var iconType:String = 'icon';
	public function new()
	{
		#if (sys && cpp)
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1271233869269696665",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#else
		trace("WARNING: Platform does not support discord integration");
		#end
	}
	
	public static function shutdown()
	{
		#if (sys && cpp)
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if (sys && cpp)
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: iconType,
			largeImageText: "FunkOS"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if (sys && cpp)
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if (sys && cpp)
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: iconType,
			largeImageText: "Engine Version: " + states.MainMenuState.engineVersion,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#end
	}

}
