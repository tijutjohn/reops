package com.realeyes.osmfplayer.controls
{
	import com.realeyes.osmfplayer.events.SendEmailEvent;
	import com.realeyes.osmfplayer.model.email.EmailVO;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * Form control for allowing users to send a message to a friend from the video
	 * player.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	[Event (name="closeOverlay", type="flash.events.Event")]
	[Event (name="sendEmail", type="com.realeyes.osmfplayer.events.SendEmailEvent")]
	public class EmailOverlay extends SkinElementBase
	{
		//==================================================================
		//	PROPERTY DECLARATIONS
		//==================================================================
		static public const CLOSE_OVERLAY:String = 'closeOverlay';
		
		static public const OPEN:String = 'open';
		static public const CLOSE:String = 'close';
		
		public var toEmail_ti:TextField;
		public var fromEmail_ti:TextField;
		public var message_ti:TextField;
		public var status_txt:TextField;
		
		public var close_btn:ToggleButton;
		public var send_btn:ToggleButton;
		
		public var background_mc:MovieClip;
		
		private var _parentWidth:Number;
		private var _parentHeight:Number;
		
		private var _currentState:String;
		
		//==================================================================
		//	INIT METHODS
		//==================================================================
		public function EmailOverlay()
		{
			super();
			
			_initListeners();
			
			//For some reason a linebreak is being put in the field. This clears it
			message_ti.text = '';
		}
		
		/**
		 * Listen for user interaction
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			addEventListener( Event.ADDED, _onAdded );
			send_btn.addEventListener( MouseEvent.CLICK, _onSend );
			close_btn.addEventListener( MouseEvent.CLICK, _onClose );
			
			toEmail_ti.addEventListener( FocusEvent.FOCUS_IN, _onFieldFocus );
			fromEmail_ti.addEventListener( FocusEvent.FOCUS_IN, _onFieldFocus );
			message_ti.addEventListener( FocusEvent.FOCUS_IN, _onFieldFocus );
		}
		
		/**
		 * Create a background that masks the background of the container the 
		 * overlay is added to. If the parentHeight and parentWidth are both
		 * not specified, it will hide the background
		 * 
		 * @return	void
		 */
		private function _initBackground():void
		{	
			if( !isNaN( parentWidth ) && !isNaN( parentHeight ) )
			{
				//Reset the coordinates to deal with repeated use
				background_mc.x = 0;
				background_mc.y = 0;
				
				background_mc.visible = true;
				background_mc.x -= this.x;
				background_mc.y -= this.y;
				background_mc.width = parentWidth;
				background_mc.height = parentHeight;
			}
			else
			{
				background_mc.visible = false;
			}
		}
		
		//==================================================================
		//	CONTROL METHODS
		//==================================================================
		/**
		 * Validates the entries in the form and returns true if valid, false
		 * if not.
		 * 
		 * @return	Boolean
		 */
		private function _validateForm():Boolean
		{
			var valid:Boolean = true;
			
			if( !_validateEmail( toEmail_ti.text ) )
			{
				valid = false;
			}
			
			if( !_validateEmail( fromEmail_ti.text ) )
			{
				valid = false;
			}
			
			return valid;
		}
		
		/**
		 * Use RegEx to validate an email address
		 * 
		 * @param	email	(String) the address to validate
		 * @return	Boolean
		 */
		private function _validateEmail( email:String ):Boolean
		{
			var emailExpression:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/;
			return emailExpression.test(email);
		}
		
		/**
		 * Displays feedback to the user based on form activity
		 * 
		 * @param	message	(String) the message to display.
		 * @return	void
		 */
		public function showMessage( message:String ):void
		{
			status_txt.text = message;
		}
		//==================================================================
		//	EVENT HANDLERS
		//==================================================================
		
		/**
		 * If the form is valid, relay the message to be sent via a SendEmailEvent
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onSend( event:MouseEvent ):void
		{
			if( _validateForm() )
			{
				var message:EmailVO = new EmailVO();
				message.toAddress = toEmail_ti.text;
				message.fromAddress = fromEmail_ti.text;
				message.message = message_ti.text;
				
				dispatchEvent( new SendEmailEvent( SendEmailEvent.SEND_EMAIL, message ) );
			}
			else
			{
				//TODO: handle user feedback for invalid form 
				showMessage( 'Please use valid emails.' );
			}
		}
		
		/**
		 * Relay the user closing the overlay to the parent app
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onClose( event:MouseEvent ):void
		{
			toEmail_ti.text = '';
			fromEmail_ti.text = '';
			message_ti.text = '';
			status_txt.text = '';
			
			currentState = CLOSE;
		}
		
		/**
		 * Clear any status messages on a field gaining focus
		 * 
		 * @param	event	(FocusEvent)
		 * @return	void
		 */
		private function _onFieldFocus( event:FocusEvent ):void
		{
			showMessage( '' );
		}
		
		/**
		 * When the item is added, resize the background
		 *
		 * @param	event	(Event) Event.ADDED
		 * @return	void
		 */
		private function _onAdded( event:Event ):void
		{
			if( event.target == this )
			{
				_initBackground();
				currentState = OPEN;
			}
		}
		
		/**
		 * When the closing animation completes, fire the close overlay event
		 * 
		 * @param	event	(Event) ENTER_FRAME event
		 * @return	void
		 */
		private function _onEnterFrame( event:Event ):void
		{
			if( currentFrame == totalFrames )
			{
				removeEventListener( Event.ENTER_FRAME, _onEnterFrame );
				dispatchEvent( new Event( CLOSE_OVERLAY ) );
			}
		}
		
		//==================================================================
		//	GETTER/SETTERS
		//==================================================================
		/**
		 * Desired width of the background. If not set before the
		 * overlay is added to the display list, the background will not
		 * render.
		 * 
		 * @return	Number
		 */
		public function get parentWidth():Number
		{
			return _parentWidth;
		}
		public function set parentWidth( value:Number ):void
		{
			_parentWidth = value;
		}
		
		/**
		 * Desired height of the background. If not set before the
		 * overlay is added to the display list, the background will not
		 * render.
		 * 
		 * @return	Number
		 */
		public function get parentHeight():Number
		{
			return _parentHeight;
		}
		public function set parentHeight( value:Number ):void
		{
			_parentHeight = value;
		}
		
		/**
		 * currentState
		 * The current state of the button. The valid values are
		 * CLOSE and OPEN
		 * 
		 * @return	String
		 */  
		public function get currentState():String
		{
			
			return _currentState;
			
		}
		public function set currentState( p_value:String ):void
		{
			_currentState = p_value;
		
			//Listen for the end of the closing animation
			if( _currentState == CLOSE && !willTrigger( Event.ENTER_FRAME ) )
			{
				addEventListener( Event.ENTER_FRAME, _onEnterFrame );
			}
			
			this.gotoAndPlay( _currentState );
		}
	}
}