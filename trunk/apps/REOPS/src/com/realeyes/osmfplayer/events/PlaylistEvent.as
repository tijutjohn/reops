package com.realeyes.osmfplayer.events
{
	import flash.events.Event;
	
	public class PlaylistEvent extends Event
	{
		static public const PLAYLIST_NEXT:String = 'playlistNext';
		static public const PLAYLIST_PREV:String = 'playlistPrev';
		static public const PLAYLIST_SELECT:String = 'playlistSelect';
		
		public var index:int;
		
		public function PlaylistEvent(type:String, index:int = -1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.index = index;
		}
		
		override public function clone():Event
		{
			return new PlaylistEvent( type, index, bubbles, cancelable );
		}
	}
}