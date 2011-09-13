package
{
	import com.realeyes.osmfplayer.events.ConfigLoadedEvent;
	import com.realeyes.osmfplayer.events.ControlBarEvent;
	import com.realeyes.osmfplayer.events.PluginsLoadedEvent;
	import com.realeyes.osmfplayer.managers.ConfigurationManager;
	import com.realeyes.osmfplayer.media.REMediaFactory;
	import com.realeyes.osmfplayer.model.Plugin;
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	import com.realeyes.osmfplayer.util.PlaylistManager;
	import com.realeyes.osmfplayer.util.PluginLoader;
	import com.realeyes.osmfplayer.util.net.ReconnectionManager;
	import com.realeyes.osmfplayer.util.parser.MediaElementConfigParser;
	import com.realeyes.osmfplayer.view.SkinContainer;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.NetConnection;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.captioning.CaptioningPluginInfo;
	import org.osmf.captioning.model.Caption;
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.StreamingURLResource;
	
	/**
	 * Creates a video player based off of an external XML configuration
	 * file.
	 * 
	 * @author	RealEyes Media
	 * @version	0.1
	 */ 
	[SWF(width="768", height="600")]
	[IconFile("osmf.png")]
	public class REOPS extends Sprite
	{
		
		//TODO - need to figure out why 2 streams showing up in manager when we play back a vid - one of them is unamed or something..grrr	
		//TODO - evaluate if we can update the control bar system to a media element and integrate in the player and the layout management via LayoutUtils
		//--need to look into MediaFactory
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		static public const CAPTIONING_PLUGIN_PATH:String = "org.osmf.captioning.CaptioningPluginInfo";
		
		static public const UNAUTHORIZED_DOMAIN:String = 'unauthorizedDomain';
		
		protected var _configManager:ConfigurationManager;
		protected var _pluginLoader:PluginLoader;
		protected var _playerConfig:PlayerConfig;
		protected var _mediaFactory:MediaFactory;
		
		protected var _skin:SkinContainer;
		
		protected var _playlistManager:PlaylistManager;
		
		protected var _mediaPlayerShell:MediaContainer; 
		protected var _mediaPlayerCore:MediaPlayer; 
		protected var _timelineMetaData:TimelineMetadata; 
		
		private var _mediaResource:MediaResourceBase;
		protected var _mediaElement:MediaElement;
		
		protected var _netConnectionFactory:NetConnectionFactory;
		protected var _netConnection:NetConnection;
		protected var _reconnectManager:ReconnectionManager;
		
		protected var _loaderInfoParams:Object;
		
		/**
		 * configPath	(String) the path for the config file
		 * This property can be set through FlashVars.
		 * 
		 * @default		"assets/data/reosmf_config.xml"
		 */
		[Inspectable(defaultValue="assets/data/reosmf_config.xml")]
		public var configPath:String;
		
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/reosmf_config.xml";
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/PlayerConfig_DynStreams.xml";
		
		//TESTING ONLY		
		//private static const REMOTE_PROGRESSIVE:String = "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
		//private static const TEST_VOD_URL:String = "rtmp://127.0.0.1/vod/sample";
		//private static const TEST_PROGRESSIVE_URL:String = "assets/seeker.flv";
		
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/PlayerConfig_MediaElements.xml";
		
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/PlayerConfig_DynStreams.xml";
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/PlayerConfig_Progressive.xml";
		//public static const CONFIG_DEFAULT_PATH:String = "assets/data/PlayerConfig_Streaming.xml";
		public static const CONFIG_DEFAULT_PATH:String = "assets/data/reosmf_config.xml";
		
		//REOPS RELEASE VERSION
		public static const VERSION:Number = 0.1;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function REOPS( p_loaderInfoParams:Object = null )
		{
			trace( "REOSMF - Contruct" );
			
			
			//if this instance is at root
			if( loaderInfo )
			{
				_loaderInfoParams = loaderInfo.parameters;
				loaderInfo.addEventListener( Event.INIT, _init );
				return;
			}
			
			if( p_loaderInfoParams )
			{
				_loaderInfoParams = p_loaderInfoParams;
				
			}
			else if( this.root && this.root.loaderInfo )
			{
				_loaderInfoParams = this.root.loaderInfo.parameters;
			}
			else
			{
				_loaderInfoParams = new Object();
			}
			
			_init();
			
		}
		
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		
		/**
		 * Initialize the player. The first step is to load in
		 * the config file through a ConfigurationManager.
		 * 
		 * @return	void
		 */
		private function _init( p_evt:Event=null ):void
		{
			if( stage )
			{
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
			}

			// Initialize the External Interface Manager and add any callbacks
			_initExternalInterface();

			// Create the connection factory
			_initConnectionFactory();
			
			// Create our MediaFactory
			_initMediaFactory();
			
			// Start the process by loading the config 
			_loadConfigFile();
		}
		
		protected function _initConfigManager():void
		{
			//Load the specified config file, pulling the path from FlashVars, if need be
			_configManager = new ConfigurationManager( CONFIG_DEFAULT_PATH, _mediaFactory, false );
			_configManager.addEventListener( ConfigLoadedEvent.CONFIG_LOADED, _configLoadHandler, false, 0, true );
		}
		
		protected function _loadConfigFile():void
		{
			_initConfigManager();
			
			trace("configPath: " + configPath);
			
			if( _loaderInfoParams.configPath )
			{
				_configManager.load( _loaderInfoParams.configPath );
			}
			else if( configPath )
			{
				_configManager.load( configPath );
			}
			else
			{
				_configManager.load();
			}
		}
		
		/**
		 * Initialize the external interface for JS communication
		 * 
		 * @return	void
		 */
		protected function _initExternalInterface():void
		{
			if( ExternalInterface.available )
			{
				ExternalInterface.addCallback( "changeMedia", changeMediaElement );	
			}
			else
			{
				trace( "External interface not available" );	
			}
		}
		
		/**
		 * Initialize the control bar with settings pulled from the config file. Loads
		 * in the skin for the control bar
		 * 
		 * @return	void
		 */
		protected function _initSkin():void
		{
			_skin = new SkinContainer( _mediaPlayerShell, _mediaPlayerCore, _playerConfig.isLive );
			
			_skin.hasCaptions = _playerConfig.hasCaptions;
			
			_skin.loadExternal(_playerConfig.skinConfig.path, _playerConfig.skinConfig.getSkinElements() );	
			
			_skin.addEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onRemoveClosedCaption );
			_skin.addEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onDisplayClosedCaption );
			
			this.addChild( _skin );
		}
		
		/**
		 * Initializes the media player and adds it to the stage
		 * 
		 * @return	void
		 */
		protected function _initMediaPlayer():void
		{
			var k:ParallelElement;
			var l:SerialElement;
			_mediaPlayerCore = new MediaPlayer();
			_mediaPlayerCore.autoPlay = _playerConfig.autoPlay;
			_mediaPlayerCore.currentTimeUpdateInterval = _mediaPlayerCore.bytesLoadedUpdateInterval= _playerConfig.updateInterval;
			//_mediaPlayerCore.bufferTime = 25;			
			//_mediaPlayerShell.scaleMode = _playerConfig.scaleMode;// ScaleMode.LETTERBOX; // 
			
			var layoutMeta:LayoutMetadata = new LayoutMetadata();
			if( _playerConfig.width )
			{
				layoutMeta.width = _playerConfig.width;
			}
			else
			{
				layoutMeta.width = stage.stageWidth;
			}
			
			if( _playerConfig.height )
			{
				//layoutMeta.percentHeight = 100;
				layoutMeta.height = _playerConfig.height;
			}
			else
			{
				layoutMeta.height = stage.stageHeight;
			}
			
			layoutMeta.scaleMode = _playerConfig.scaleMode;
			_mediaPlayerShell = new MediaContainer( null, layoutMeta );
			
			
			
			addChild( _mediaPlayerShell );
		}
		
		/**
		 * Initializes the NetConnectionFactory
		 * 
		 * @return	void
		 */
		protected function _initConnectionFactory():void
		{
			_netConnectionFactory = new NetConnectionFactory();
			
			_netConnectionFactory.addEventListener( NetConnectionFactoryEvent.CREATION_COMPLETE, _onCreateNetConnectionSuccess );
			_netConnectionFactory.addEventListener( NetConnectionFactoryEvent.CREATION_ERROR, _onCreateNetConnectionFault );
		}
		
		/**
		 * Adds in the default media types. Currently that is only VideoElement
		 * 
		 * @return void
		 */
		protected function _initMediaFactory():void
		{
			_mediaFactory = new REMediaFactory( _netConnectionFactory );	
			
			_pluginLoader = new PluginLoader( _mediaFactory ); // Create our plugin loader
			_pluginLoader.addEventListener( PluginsLoadedEvent.PLUGINS_LOADED, _onPluginsLoaded ); // we need to listen for the plugins loaded event before we initialize any of the mediaElements
		}
		
		/**
		 * Assign the MediaElement to the MediaPlayer element
		 * 
		 * @return	void
		 */
		protected function _initMediaElement():void
		{
			//if( !_mediaElement.metadata.hasEventListener( MetadataEvent.VALUE_ADD ) && !_mediaElement.metadata.hasEventListener( MetadataEvent.VALUE_REMOVE ) )
			if( _mediaElement.metadata ) 
			{
				_mediaElement.metadata.addEventListener( MetadataEvent.VALUE_ADD, _onMetaDataAdded );
				_mediaElement.metadata.addEventListener( MetadataEvent.VALUE_REMOVE, _onMetaDataRemoved );
			}
			
			_initMediaElementLayout();
			
			_mediaPlayerShell.addMediaElement( _mediaElement );
			
			//This actually gets things playing
			_mediaPlayerCore.media = _mediaElement;
		}
		
		protected function _initPlayerComponents():void
		{
			trace("-- init sequence --");
			
			// NOTE: Had to change some of the sequencing here and in the PlayerConfig class
			//	Basically the metadata FACET event listeners weren't firing because the MediaElements from the config
			// 	were being created before they had the chance to get set up. 
			if( _playerConfig.playlist )
			{
				_mediaElement = _playerConfig.getPlaylistMediaElement( 0 );
			}
			else
			{
				_mediaElement = _playerConfig.mediaElement; // Set up the media to be played
			}
			
			_initMediaPlayer(); // Set up the player
			
			_initMediaElement(); // Kick it off
			
			_initSkin(); // Set up control
			
			if( _playerConfig.playlist )
			{
				_playlistManager = new PlaylistManager( _playerConfig, _skin, _mediaPlayerCore );
				_skin.playlistItem = _playerConfig.getPlaylistItem( 0 );
			}
		}

		
		protected function _initMediaElementLayout():void
		{
			//var layoutMeta:LayoutMetadata = new LayoutMetadata();
			//layoutMeta.scaleMode = _playerConfig.scaleMode;
			_mediaElement.addMetadata( LayoutMetadata.LAYOUT_NAMESPACE, _mediaPlayerShell.layoutMetadata );
		}
		
		/**
		 * If we are not in an allowed docom.realeyes.osmfplayer.controls.LoadingIndicatorAssetmain, do not load the media. Instead, load
		 * the player and skin, and once the skin is loaded, we can show an alert 
		 * telling the user that the domain is invalid. If it is valid, the player
		 * components will initialize once the plugins have finished loading. If there
		 * are no plugins, the _initPlugins method will proceed to initialize the 
		 * player components
		 * 
		 * @return	void
		 */
		protected function _initStartUpSequence():void
		{
			this.addEventListener( UNAUTHORIZED_DOMAIN, _onUnauthorizedDomain );
			
			if( _checkForAllowedDomain() )
			{
				removeEventListener( UNAUTHORIZED_DOMAIN, _onUnauthorizedDomain );
				_initPlugins();
			}
			else
			{
				dispatchEvent( new Event( UNAUTHORIZED_DOMAIN ) );
				
				_initMediaPlayer();
				_initSkin();
				
			}
		}
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		protected function _loadPluginsFromConfig():void
		{
			for each( var plugin:Plugin in _playerConfig.plugins )
			{
				_pluginLoader.addPlugin( plugin );
			}
		}
		
		
		
		/**
		 * Loads a new video element.
		 * 
		 * @param	p_url	(String) the URL for the video element to play
		 * @return	void
		 */
		public function changeMediaElement( p_url:String ):void
		{
			setMediaResource( p_url );
			_initMediaElement();
		}
		
		
		/**
		 * Creates the MediaResource based on the stream type specified for the player
		 * 
		 * @param	p_path		(String) URL to the media resource
		 * @param	streamType	(String) the type of streaming (PlayerConfig.PROGRESSIVE, PlayerConfig.STREAMING, PlayerConfig.DYNAMIC_Streaming, or none). Defaults to null.
		 * @return	void
		 */
		public function setMediaResource( p_path:String, streamType:String = null ):void
		{
			trace("setMediaResource: " + p_path);
			if( !streamType )
			{
				streamType = 'none';
			}
			
			switch( streamType.toUpperCase() )
			{
				case PlayerConfig.PROGRESSIVE:
				{
					_mediaResource = new URLResource( p_path );
					break;
				}
				case PlayerConfig.STREAMING:
				{
					_mediaResource = new StreamingURLResource( p_path );
					break;
				}
				case PlayerConfig.DYNAMIC_STREAMING:
				{
					var dynamicStreamingResource:DynamicStreamingResource = _parseSMIL( new XML( p_path ) ); // Here we expect SMIL xml to be sent as the media location
					
					_mediaResource =  dynamicStreamingResource;
					break;
				}
				default: // Images and SWFs
				{
					_mediaResource = new URLResource( p_path );
				}
			}
			
			// udpate the mediaElement
			_mediaElement = _mediaFactory.createMediaElement( _mediaResource );
		}
		
		/**
		 * Parses an XML document in the SMIL format and creates a Dynamic Streaming Resource
		 * from that, which contains an DynamicStreamingItem Vector.
		 * 
		 * @param	p_xml	(XML) an XML object in SMIL format
		 * @return	DynamicStreamingResource
		 */
		private function _parseSMIL( p_xml:XML ):DynamicStreamingResource
		{
			var items:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			
			var ns:Namespace = p_xml.namespace();
			
			trace( "URL: " + p_xml.ns.head.meta.@base );
			
			var dynamicStreamingResource:DynamicStreamingResource = new DynamicStreamingResource( p_xml.ns::head.meta.@base );
			
			for (var i:int = 0; i < p_xml.ns::body.ns::["switch"].ns::video.length(); i++)
			{
				var streamName:String = p_xml.ns::body.ns::["switch"].ns::video[i].@src;
				var bitrate:Number = Number(p_xml.ns::body.ns::["switch"].ns::video[i].@["system-bitrate"])/1000;
				
				items.push(new DynamicStreamingItem(streamName, bitrate));
			}
			
			dynamicStreamingResource.streamItems = items;
			
			return dynamicStreamingResource;
		}
		
		/**
		 * Handles loading the CaptioningPlugin 
		 * 
		 */
		protected function _initPlugins():void
		{
			
			if( _playerConfig.hasCaptions ) // Create and add the CC plugin
			{
				//Forces class include?
				var dummy:CaptioningPluginInfo;
				
				var ccPlugin:Plugin = new Plugin();
				var ccInfoRef:Class = getDefinitionByName( CAPTIONING_PLUGIN_PATH ) as Class;
				var ccPluginResource:MediaResourceBase = new PluginInfoResource( new ccInfoRef() );
				
				ccPlugin.resource = ccPluginResource;
				_pluginLoader.addPlugin( ccPlugin );
			}
			
			_loadPluginsFromConfig();
			
			if( _pluginLoader.hasPlugins() )
			{				
				_pluginLoader.loadPlugins();
			}
			else
			{
				_initPlayerComponents();
			}
		}
		
		/**
		 * Examines the array of allowed domains. It returns a true or false
		 * depending on whether the domain is allowed or not. It also has an
		 * exception for locally run content, by checking for 'file:' as the
		 * protocol for the URL. If there are no allowed domains specified, either
		 * by setting allowedDomains to null or to an empty Array, all domains 
		 * are allowed.
		 * 
		 * @return	Boolean
		 */
		protected function _checkForAllowedDomain():Boolean
		{
			if( ExternalInterface.available )
			{
				_playerConfig.playerURL = String( ExternalInterface.call( "window.location.href.toString" ) );
			}
			else
			{
				_playerConfig.playerURL = null;
			}
			
			var domains:Array = _playerConfig.allowedDomains;
			var swfURL:String = _playerConfig.playerURL;
			
			//If we are lacking domains or a URL for the player, don't try auth
			if( domains && domains.length > 0 && swfURL && swfURL != 'null' )
			{
				var len:uint = domains.length;
				var urlParts:Array = swfURL.split( '/' );
				
				//If we're running locally, allow access
				if( String( urlParts[0] ).toLowerCase() == 'file:' )
				{
					return true;
				}
				
				//Get the domain
				var swfDomain:String = urlParts[2];
				
				//Break it into an easy to compare collection
				var swfDomainArray:Array = swfDomain.split( '.' );
				var swfDomainLength:uint = swfDomainArray.length;
				
				//Loop through the allowed domains
				for( var i:uint = 0; i < len; i++ )
				{
					//Break the domain down into easy to compare bits
					var domain:String = domains[i];
					var domainArray:Array = domain.split( '.' );
					var domainLength:uint = domainArray.length;
					
					//If the swf domain isn't long enough to match the domain length, don't
					//even bother doing a comparison
					if( swfDomainLength >= domainLength )
					{
						//Start at the end of the domain array, and come back through
						//in order to prevent hinky subdomain tomfoolery
						for( var j:uint = 0; j < domainLength; j++ )
						{
							//If this part of the domain doesn't match, break the loop
							if( swfDomainArray[ swfDomainLength - 1 - j ] != domainArray[ domainLength - 1 - j ] )
							{
								break;
							}
							
							//If we make it through the whole loop without a miss, we have a match
							if( j == domainLength - 1 )
							{
								return true;
							}
						}
					}
				}
				
				return false;
			}
			else
			{
				return true;
			}
		}
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		
		/**
		 * Once the config file has been loaded, create the media player and control bar.
		 * Also, based on the playback type, load in the appropriate media resource from the
		 * config. Then, load in any plugins specified in the config file and create the VideoElement
		 * to play the video
		 * 
		 * @param	p_evt	(ConfigLoadedEvent)
		 * @return	void
		 */
		protected function _configLoadHandler( p_evt:ConfigLoadedEvent ):void
		{
			_playerConfig = p_evt.config;
			
			_initStartUpSequence();
		}
		
		/**
		 * Once all of the plugins are loaded we can initialize the media elements
		 * 	and then kick everything off to display the video and control elements 
		 * 
		 */
		protected function _onPluginsLoaded( event:PluginsLoadedEvent ):void
		{
			_initPlayerComponents();
		}
		
		/**
		 * Once the NetConnection has been created, set it as the NetConnection for the player.
		 * When the NetConnection is first created, grab the NetConnection and
		 * use it to initilaize the ReconnectionManager. Because the NetConnection
		 * is shared between elements, we can use this one connection. However, this
		 * event gets broadcast when we reconnect, so this method only creates the
		 * ReconnectionManager once
		 * 
		 * @param	event	(NetConnectionFactoryEvent) NetConnectionFactoryEvent.CREATED
		 * @return	void
		 */
		protected function _onCreateNetConnectionSuccess( event:NetConnectionFactoryEvent ):void
		{
			// Get a reference to the netConnection object that was created by the factory.
			_netConnection = event.netConnection;
			if( !_reconnectManager )
			{
				_reconnectManager = new ReconnectionManager( _netConnection );
				_reconnectManager.addEventListener( ReconnectionManager.DISCONNECTED, _onDisconnected );
				_reconnectManager.addEventListener( ReconnectionManager.RECONNECT_ABANDONED, _onReconnectAbandoned );
				_reconnectManager.addEventListener( ReconnectionManager.RECONNECT_SUCCESS, _onReconnectSuccess );
			}
		}
		
		/**
		 * Handles a fault in the creation of a NetConnection
		 * 
		 * @param	event	(NetConnectionFactoryEvent) connection creation fault event
		 * @return	void
		 */
		protected function _onCreateNetConnectionFault( event:NetConnectionFactoryEvent ):void
		{
			// TODO: Handle create NC failure
			trace( "There was an error. The NetConnection was not created." );
		}
		
		/**
		 * When the player gets disconnected, quickly grab the current time, because
		 * the next time the NetStream time gets checked, this will become NaN.
		 * 
		 * @param	event	(Event) ReconnectionManager.DISCONNECTED event
		 * @return	void
		 */
		protected function _onDisconnected( event:Event ):void
		{	
			if( !isNaN( _skin.lastCurrentTime ) )
			{
				_reconnectManager.timeAtDisconnect = _skin.lastCurrentTime;
			}
		}
		
		/**
		 * When the reconnect sequence has completely failed ...
		 * 
		 * @param	event	(Event) ReconnectionManager.RECONNECT_ABANDONED event
		 * @return	void
		 */
		protected function _onReconnectAbandoned( event:Event ):void
		{
			//TODO: implement error handling here once the alerting system is brought over
		}
		
		/**
		 * When the player gets reconnected, reset the media element to start
		 * it playing again, and listen for when it is seekable, so we can
		 * seek to the last point the user was at.
		 * 
		 * @param	event	(Event) ReconnectionManager.RECONNECT_SUCCESS event
		 * @return	void
		 */
		protected function _onReconnectSuccess( event:Event ):void
		{
			_mediaPlayerShell.removeMediaElement( _mediaElement );
			
			//Listen for when the duration changes, because otherwise, if we seek before duration
			//gets set, the seek gets ignored
			_mediaPlayerCore.addEventListener( TimeEvent.DURATION_CHANGE, _onDurationChange );
			
			//In order to resume playing, we need to set autoPlay to true. Only do this
			//if we were alaredy playing.
			if( !_playerConfig.autoPlay && !isNaN( _reconnectManager.timeAtDisconnect ) && _reconnectManager.timeAtDisconnect != 0 )
			{
				_mediaPlayerCore.autoPlay = true;
			}
			
			_mediaPlayerShell.addMediaElement( _mediaElement );
		}
		
		/**
		 * When the duration get set after a reconnect, then we should be able to
		 * seek. If for some reason we are not, we'll listen for the canSeek property
		 * to change and then seek at that time.
		 * 
		 * @param	event	(TimeEvent) TimeEvent.DURATION_CHANGE
		 * @return	void
		 */ 
		protected function _onDurationChange( event:TimeEvent ):void
		{
			
			if( _mediaPlayerCore.duration > 0 )
			{
				_mediaPlayerCore.removeEventListener( TimeEvent.DURATION_CHANGE, _onDurationChange );
				if( _mediaPlayerCore.canSeek )
				{
					_mediaPlayerCore.seek( _reconnectManager.timeAtDisconnect );
				}
				else
				{
					_mediaPlayerCore.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, _onPlayerSeekable );
				}
			}
		}
		
		/**
		 * After a reconnection, once the player is seekable, seek to the last
		 * point the viewer was at.
		 * 
		 * @param	event	(Event) MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE event
		 * @return	void
		 */
		protected function _onPlayerSeekable( event:Event ):void
		{
			if( _mediaPlayerCore.canSeek )
			{
				_mediaPlayerCore.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, _onPlayerSeekable );
				_mediaPlayerCore.seek( _reconnectManager.timeAtDisconnect );
				
				if( !_playerConfig.autoPlay )
				{
					_mediaPlayerCore.play();
				}
			}
		}
		
		/**
		 * When a temporal metadata facet has been added, listen for events to show or hide
		 * the caption in the control bar
		 * 
		 * @param	event	(MetadataEvent)
		 * @return	void
		 */
		protected function _onMetaDataAdded( event:MetadataEvent ):void
		{
			if( event.value && event.value is TimelineMetadata )
			{
				_timelineMetaData = event.value as TimelineMetadata;
				_timelineMetaData.addEventListener( TimelineMetadataEvent.MARKER_TIME_REACHED, _onShowCaption );
				_timelineMetaData.addEventListener( TimelineMetadataEvent.MARKER_DURATION_REACHED, _onHideCaption );
			}
			
			/*
			captionMetadata = mediaElement.getMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
			if (captionMetadata == null)
			{
				captionMetadata = new TimelineMetadata(mediaElement);
				mediaElement.addMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE, captionMetadata);
			}
			captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onShowCaption);
			captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_ADD, onHideCaption);
			*/
		}
		
		/**
		 * When a temporal metadata facet has been removed, clean up any listeners and delete the facet
		 * 
		 * @param	event	(MetadataEvent)
		 * @return	void
		 */
		protected function _onMetaDataRemoved( event:MetadataEvent ):void
		{
			if( event.value && event.value is TimelineMetadata )
			{
				_timelineMetaData = event.value as TimelineMetadata;
				_timelineMetaData.removeEventListener( TimelineMetadataEvent.MARKER_TIME_REACHED, _onShowCaption );
				_timelineMetaData = null;
			}
		}
		
		/**
		 * When the player reaches the time for a caption metadata facet, show the caption in 
		 * the control bar
		 * 
		 * @param	event	(TemporalFacetEvent)
		 * @return	void
		 */
		protected function _onShowCaption( event:TimelineMetadataEvent ):void
		{
			if( event.value is Caption )
			{
				var caption:Caption = event.value as Caption;
			}
			//var ns:String = ( event.currentTarget as TimelineMetadata ).namespaceURL;
			//if( caption != null && ns == CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE )
			if( caption != null )
			{
				_skin.setClosedCaptionText( caption.text );
			}
			
		}
		
		/**
		 * Hide the caption when the caption item reaches its duration
		 * 
		 * @param	event	(TemporalFacetEvent)
		 * @return	void
		 */
		protected function _onHideCaption( event:TimelineMetadataEvent ):void
		{
			_skin.setClosedCaptionText( "" );
		}
		
		/**
		 * Toggle on closed captions
		 * 
		 * @param	event	(ControlBarEvent)
		 * @return	void
		 */
		protected function _onDisplayClosedCaption( event:ControlBarEvent ):void
		{
			if( _timelineMetaData )
			{
				_timelineMetaData.enabled = true;
			}
		}
		
		/**
		 * Toggle off closed captions
		 * 
		 * @param	event	(ControlBarEvent)
		 * @return	void
		 */
		protected function _onRemoveClosedCaption( event:ControlBarEvent ):void
		{
			if( _timelineMetaData )
			{
				_timelineMetaData.enabled = false; // Disable the temporal facet and its timers for performance
			}
		}
		
		/**
		 * Function stub meant to be overwritten to handle unauthorized domains
		 * 
		 * @param	event	(Event) UNAUTHORIZED_DOMAIN event
		 * @return	void
		 */
		protected function _onUnauthorizedDomain( event:Event ):void
		{
			removeEventListener( UNAUTHORIZED_DOMAIN, _onUnauthorizedDomain );
		}
	}
}