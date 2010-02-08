package com.realeyes.osmfplayer.controls
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import com.realeyes.osmfplayer.events.ControlBarEvent;
	import com.realeyes.osmfplayer.model.Plugin;
	
	/**
	 * Shows progress of the media playback in a slider bar. Also allows
	 * for seeking through the media by using the scrubber. Also shows 
	 * buffer progress.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ProgressBar extends MovieClip
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var scrubber_mc:ToggleButton;
		
		public var current_mc:MovieClip;
		public var loaded_mc:MovieClip;
		
		public var live_mc:MovieClip;
		
		public var bg_mc:MovieClip;
		
		private var _dragging:Boolean = false;
		private var _scrubberPadding:Number = 0;
		private var _scrubberWidth:Number = 0;
		private var _activeRange:Number;
		
		private var _isLive:Boolean;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ProgressBar()
		{
			super();
			
			live_mc.visible = false;
			
			current_mc.width = 0;
			loaded_mc.width = 0;
			
			if( scrubber_mc )
			{
				_scrubberWidth = scrubber_mc.width;
				scrubber_mc.toggle = false;
			}

			_scrubberPadding = _scrubberWidth / 2;
			_activeRange = width - _scrubberWidth;
			
			_initListeners();
		}
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		/**
		 * Initialize listenrs for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			addEventListener( MouseEvent.CLICK, _onClick );
			
			if( scrubber_mc )
			{
				scrubber_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onScrubberMouseDown );
				scrubber_mc.addEventListener( MouseEvent.MOUSE_UP, _onScrubberMouseUp );
			}
		}
		
		/**
		 * Sets the current progress indicator at a certain percentage of the
		 * bar's width. If showing playback progress, it also moves the scrubber.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */ 
		public function setCurrentBarPercent( p_value:Number ):void
		{
			//trace("current percent: " + (p_value) );
			if( !_dragging )
			{
				current_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
				
				if( scrubber_mc )
				{
					scrubber_mc.x = Math.round( current_mc.width - _scrubberWidth );
				}
			}
		}
		
		/**
		 * Updates the loading indicator bar to be at a certain percentage of the
		 * bar's width.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			//trace("load percent: " + p_value);
			if( p_value <= 1 )
			{
				loaded_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
			}
			else if( !isNaN( p_value ) )
			{
				loaded_mc.width = width;
			}
		}
		
		/**
		 * Stops dragging of the scrubber and seeks for recorded content.
		 * 
		 * @return	void
		 */
		private function _stopScrubberDrag():void
		{
			_dragging = false;
			
			scrubber_mc.removeEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			scrubber_mc.stopDrag();
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			
			if( !isLive )
			{
				dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK, 0, scrubber_mc.x / _activeRange, true ) );
			}
		}
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * Is the content live?
		 * 
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			
			if( _isLive )
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = false;
				}
				current_mc.visible = false;
				loaded_mc.visible = false;
				
				live_mc.visible = true;
			}
			else
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = true;
				}
				current_mc.visible = true;
				loaded_mc.visible = true;
				
				live_mc.visible = false;
			}
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * When the bar is clicked on during playback, seek to
		 * that point.
		 * 
		 * @param	p_evt	(MouseEvent) click event
		 * @return	void
		 */
		private function _onClick( p_evt:MouseEvent ):void
		{
			if( !scrubber_mc || p_evt.target != scrubber_mc && !isLive )
			{
				dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK, 0, ( mouseX - _scrubberPadding ) / _activeRange, true ) );
			}
		}
		
		/**
		 * Start draggin the scrubber when the mouse is down on the scrubber.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onScrubberMouseDown( p_evt:MouseEvent ):void
		{
			_dragging = true;
			
			scrubber_mc.addEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
	
			scrubber_mc.startDrag( false, new Rectangle( 0, scrubber_mc.y, _activeRange, 0 ) );
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onScrubberMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
		
		/**
		 * Change the width of the progress bar to match movements of the
		 * scrubber when it is being dragged.
		 * 
		 * @param	p_evt	(MouseEvent) mouse move event
		 * @return	void
		 */
		private function _onScrubberMouseMove( p_evt:MouseEvent ):void
		{
			current_mc.width = scrubber_mc.x + _scrubberPadding;
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onStageMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
	}
}