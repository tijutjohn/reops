package com.realeyes.osmfplayer.events
{
	import flash.events.Event;
	
	/**
	 * Event for control bar interactions.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ControlBarEvent extends Event
	{
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const SEEK:String = "seek";
		public static const STOP:String = "stop";
		public static const MUTE:String = "mute";
		public static const UNMUTE:String = "unmute";
		public static const VOLUME:String = "volume";
		public static const VOLUME_UP:String = "volumeUp";
		public static const VOLUME_DOWN:String = "volumeDown";
		public static const FULLSCREEN:String = "fullscreen";
		public static const FULLSCREEN_RETURN:String = "fullscreenReturn";
		public static const SHOW_CLOSEDCAPTION:String = "showClosedcaption";
		public static const HIDE_CLOSEDCAPTION:String = "hideClosedcaption";
		public static const BITRATE_UP:String = "bitrateUp";
		public static const BITRATE_DOWN:String = "bitrateDown";
		
		/**
		 * The volume to use for volume events.	(Number)
		 * @default	0
		 */
		public var volume:Number;
		
		/**
		 * The percentage of the file to seek to for seek events.	(Number)
		 * @default	0
		 */
		public var seekPercent:Number;
		
		/**
		 * Constructor
		 * @param	p_type			(String) the event type
		 * @param	p_volume		(Number) volume to use for a volume event. Defaults to 0.
		 * @param	p_seekPercent	(Number) percentage of the file to seek to for seek events. Defaults to 0.
		 * @param	p_bubbles		(Boolean) does the event bubble? Defaults to false
		 * @param	p_cancelable	(Boolean) can the event be canceled? Defaults to false
		 * @return	ControlBarEvent
		 */
		public function ControlBarEvent(	p_type:String,
											p_volume:Number=0,
											p_seekPercent:Number=0,
											p_bubbles:Boolean=false, 
											p_cancelable:Boolean=false )
		{
			super( p_type, p_bubbles, p_cancelable );
			
			this.volume = p_volume;
			this.seekPercent = p_seekPercent;
		}
		
		/**
		 * Clones the event
		 * 
		 * @return	Event
		 */
		override public function clone():Event
		{
			return new ControlBarEvent( type, volume, seekPercent, bubbles, cancelable );
		}
	}
}