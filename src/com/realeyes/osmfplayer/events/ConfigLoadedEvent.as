package com.realeyes.osmfplayer.events
{
	
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	
	import flash.events.Event;
	
	/**
	 * Event class for notifying the app about the config loading. Transmits
	 * the parsed config.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ConfigLoadedEvent extends Event
	{
		static public var CONFIG_LOADED:String = "configLoaded";
		
		/**
		 * The config for the player.	(PlayerConfig)
		 */
		public var config:PlayerConfig;
		
		/**
		 * Constructor
		 * @param	config		(PlayerConfig) config for the player
		 * @param	bubbles		(Boolean) does the event bubble? Defaults to false
		 * @param	cancelable	(Boolean) can the event be canceled? Defaults to false
		 * @return	ConfigLoadedEvent
		 */
		public function ConfigLoadedEvent( config:PlayerConfig, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( CONFIG_LOADED, bubbles, cancelable );
			
			this.config = config;
		}
	}
}