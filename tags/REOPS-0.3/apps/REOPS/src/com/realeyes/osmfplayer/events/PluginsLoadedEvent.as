package com.realeyes.osmfplayer.events
{
	import flash.events.Event;
	
	public class PluginsLoadedEvent extends Event
	{
		static public const PLUGINS_LOADED:String = "pluginsLoaded";
		
		public function PluginsLoadedEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
		}
	}
}