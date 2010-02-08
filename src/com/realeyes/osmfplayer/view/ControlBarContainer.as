package com.realeyes.osmfplayer.view
{
	
	import com.realeyes.osmfplayer.controls.ClosedCaptionField;
	import com.realeyes.osmfplayer.controls.ControlBar;
	import com.realeyes.osmfplayer.controls.LoadingIndicator;
	import com.realeyes.osmfplayer.controls.SkinElementBase;
	import com.realeyes.osmfplayer.events.ControlBarEvent;
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	import com.realeyes.osmfplayer.model.config.skin.SkinConfig;
	import com.realeyes.osmfplayer.model.config.skin.SkinElement;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	
	import org.osmf.display.MediaPlayerSprite;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	[Event(name="showClosedcaption", type="com.realeyes.osmfplayer.events.ControlBarEvent")]
	[Event(name="hideClosedcaption", type="com.realeyes.osmfplayer.events.ControlBarEvent")]
	/**
	 * Container for the control bar that manages layout of buttons, display of the
	 * skin, and handling control logic for user/player interaction
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */ 
	public class ControlBarContainer extends Sprite
	{
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
//SHOULD WE TYPE THIS TO THE ControlBar base class or leave generic so it doesnt compile in?
		protected var _controlBar:ControlBar;
		private var _loadingIndicator:LoadingIndicator;
		private var _closedCaptionField:ClosedCaptionField;
		
		protected var _mediaPlayerShell:MediaPlayerSprite;
		private var _mediaPlayerCore:MediaPlayer;
		
		private var _currentState:String;
		
		//private var _scaleMode:String;
		
		private var _path:String;
		
		private var _hasCaptions:Boolean;
		private var _isLive:Boolean;
		private var _autoHide:Boolean;
		
		private var _loader:Loader;
		
		private var _bytesTotal:Number;
		
		
		
		private var _hideControlsTimer:Timer;
		private var _hideControlsDelay:uint = 2000;
		
		private var _mouseOverControls:Boolean;
		private var _mouseOverShell:Boolean;
		
		private var _bufferTimer:Timer;
		private var _bufferInterval:uint = 100;
		
		private var _restoreWidth:Number;
		private var _restoreHeight:Number;
		
		
		/**
		 * The skinElements to apply to the view	(Array)
		 */		
		private var _skinElements:Array;
		private var _skinElementInstances:Array;
		
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		/**
		 * Constructor
		 * @param	p_player		(MediaPlayerSprite) the instance of the player for this control bar
		 * @param	p_isLive		(Boolean) is the media live?
		 * @return	ControlsBarContainer
		 */
		public function ControlBarContainer( p_player:MediaPlayerSprite, p_isLive:Boolean )
		{
			super();
			
			_init( p_player, p_isLive );
		}
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		/**
		 * Initializes the control bar with starting settings
		 * 
		 * @param	p_player		(MediaPlayerSprite) the instance of the player for this control bar
		 * @param	p_isLive		(Boolean) is the media live?
		 * @return	void
		 */ 
		private function _init( p_player:MediaPlayerSprite, p_isLive:Boolean ):void
		{
			
			_skinElementInstances = new Array();
			
			_mediaPlayerShell = p_player;
			
			_mediaPlayerCore = _mediaPlayerShell.mediaPlayer;
			
		
			_isLive = p_isLive;
			
			
			_hideControlsTimer = new Timer( _hideControlsDelay, 1 );
			_hideControlsTimer.addEventListener( TimerEvent.TIMER_COMPLETE, _onHideControlsTimerComplete );
		}
		
		
		/**
		 * Initializes listening for player events
		 * 
		 * @return	void
		 */
		private function _initMediaPlayerListeners():void
		{
			trace("duration: " + _mediaPlayerCore.duration);
						
			_mediaPlayerCore.addEventListener(PlayEvent.PLAY_STATE_CHANGE, _onMediaStateChange, false, 0, true);
			_mediaPlayerCore.addEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, _onPlayerStateChange, false, 0, true );
			_mediaPlayerCore.addEventListener( TimeEvent.CURRENT_TIME_CHANGE, _onCurrentTimeChange, false, 0, true );
			_mediaPlayerCore.addEventListener( TimeEvent.DURATION_CHANGE, _onDurationTimeChange, false, 0, true );
			
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFER_TIME_CHANGE, _onBufferTimeChange );
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFERING_CHANGE, _onBufferingChange, false, 0, true );
			
			_mediaPlayerCore.addEventListener( LoadEvent.BYTES_LOADED_CHANGE, _onBytesLoadedChange, false, 0, true );
			_mediaPlayerCore.addEventListener( LoadEvent.BYTES_TOTAL_CHANGE, _onBytesTotalChange, false, 0, true );
			
			_mediaPlayerCore.addEventListener( DynamicStreamEvent.SWITCHING_CHANGE, _onSwitchChange, false, 0, true );
			_mediaPlayerCore.addEventListener( MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, _onIsDynamicStreamChange, false, 0, true );
			
		}
		
		/**
		 * Listen for user interaction with the control bar
		 * 
		 * @return	void
		 */
		private function _initControlBarListeners():void
		{
			_controlBar.addEventListener( ControlBarEvent.STOP, _onStop, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.PLAY, _onPlay, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SEEK, _onSeek, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.PAUSE, _onPause, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.MUTE, _onMute, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.UNMUTE, _onUnMute, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME, _onVolumeChange, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME_UP, _onVolumeUp, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME_DOWN, _onVolumeDown, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.FULLSCREEN, _onFullScreen, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.FULLSCREEN_RETURN, _onFullscreenReturn, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onShowClosedcaption, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onHideClosedCaption, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.BITRATE_UP, _onBitrateUp, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.BITRATE_DOWN, _onBitrateDown, false, 0, true );
			
			/*if( _autoHide )
			{
				_controlBar.addEventListener( MouseEvent.MOUSE_OVER, _onControlBarMouseOver, false, 0, true );
				_controlBar.addEventListener( MouseEvent.MOUSE_OUT, _onControlBarMouseOut, false, 0, true );
				
			}*/
		}
		
	//TODO - need to figure out when to run this. Not sure how/where with the new skinElement system	
		private function _removeControlBarListeners():void
		{
			_controlBar.removeEventListener( ControlBarEvent.STOP, _onStop );
			_controlBar.removeEventListener( ControlBarEvent.PLAY, _onPlay );
			_controlBar.addEventListener( ControlBarEvent.SEEK, _onSeek );
			_controlBar.removeEventListener( ControlBarEvent.PAUSE, _onPause );
			_controlBar.removeEventListener( ControlBarEvent.MUTE, _onMute );
			_controlBar.removeEventListener( ControlBarEvent.UNMUTE, _onUnMute );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME, _onVolumeChange );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME_UP, _onVolumeUp );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME_DOWN, _onVolumeDown );
			_controlBar.removeEventListener( ControlBarEvent.FULLSCREEN, _onFullScreen );
			_controlBar.removeEventListener( ControlBarEvent.FULLSCREEN_RETURN, _onFullscreenReturn );
			_controlBar.removeEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onShowClosedcaption );
			_controlBar.removeEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onHideClosedCaption );
			_controlBar.removeEventListener( ControlBarEvent.BITRATE_UP, _onBitrateUp );
			_controlBar.removeEventListener( ControlBarEvent.BITRATE_DOWN, _onBitrateDown );
			
			if( autoHide )
			{
				_controlBar.removeEventListener( MouseEvent.MOUSE_OVER, _onControlBarMouseOver );
				_controlBar.removeEventListener( MouseEvent.MOUSE_OUT, _onControlBarMouseOut );
			}
			
		}
		
		public function _generateInstance( p_skinElement:SkinElement ):SkinElementBase
		{
			//var elementClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			return this.addChild( p_skinElement.buildSkinElement()  ) as SkinElementBase;
		}
		
		
		
		public function initControlBarInstance( p_skinElement:SkinElementBase ):void
		{
			//trace("ControlBarContainer - completeHandler: " + p_evt);
			
			_controlBar = p_skinElement as ControlBar;
			
			_controlBar.isLive = _isLive;
			_controlBar.hasCaptions = hasCaptions;
			
			autoHide = _controlBar.autoHide;
			
			_initMediaPlayerListeners();
			_initControlBarListeners();
			
			
			//IS THIS BAD OR EVEN NEEDED?
			if( _mediaPlayerCore.duration )
			{
				_controlBar.duration = _mediaPlayerCore.duration;
			}	
			
			
			if( _mediaPlayerCore.bytesTotal )
			{
				_bytesTotal = _mediaPlayerCore.bytesTotal;
			}
			
			
			
			if( _mediaPlayerCore.playing )
			{
				_controlBar.currentState = PlayState.PLAYING;
			}
			else
			{
				_controlBar.currentState = PlayState.STOPPED;
			}
			
			
			
			
			if( _mediaPlayerCore.canBuffer )
			{
				_startBufferTimer();
			}
			else
			{
				_stopBufferTimer();
			}
			
			if( _mediaPlayerCore.isDynamicStream )
			{
				_controlBar.bitrateUpEnabled();
				_controlBar.bitrateDownEnabled();
			}
			else
			{
				_controlBar.bitrateUpDisabled();
				_controlBar.bitrateDownDisabled();
			}
			
			
		}
		
		
		public function initLoadingIndicatorInstance( p_skinElement:SkinElementBase ):void
		{
			//var loaderIndicatorClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			_loadingIndicator = p_skinElement as LoadingIndicator;
			_loadingIndicator.visible = false;
		}
		
		public function initClosedCaptionFieldInstance( p_skinElement:SkinElementBase ):void
		{
			
			//var closedCaptionFieldClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			_closedCaptionField = p_skinElement as ClosedCaptionField;
			trace("_closedCaptionField: " + _closedCaptionField);
			
		}
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		
		public function checkAutoPositions():void
		{
			var len:uint = _skinElementInstances.length;
			for( var i:uint = 0; i < len; i++ )
			{
				if( _skinElementInstances[i].autoPosition )
				{
					updatePosition( _skinElementInstances[ i ] );
				}
			}
		}
		
