package com.realeyes.osmfplayer.managers
{
	import com.realeyes.osmfplayer.events.ConfigLoadedEvent;
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.osmf.media.MediaFactory;
	
	[Event( name="configLoaded", type="com.osmf.events.ConfigLoadedEvent" )]
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]
	[Event( name="progress", type="flash.events.ProgressEvent" )]
	
	/**
	 * Configuration Manager loads in the config file for the player
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ConfigurationManager extends EventDispatcher
	{
		//==============================================
		// Declarations
		//==============================================
		/**
		 * Path for the config file	(String)
		 */
		public var configPath:String;
		
		/**
		 * Should the config be loaded as soon as the path is supplied?	(Boolean)
		 */
		public var autoLoadConfig:Boolean;
		
		protected var _loader:URLLoader;
		protected var _mediaFactory:MediaFactory;
		
		//==============================================
		// Init Methods
		//==============================================
		/**
		 * Constructor
		 * @param	configPath		(String) URL for the config XML file
		 * @param	autoLoadConfig	(Boolean) should the config be loaded now? Defaults to true
		 * @return	void
		 */
		public function ConfigurationManager( configPath:String, mediaFactory:MediaFactory=null, autoLoadConfig:Boolean=true )
		{
			this.configPath = configPath;
			this.autoLoadConfig = autoLoadConfig;
			_mediaFactory = mediaFactory;
			_init();
		}
		
		/**
		 * Initializes the config manager by loading in the config (if autoLoadConfig)
		 * 
		 * @return	void
		 */
		private function _init():void
		{
			if( autoLoadConfig )
			{
				load();
			}
		}
		
		//==============================================
		// Control Methods
		//==============================================
		/**
		 * Loads in a config file, and monitors loading and fault events
		 * 
		 * @param	pathToConfig	(String) URL for the config file. Defaults to ''.
		 * @return	void
		 */
		public function load( pathToConfig:String="" ):void
		{
			if( pathToConfig != "" ) // If they are passing in a new config path
			{
				this.configPath = pathToConfig;
			}
			trace( "Config Path: " + this.configPath  );
			var request:URLRequest = new URLRequest( this.configPath );
			_loader = new URLLoader( request );
			_loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			_loader.addEventListener( Event.COMPLETE, _onConfigLoaded );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, _onHTTPStatus );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, _onIOError );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onSecurityError );
			_loader.addEventListener( ProgressEvent.PROGRESS, _onProgress );
			
			_loader.load( request );
		}
		
		//==============================================
		// Event Handlers
		//==============================================
		/**
		 * Once the config has loaded, parse the config XML and
		 * broadcast a ConfigLoadedEvent with the parsed config
		 * attached.
		 * 
		 * @param	event	(Event) Event.COMPLETE event
		 * @return	void
		 */
		protected function _onConfigLoaded( event:Event ):void
		{
			var configXML:XML = new XML( _loader.data );
			var playerConfig:PlayerConfig = new PlayerConfig( _mediaFactory );
			playerConfig.base = this.configPath;
			playerConfig.parseConfigXML( configXML );
			
			dispatchEvent( new ConfigLoadedEvent( playerConfig ) );
		}
		
		/**
		 * Relays an HTTPStatusEvent
		 * @param	event	(HTTPStatusEvent) HTTPStatusEvent.HTTP_STATUS
		 * @return	void
		 */	
		private function _onHTTPStatus( event:HTTPStatusEvent ):void
		{
			dispatchEvent( event );
		}
		
		/**
		 * Relays an IOErrorEvent
		 * 
		 * @param	event	(IOErrorEvent) IOErrorEvent.IO_ERROR
		 * @return	void
		 */
		private function _onIOError( event:IOErrorEvent ):void
		{
			dispatchEvent( event );
		}

		/**
		 * Relays a security error event
		 * 
		 * @param	event	(SecurityErrorEvent) SecurityErrorEvent.SECURITY_ERROR
		 * @return	void
		 */
		private function _onSecurityError( event:SecurityErrorEvent ):void
		{
			dispatchEvent( event );
		}

		/**
		 * Relays a progress event while the config loads
		 * 
		 * @param	event	(ProgressEvent) ProgressEvent.PROGRESS
		 * @return	void
		 */
		private function _onProgress( event:ProgressEvent ):void
		{
			dispatchEvent( event );
		}
		
	}
}