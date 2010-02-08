package com.realeyes.osmfplayer.events
{
	import com.realeyes.osmfplayer.model.email.EmailVO;
	
	import flash.events.Event;
	
	/**
	 * Event broadcast by the EmailOverlay to let the larger app
	 * know that it should send the email.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class SendEmailEvent extends Event
	{
		static public const SEND_EMAIL:String = 'sendEmail';
		
		/**
		 * Data for the message to be sent.
		 */
		public var data:EmailVO;
		
		public function SendEmailEvent( type:String, data:EmailVO, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			
			this.data = data;
		}
		
		/**
		 * necessary clone method for rebroadcasting
		 * 
		 * @return	Event
		 */
		override public function clone():Event
		{
			return new SendEmailEvent( type, data, bubbles, cancelable );
		}
	}
}