//TODO - make sure this is called on media size change		
		/**
		 * Resize and reposition the control bar and layout the controls based on the scale mode.
		 * 
		 * @return	void
		 */
		public function updatePosition( p_skinElement:SkinElementBase ):void
		{
			trace("skin scaleMode: " + p_skinElement.scaleMode );
			switch( p_skinElement.scaleMode )
			{
							
				case SkinConfig.SCALE_MODE_FIT:
				{
					var scaleAdjuster:Number = p_skinElement.height / p_skinElement.width;
					p_skinElement.width = _mediaPlayerShell.width;
					p_skinElement.height = p_skinElement.width * scaleAdjuster;
					
					
					
					break;
				}
				
				case SkinConfig.SCALE_MODE_SELECT:
				{
					//TODO -- apply if necessary
					//break;
				}
				
				default:// SkinConfig.SCALE_MODE_NONE 
				{
					
					
				}
					
					
					
				switch( p_skinElement.hAlign )
				{
					case SkinConfig.ALIGN_LEFT:
					{
						p_skinElement.x = p_skinElement.hAdjust;
						break;
					}
						
					case SkinConfig.ALIGN_RIGHT:
					{
						p_skinElement.x = (_mediaPlayerShell.width - p_skinElement.width) + p_skinElement.hAdjust;
						break;
					}
						
					case SkinConfig.ALIGN_NONE:
					{
						
						break;
					}
					case SkinConfig.ALIGN_CENTER:
					{
						
						//break;
					}
						
					default:
					{
						
						p_skinElement.x = (( _mediaPlayerShell.width / 2 ) - (p_skinElement.width / 2)) + p_skinElement.hAdjust;
						//p_skinElement.x = (( _mediaPlayerShell.x + _mediaPlayerShell.width )/2 - (p_skinElement.width / 2)) + p_skinElement.hAdjust;
					}
				}
				
				
				switch( p_skinElement.vAlign )
				{
					case SkinConfig.ALIGN_TOP:
					{
						p_skinElement.y = (p_skinElement.height) + p_skinElement.vAdjust;
						break;
					}
					
					case SkinConfig.ALIGN_CENTER:
					{
						p_skinElement.y = ( (_mediaPlayerShell.height / 2) - (p_skinElement.height / 2) ) + p_skinElement.vAdjust;
						break;
					}	
						
					case SkinConfig.ALIGN_NONE:
					{
						
						break;
					}
					case SkinConfig.ALIGN_BOTTOM:
					{
						
						//break;
					}
						
					default:
					{
						
						p_skinElement.y = (_mediaPlayerShell.height - p_skinElement.height) + p_skinElement.vAdjust;
					}
					
				}
				
				
			}
			
			/*
			if( _loadingIndicator ) 
			{
				_loadingIndicator.x = (_mediaPlayerShell.width / 2) - (_loadingIndicator.width / 2);
				_loadingIndicator.y = (_mediaPlayerShell.height / 2) - (_loadingIndicator.height / 2);
			}
			
			if( _closedCaptionField )
			{
				_closedCaptionField.x = ( ( _controlBar.x + ( _controlBar.width /2 ) ) - (_closedCaptionField.width / 2)) + closedCaptionLabelHAdjust;
				_closedCaptionField.y = (_controlBar.y - _closedCaptionField.height) + closedCaptionLabelVAdjust;
			}
			*/
		}
		
		/**
		 * Loads in an external control bar SWF
		 * 
		 * @param	p_path						(String) URL for the SWF. Defaults to null.
		 * @param	p_controlBarPath			(String) Class for the control bar. Defaults to null.
		 * @param	p_loadingIndicatorClass		(String) Class for the loading indicator. Defaults to null.
		 * @param	p_closedCaptionFieldClass	(String) Class for the field displaying captions. Defaults to null.
		 * @return	void
		 */
		public function loadExternal( p_path:String, p_skinElements:Array  ):void
		{
			_skinElements = p_skinElements;
			
			if( p_path || _path )
			{
				if( p_path )
				{
					_path = p_path;
				}
				
				if( _loader == null)
				{
					_loader = new Loader();
					_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _completeHandler );
					_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, _httpStatusHandler );
					_loader.contentLoaderInfo.addEventListener( Event.INIT, _initHandler );
					_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, _ioErrorHandler );

				}
				
				trace("loading control bar swf: " + _path );
				_loader.load( new URLRequest( _path ), new LoaderContext( false, ApplicationDomain.currentDomain ) ); 
			}
			else
			{
				throw( new Error( "No control bar path defined" ) );
			}
		}
		
		/**
		 * Calculates a percentage of two number
		 * 
		 * @param	p_current	(Number) the number whose percentage of a total you want
		 * @param	p_total		(Number) the total to compare the first value against
		 * @return	Number
		 */
		private function _calcPercent( p_current:Number, p_total:Number ):Number
		{
			var p:Number = p_current / p_total;
			
			if( p > 1 )
			{
				return 1;
			}
			
			return p;
		}
		
		/**
		 * Start monitoring the buffer time.
		 * 
		 * @return	void
		 */
		private function _startBufferTimer():void
		{
			if(_bufferTimer == null )
			{
				_bufferTimer = new Timer( _bufferInterval );
				_bufferTimer.addEventListener( TimerEvent.TIMER, _onBufferTimer );
			}
			
			trace("start buffer timer");
			_bufferTimer.start();
		}
		
		/**
		 * Stop monitoring and displaying buffer time
		 * 
		 * @return	void
		 */
		private function _stopBufferTimer():void
		{
			if( _bufferTimer )
			{
				trace("stop buffer timer");
				_bufferTimer.stop();
				_controlBar.setLoadBarPercent( 0 );
			}
		}
		

		/**
		 * Hide the control bar
		 * 
		 * @return	void
		 */
		public function hideControls():void
		{
			_controlBar.visible = false;
		}
		

		/**
		 * Show the control bar
		 * 
		 * @return	void
		 */
		public function showControls():void
		{
			_controlBar.visible = true;
		}
		
		/**
		 * Populate the caption field in the control bar
		 * 
		 * @param	p_value	(String) the text to display in the caption field
		 * @return	void
		 */
		public function setClosedCaptionText( p_value:String ):void
		{
			if( _closedCaptionField )
			{
				_closedCaptionField.text = p_value;
			}
		}
		
		
		
		private function _checkDynamicStreamingIndex():void
		{
			if( _mediaPlayerCore.isDynamicStream && _controlBar )
			{
				
				if( _mediaPlayerCore.currentDynamicStreamIndex == 0 )
				{
					_controlBar.bitrateDownDisabled();
				}
				else if( _mediaPlayerCore.currentDynamicStreamIndex == _mediaPlayerCore.maxAllowedDynamicStreamIndex )
				{
					_controlBar.bitrateUpDisabled();
				}
				
				
			}
			
		}
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		/**
		 * hasCaptions	
		 * Should the control enable the closed caption controls if they exist
		 * @return	Boolean
		 */
		public function get hasCaptions():Boolean
		{
			return _hasCaptions;
		}
		
		public function set hasCaptions( p_value:Boolean ):void
		{
			_hasCaptions = p_value;
			
			if( _controlBar )
			{
				_controlBar.hasCaptions = _hasCaptions;
			}
		}
		
		/**
		 * autoHide	
		 * Should the control bar hide automatically and show on mouseover?
		 * @return	Boolean
		 */
		public function get autoHide():Boolean
		{
			return _autoHide;
		}
		
		public function set autoHide( p_value:Boolean ):void
		{
			_autoHide = p_value;
			
			if( _autoHide )
			{
				
				
				_mediaPlayerShell.addEventListener( MouseEvent.MOUSE_OVER, _onShellMouseOver ); 
				_mediaPlayerShell.addEventListener( MouseEvent.MOUSE_OUT, _onShellMouseOut ); 
				
				if( _controlBar )
				{
					_controlBar.addEventListener( MouseEvent.MOUSE_OVER, _onControlBarMouseOver );
					_controlBar.addEventListener( MouseEvent.MOUSE_OUT, _onControlBarMouseOut );
				}
			}
			else
			{
				_mediaPlayerShell.removeEventListener( MouseEvent.MOUSE_OVER, _onShellMouseOver ); 
				
				if( _controlBar && _controlBar.hasEventListener( MouseEvent.MOUSE_OVER ) )
				{
					_controlBar.removeEventListener( MouseEvent.MOUSE_OVER, _onControlBarMouseOver );
				}
			}
			
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		
		public function generateSkinInstance( p_skinElement:SkinElement ):void
		{
			var instance:SkinElementBase;
			
			if( p_skinElement.elementClassString )
			{
				instance = _generateInstance( p_skinElement );
				
				_skinElementInstances.push( instance );
				
				//if there is an init function call it and pass the instance
				if( p_skinElement.initMethodName )
				{
					this[ p_skinElement.initMethodName ]( instance );
				}
				
				if( instance.autoPosition )
				{
					updatePosition( instance );
				}
				
				
			}
		}
		
		
		/**
		 * When the control bar has completed loading, initialize the setup.
		 * 
		 * @param	p_evt	(Event)
		 * @return	void
		 */
		private function _completeHandler( p_evt:Event ):void 
		{
			
			if( _controlBar )
			{
				_removeControlBarListeners();
			}
			
			
			
			var len:uint = _skinElements.length;
			//var element:SkinElement;
			
			for( var i:uint = 0; i < len; i++ )
			{
				//element = _skinElements[ i ];
				
				generateSkinInstance( _skinElements[ i ] );
			}
			
			/*
			initControlBarInstance( _controlBarClass );
			
			initLoadingIndicatorInstance( _loadingIndicatorClass );
			
			if( _closedCaptionFieldClass )
			{
				initClosedCaptionFieldInstance( _closedCaptionFieldClass );
			}
			*/
			
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreenRestore );
			
		}
		
		/**
		 * When there is a server problem loading the control bar SWF...
		 * 
		 * @param	p_evt	(HTTPStatusEvent)
		 * @return	void
		 */
		private function _httpStatusHandler( p_evt:HTTPStatusEvent ):void 
		{
			//trace("ControlBarContainer - httpStatusHandler: " + p_evt);
		}
		
		/**
		 * When there is a problem loading the control bar SWF...
		 * 
		 * @param	p_evt	(IOErrorEvent)
		 * @return	void
		 */
		private function _ioErrorHandler( p_evt:IOErrorEvent ):void 
		{
			//trace("ControlBarContainer - ioErrorHandler: " + p_evt);
		}
		
		
		/**
		 * When the control bar has initialized ...
		 * 
		 * @param	p_evt	(Event)
		 * @return	void
		 */
		private function _initHandler( p_evt:Event):void 
		{
			//trace("ControlBarContainer - initHandler: " + p_evt);
		}
		
		
		/**
		 * On stop click, tell the player to stop.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.STOP event
		 * @return	void
		 */
		private function _onStop( p_evt:ControlBarEvent ):void
		{
			trace("core - stop");
			_mediaPlayerCore.stop();
		}
		
		/**
		 * On play click, tell the player to play.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.PLAY event
		 * @return	void
		 */
		private function _onPlay( p_evt:ControlBarEvent ):void
		{
			trace("core - play");
			_mediaPlayerCore.play();
		}
		
		/**
		 * When the user seeks, tell the player to go to that point
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.SEEK event
		 * @return	void
		 */
		private function _onSeek( p_evt:ControlBarEvent ):void
		{
			trace("core - seek, percent: " + p_evt.seekPercent + ", duration: " + _mediaPlayerCore.duration );
			_mediaPlayerCore.seek( p_evt.seekPercent * _mediaPlayerCore.duration );
		}
		
		/**
		 * On paise click, tell the player to pause.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.PAUSE event
		 * @return	void
		 */
		private function _onPause( p_evt:ControlBarEvent ):void
		{
			trace("core - pause");
			_mediaPlayerCore.pause();
		}
		
		/**
		 * On mute click, tell the player to mute.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.MUTE event
		 * @return	void
		 */
		private function _onMute( p_evt:ControlBarEvent ):void
		{
			_mediaPlayerCore.muted = true;
		}
		
		/**
		 * On unmute click, tell the player to unmute.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.UNMUTE event
		 * @return	void
		 */
		private function _onUnMute( p_evt:ControlBarEvent ):void
		{
			_mediaPlayerCore.muted = false;
		}
		
		/**
		 * When the user uses the volume scrubber, change the volume
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME
		 * @return	void
		 */
		private function _onVolumeChange( p_evt:ControlBarEvent ):void
		{
			_mediaPlayerCore.volume = p_evt.volume;
		}
		
		/**
		 * On volume up click, tell the player to raise the volume by a percent.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME_UP event
		 * @return	void
		 */
		private function _onVolumeUp( p_evt:ControlBarEvent ):void
		{
			if( (_mediaPlayerCore.volume + .1) >= 1 )
			{
				_mediaPlayerCore.volume = 1;
			}
			else
			{
				_mediaPlayerCore.volume = _mediaPlayerCore.volume + .1;
			}
		}
		
		/**
		 * On volume down click, tell the player to lower the volume by a percent.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME_UP event
		 * @return	void
		 */
		private function _onVolumeDown( p_evt:ControlBarEvent ):void
		{
			if( (_mediaPlayerCore.volume - .1) <= 0 )
			{
				_mediaPlayerCore.volume = 0;
			}
			else
			{
				_mediaPlayerCore.volume = _mediaPlayerCore.volume - .1;
			}
		}
		
		/**
		 * On full screen click, tell the player to go fullscreen.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.FULL_SCREEN event
		 * @return	void
		 */
		private function _onFullScreen( p_evt:ControlBarEvent ):void
		{
			//updatePosition();
			//checkAutoPositions();
			
			/*NOTE: this code measures a bounding box around the player and the controls
					whether or not the controls are over the player and passes that 
					rectangle as fullScreenSourceRect for fullscreen scaling
			
			var rectX:Number = 0;
			var rectY:Number = 0;
			var rectWidth:Number = 0;
			var rectHeight:Number = 0;
			
			if( _controlBar.x < _mediaPlayerShell.x )
			{
				rectX = _controlBar.x;
				rectWidth += _mediaPlayerShell.x - _controlBar.x;
			}
			else
			{
				rectX = _mediaPlayerShell.x;
			}
			
			if( _controlBar.y < _mediaPlayerShell.y )
			{
				rectY = _controlBar.y;
				rectHeight += _mediaPlayerShell.y - _controlBar.y;
			}
			else
			{
				rectY = _mediaPlayerShell.y;
			}
			
			if( _controlBar.x + _controlBar.width > _mediaPlayerShell.x + _mediaPlayerShell.width )
			{
				rectWidth = _controlBar.x + _controlBar.width - _mediaPlayerShell.x;
			}
			else
			{
				rectWidth += _mediaPlayerShell.width;
			}

			if( _controlBar.y + _controlBar.height > _mediaPlayerShell.y + _mediaPlayerShell.height)
			{
				rectHeight = _controlBar.y + _controlBar.height - _mediaPlayerShell.y;
			}
			else
			{
				rectHeight += _mediaPlayerShell.height;
			}
			
			stage.fullScreenSourceRect = new Rectangle(	rectX, rectY, rectWidth, rectHeight );*/
			
			_restoreWidth = _mediaPlayerShell.width;
			_restoreHeight = _mediaPlayerShell.height;
			
			_mediaPlayerShell.width = stage.fullScreenWidth;
			_mediaPlayerShell.height = stage.fullScreenHeight;
			
			if( _controlBar )
			{
				_controlBar.x = ( _mediaPlayerShell.width / 2 ) - ( _controlBar.width / 2 );
				_controlBar.y = _mediaPlayerShell.height - _controlBar.height;
			}
			
			
			if( _closedCaptionField )
			{
				updatePosition( _closedCaptionField );
			}
			
			stage.displayState = StageDisplayState.FULL_SCREEN;
			
			_mediaPlayerShell.addEventListener( MouseEvent.MOUSE_MOVE, _onShellMouseMove );
			_mouseOverShell = false;
		}
		
		private function _onShellMouseMove( event:MouseEvent ):void
		{
			showControls();
			
			_hideControlsTimer.reset();
			_hideControlsTimer.start();
		}
		
		/**
		 * On full screen toggle, tell the player to leave fullscreen.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.FULL_SCREEN_RETURN event
		 * @return	void
		 */
		private function _onFullscreenReturn( p_evt:ControlBarEvent ):void
		{
			stage.displayState = StageDisplayState.NORMAL;
		}
		
		/**
		 * When the player returns to normal from fullscreen mode, restore original size
		 * and positioning
		 * 
		 * @param	p_evt	(FullScreenEvent)
		 * @return	void
		 */
		private function _onFullScreenRestore( p_evt:FullScreenEvent ):void
		{
			if( stage.displayState == StageDisplayState.NORMAL )
			{
				_mediaPlayerShell.width = _restoreWidth;
				_mediaPlayerShell.height = _restoreHeight;
				
				_hideControlsTimer.reset();
				_hideControlsTimer.stop();
				
				_mediaPlayerShell.removeEventListener( MouseEvent.MOUSE_MOVE, _onShellMouseMove );
				
				//updatePosition();
				checkAutoPositions();
			}
		}
		
		/**
		 * On captioning toggle, display the caption field
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.SHOW_CLOSEDCAPTION event
		 * @return	void
		 */
		private function _onShowClosedcaption( p_evt:ControlBarEvent ):void
		{
			_closedCaptionField.visible = true;
			this.dispatchEvent( p_evt.clone() );
		}
		
		/**
		 * On captioning toggle, hide the caption field
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.HIDE_CLOSEDCAPTION event
		 * @return	void
		 */
		private function _onHideClosedCaption( p_evt:ControlBarEvent ):void
		{
			_closedCaptionField.visible = false;	
			setClosedCaptionText( "" );
			this.dispatchEvent( p_evt.clone() );
		}
		
		
		
		/**
		 * When the user switches streams, check to see if we are at the highest
		 * or lowest stream and enabled bitrate controls accordingly.
		 * 
		 * @param	p_evt	(SwitchEvent)
		 * @return	void
		 */
		private function _onSwitchChange( p_evt:DynamicStreamEvent ):void
		{
			//TODO: Need to verify p_evt.switching is the equiv of old p_evt.newState == SwitchEvent.SWITCHSTATE_COMPLETE
			if( !p_evt.switching )
			{
				if( _mediaPlayerCore.currentDynamicStreamIndex != 0 )
				{
					_controlBar.bitrateDownEnabled();
				}
				
				if( _mediaPlayerCore.currentDynamicStreamIndex != _mediaPlayerCore.maxAllowedDynamicStreamIndex )
				{
					_controlBar.bitrateUpEnabled();
				}
				
			}
		}
		
		/**
		 * On bitrate up click, tell the player to play a higher bitrate stream. Disable
		 * bitrate change buttons if necessary. Disables auto switching.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.BITRATE_UP event
		 * @return	void
		 */
		private function _onBitrateUp( p_evt:ControlBarEvent ):void
		{
			trace("SWITCH UP");
			
			if( _mediaPlayerCore.autoDynamicStreamSwitch )
			{
				_mediaPlayerCore.autoDynamicStreamSwitch = false;
			}
			
			_mediaPlayerCore.switchDynamicStreamIndex( _mediaPlayerCore.currentDynamicStreamIndex + 1 );
			_controlBar.bitrateUpDisabled();
			_controlBar.bitrateDownDisabled();
			
		}
		
		/**
		 * On bitrate down click, tell the player to play a lower bitrate stream. Disable
		 * bitrate change buttons if necessary. Disables auto switching.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.BITRATE_UP event
		 * @return	void
		 */
		private function _onBitrateDown( p_evt:ControlBarEvent ):void
		{
			trace("SWITCH DOWN");
			
			if( _mediaPlayerCore.autoDynamicStreamSwitch )
			{
				_mediaPlayerCore.autoDynamicStreamSwitch = false;
			}
			
			_mediaPlayerCore.switchDynamicStreamIndex( _mediaPlayerCore.currentDynamicStreamIndex - 1 );
			_controlBar.bitrateUpDisabled();
			_controlBar.bitrateDownDisabled();
			
			
		}
		
		
		/**
		 * When the duration changes when media changes, update the display of the total time
		 * 
		 * @param	p_evt	(TimeEvent) TimeEvent.DURATION_CHANGE
		 * @return	void
		 */
		private function _onDurationTimeChange( p_evt:TimeEvent ):void
		{
			if( p_evt.time )
			{
				_controlBar.duration = Math.round( p_evt.time );
			}
		}
		
		/**
		 * Update the current time as progress events are received
		 * 
		 * @param	p_evt	(TimeEvent) TimeEvent.CURRENT_TIME_CHANGE
		 * @return	void
		 */
		private function _onCurrentTimeChange( p_evt:TimeEvent ):void
		{
			_controlBar.currentTime = Math.round( p_evt.time );
			_controlBar.setCurrentBarPercent( _calcPercent( p_evt.time, _controlBar.duration ) );
		}
		
		
		/**
		 * Update the buffer bar.
		 * 
		 * @param	p_evt	(TimerEvent) TimerEvent.TIMER
		 * @return	void
		 */
		private function _onBufferTimer( p_evt:TimerEvent ):void
		{
			if( _mediaPlayerCore.canBuffer )
			{
				//trace("currentTime: " + _mediaPlayerCore.currentTime);
				//trace("_mediaPlayerCore.bufferLength: " + _mediaPlayerCore.bufferLength);
				//trace("_controlBar.duration: " + _controlBar.duration);
				//trace("///////////////////");
				_controlBar.setLoadBarPercent( _calcPercent( (_mediaPlayerCore.currentTime + _mediaPlayerCore.bufferLength), _controlBar.duration ) );
			}
		}
		
		/**
		 * When the player's buffer changes ...
		 * 
		 * @param	p_evt	(BufferEvent) BufferEvent.BUFFER_CHANGED
		 * @return	void
		
		private function _onBufferingChange( p_evt:BufferEvent ):void
		{
			//p_evt.buffering
			if( _mediaPlayerCore.canBuffer )
			{
				//TODO - display buffering indicator
				
				trace("p_evt.buffering: " + p_evt.buffering);
				
				if( p_evt.buffering )
				{
					
				}
				else
				{
					
				}
			}
		} */
		
		
		/**
		 * As the media loads, display the loading progress via the load bar
		 * 
		 * @param	p_evt	(LoadEvent)
		 * @return	void
		 */
		private function _onBytesLoadedChange( p_evt:LoadEvent ):void
		{
			
			_controlBar.setLoadBarPercent( _calcPercent( p_evt.bytes, _bytesTotal ) );
			
		}
		
		/**
		 * When beginning loading media, update the total bytes to load
		 * 
		 * @param	p_evt	(LoadEvent)
		 * @return	void
		 */
		private function _onBytesTotalChange( p_evt:LoadEvent ):void
		{
			
			_bytesTotal = p_evt.bytes;
			
		}
		
		/**
		 * During non-progressive playback, stop buffer feedback when the media is
		 * paused or stopped, and start displaying buffer feedback when playing.
		 * 
		 * @param	p_evt	(PlayEvent)
		 * @return	void
		 */
		private function _onMediaStateChange( p_evt:PlayEvent ):void
		{
			_currentState = _controlBar.currentState = p_evt.playState;
			
			trace(">> STATE: " + _currentState);
			
			if( _mediaPlayerCore.canBuffer )
			{
			
				switch( _currentState )
				{
					//case PlayState.PAUSED :
					case PlayState.STOPPED :
					{
						_stopBufferTimer();
						break;
					}
					case PlayState.PLAYING :
					{
						
						_startBufferTimer();
						break;
					}
				}
			}
		}
		
		
		
		
		/**
		 * When the player's state changes, hide the loading indicator if the player is
		 * not buffering. Otherwise, show the loading indicator
		 * 
		 * @param	p_evt	(MediaPlayerStateChangeEvent)
		 * @return	void
		 */
		private function _onPlayerStateChange( p_evt:MediaPlayerStateChangeEvent ):void
		{
			
			_currentState = _controlBar.currentState = p_evt.state;
			/*
			if( p_evt.state == MediaPlayerState.BUFFERING || p_evt.state == MediaPlayerState.LOADING )
			{
				_loadingIndicator.visible = true;
			}
			else
			{
				_loadingIndicator.visible = false;
			}
			*/
			
			switch( p_evt.state )
			{
				case MediaPlayerState.LOADING :
				case MediaPlayerState.BUFFERING :
				{
					_loadingIndicator.visible = true;
					break;
				}
				case MediaPlayerState.PAUSED :
				case MediaPlayerState.READY :
				{
					//break;
				}
				case MediaPlayerState.PLAYING :
				{
					_loadingIndicator.visible = false;
					_checkDynamicStreamingIndex();
					break;
				}
			}
			
		}
		
		
		private function _onIsDynamicStreamChange( p_evt:MediaPlayerCapabilityChangeEvent ):void
		{
			
			if( p_evt.enabled && _controlBar )
			{
				_controlBar.bitrateUpEnabled();
				_controlBar.bitrateDownEnabled();
			}
			else
			{
				_controlBar.bitrateUpDisabled();
				_controlBar.bitrateDownDisabled();
			}
			
		}
		
		
		/**
		 * After a delay, check to see if the user is over the player. If they aren't, 
		 * hide the controls. Otherwise, keep checking to see when they mouse out.
		 * 
		 * @param	event	(TimerEvent) TimerEvent.TIMER
		 * @return	void
		 */
		private function _onHideControlsTimerComplete( event:TimerEvent ):void
		{
			//trace(">>> _mouseOverControls: " + _mouseOverControls );
			if( ( stage.displayState == StageDisplayState.FULL_SCREEN || !_mouseOverShell ) && !_mouseOverControls )
			{
				hideControls();
			}
			else
			{
				_hideControlsTimer.reset();
				_hideControlsTimer.start();
			}
		}
		
		/**
		 * When the user mouses over the control bar, show the controls if hidden,
		 * and monitor user activity to see when to hide the controls
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onControlBarMouseOver( event:MouseEvent ):void
		{
			
			if( !_controlBar.visible )
			{
				showControls();
			}
			
			if( stage.displayState == StageDisplayState.NORMAL )
			{
				_hideControlsTimer.reset();
				_hideControlsTimer.start();
			}
			
			_mouseOverControls = true;
			
		}
		
		/**
		 * When the user mouses out from the control bar, notify the control bar
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onControlBarMouseOut( event:MouseEvent ):void
		{
			
			_mouseOverControls = false;
			
		}
		
		/**
		 * When the user mouses over the player shell, show the controls if hidden,
		 * and monitor user activity to see when to hide the controls
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onShellMouseOver( event:MouseEvent ):void
		{
			if( _controlBar && !_controlBar.visible )
			{
				showControls();
			}
			
			_hideControlsTimer.reset();
			_hideControlsTimer.start();
			
			if( autoHide )
			{
				_mouseOverShell = true;
			}
		}
		
		/**
		 * When the user mouses out from the player, notify the control bar
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		private function _onShellMouseOut( event:MouseEvent ):void
		{
			_mouseOverShell = false;
		}
	}
}