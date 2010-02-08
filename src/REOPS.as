package
{
	import com.realeyes.osmfplayer.events.ConfigLoadedEvent;
	import com.realeyes.osmfplayer.events.ControlBarEvent;
	import com.realeyes.osmfplayer.managers.ConfigurationManager;
	import com.realeyes.osmfplayer.media.REMediaFactory;
	import com.realeyes.osmfplayer.model.Plugin;
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	import com.realeyes.osmfplayer.util.PluginLoader;
	import com.realeyes.osmfplayer.view.ControlBarContainer;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.external.ExternalInterface;
	import flash.net.NetConnection;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.captioning.CaptioningPluginInfo;
	import org.osmf.captioning.model.Caption;
	import org.osmf.display.MediaPlayerSprite;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.TemporalFacet;
	import org.osmf.metadata.TemporalFacetEvent;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.dynamicstreaming.DynamicStreamingItem;
	import org.osmf.net.dynamicstreaming.DynamicStreamingResource;
	import org.osmf.plugin.PluginInfoResource;
	import org.osmf.utils.FMSURL;
	import org.osmf.utils.URL;
	
	/**
	 * Creates a video player based off of an external XML configuration
	 * file.
	 * 
	 * @author	RealEyes Media
	 * @version	0.1
	 */ 
	[SWF(width="700", height="600")]
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
		
		private var _configManager:ConfigurationManager;
		protected var _pluginLoader:PluginLoader;
		protected var _playerConfig:PlayerConfig;
		protected var _mediaFactory:MediaFactory;
		
		protected var _controlBar:ControlBarContainer;
		
		protected var _mediaPlayerShell:MediaPlayerSprite; 
		private var _mediaPlayerCore:MediaPlayer; 
		private var _temporalFacet:TemporalFacet; 
		
		private var _mediaResource:MediaResourceBase;
		protected var _mediaElement:MediaElement;
		
		private var _netConnectionFactory:NetConnectionFactory;
		private var _netConnection:NetConnection;
		
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

		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function REOPS()
		{
			trace( "REOSMF - Contruct" );
			
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
		private function _init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Initialize the External Interface Manager and add any callbacks
			_initExternalInterface();

			// Create the connection factory
			_initConnectionFactory();
			
			// Create our MediaFactory
			_initMediaFactory();
			
			// Start the process by loading the config 
			_loadConfigFile();
		}
		
		protected function _loadConfigFile():void
		{
			//Load the specified config file, pulling the path from FlashVars, if need be
			_configManager = new ConfigurationManager( CONFIG_DEFAULT_PATH, _mediaFactory, false );
			_configManager.addEventListener( ConfigLoadedEvent.CONFIG_LOADED, _configLoadHandler, false, 0, true );
			
			if( LoaderInfo( this.root.loaderInfo ).parameters.configPath )
			{
				_configManager.load( LoaderInfo( this.root.loaderInfo ).parameters.configPath );
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
		protected function _initControlBar():void
		{
			_controlBar = new ControlBarContainer( _mediaPlayerShell, _playerConfig.isLive );
			
			_controlBar.hasCaptions = _playerConfig.hasCaptions;
			_controlBar.loadExternal(_playerConfig.skinConfig.path, _playerConfig.skinConfig.getSkinElements() );	
			
			_controlBar.addEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onRemoveClosedCaption );
			_controlBar.addEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onDisplayClosedCaption );
			
			this.addChild( _controlBar );
		}
		
		/**
		 * Initializes the media player and adds it to the stage
		 * 
		 * @return	void
		 */
		protected function _initMediaPlayer():void
		{
			_mediaPlayerCore = new MediaPlayer();
			_mediaPlayerCore.autoPlay = _playerConfig.autoPlay;
			_mediaPlayerCore.currentTimeUpdateInterval = _mediaPlayerCore.bytesLoadedUpdateInterval= _playerConfig.updateInterval;
			//_mediaPlayerCore.bufferTime = 25;			
			_mediaPlayerShell = new MediaPlayerSprite( _mediaPlayerCore );
			_mediaPlayerShell.scaleMode = _playerConfig.scaleMode;// ScaleMode.LETTERBOX;
			
			
			if( _playerConfig.width )
			{
				_mediaPlayerShell.width = _playerConfig.width;
			}
			else
			{
				_mediaPlayerShell.width = stage.stageWidth;
			}
			
			if( _playerConfig.height )
			{
				_mediaPlayerShell.height = _playerConfig.height;
			}
			else
			{
				_mediaPlayerShell.height = stage.stageHeight;
			}
			
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
			
			_netConnectionFactory.addEventListener( NetConnectionFactoryEvent.CREATED, _onCreateNetConnectionSuccess );
			_netConnectionFactory.addEventListener( NetConnectionFactoryEvent.CREATION_FAILED, _onCreateNetConnectionFault );
		}
		
		/**
		 * Adds in the default media types. Currently that is only VideoElement
		 * 
		 * @return void
		 */
		protected function _initMediaFactory():void
		{
			_mediaFactory = new REMediaFactory( _netConnectionFactory );	
		}
		
		/**
		 * Assign the MediaElement to the MediaPlayer element
		 * 
		 * @return	void
		 */
		protected function _initMediaElement():void
		{
			if( !_mediaElement.metadata.hasEventListener( MetadataEvent.FACET_ADD ) && !_mediaElement.metadata.hasEventListener( MetadataEvent.FACET_REMOVE ) )
			{
				_mediaElement.metadata.addEventListener( MetadataEvent.FACET_ADD, _onFacetAdded );
				_mediaElement.metadata.addEventListener( MetadataEvent.FACET_REMOVE, _onFacetRemoved );
			}
			
			_mediaPlayerShell.mediaElement = _mediaElement;
		}
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		/**
		 * Loads a new video element.
		 * 
		 * @param	p_url	(String) the URL for the video element to play
		 * @return	void
		 */
		public function changeMediaElement( p_url:String, mediaType:String="VIDEO", streamType:String=null ):void
		{
			setMediaResource( p_url, mediaType, streamType );
			_initMediaElement();
		}
		
		
		/**
		 * Creates the MediaResource based on the stream type specified for the player
		 * 
		 * @param	p_path		(String) URL to the media resource
		 * @param	mediaType	(String) the type of media. Defaults to "VIDEO".
		 * @param	streamType	(String) the type of streaming (PlayerConfig.PROGRESSIVE, PlayerConfig.STREAMING, PlayerConfig.DYNAMIC_Streaming, or none). Defaults to null.
		 * @return	void
		 */
		public function setMediaResource( p_path:String, mediaType:String="VIDEO", streamType:String=null ):void
		{
			trace("setMediaResource: " + p_path);
			
			switch( streamType.toUpperCase() )
			{
				case PlayerConfig.PROGRESSIVE:
				{
					_mediaResource = new URLResource( new FMSURL( p_path ) );
					break;
				}
				case PlayerConfig.STREAMING:
				{
					_mediaResource = new StreamingURLResource( new FMSURL( p_path ) );
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
					_mediaResource = new URLResource( new URL( p_path ) );
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
			
			var dynamicStreamingResource:DynamicStreamingResource = new DynamicStreamingResource( new URL( p_xml.ns::head.meta.@base ) );
			
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
		protected function _loadCCPlugin():void
		{
			var ccPlugin:Plugin = new Plugin();
			var ccInfoRef:Class = getDefinitionByName( CAPTIONING_PLUGIN_PATH ) as Class;
			var ccPluginResource:MediaResourceBase = new PluginInfoResource( new ccInfoRef() );
			
			ccPlugin.resource = ccPluginResource;
			_pluginLoader.loadPlugin( ccPlugin );
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
			
			trace("-- init sequence --");
			
			_pluginLoader = new PluginLoader( _mediaFactory ); // Create out plugin loader
			
			if( _playerConfig.hasCaptions ) // Create and add the CC plugin
			{
				_loadCCPlugin();
			}
			
			if( _playerConfig.loadPlugins ) // Load our plugins if we have any
			{
				_pluginLoader.loadPlugins( _playerConfig.plugins );
			}
			
			// NOTE: Had to change some of the sequencing here and in the PlayerConfig class
			//	Basically the metadata FACET event listeners weren't firing because the MediaElements from the config
			// 	were being created before they had the chance to get set up. 
			_mediaElement = _playerConfig.mediaElement; // Set up the media to be played 
			
			_initMediaPlayer(); // Set up the player
			
			_initMediaElement(); // Kick it off
			
			_initControlBar(); // Set up control
		}
		
		/**
		 * Once the NetConnection has been created, set it as the NetConnection for the player
		 * 
		 * @param	event	(NetConnectionFactoryEvent) connection success event
		 * @return	void
		 */
		protected function _onCreateNetConnectionSuccess( event:NetConnectionFactoryEvent ):void
		{
			// Get a reference to the netConnection object that was created by the factory.
			_netConnection = event.netConnection;
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
		 * When a temporal metadata facet has been added, listen for events to show or hide
		 * the caption in the control bar
		 * 
		 * @param	event	(MetadataEvent)
		 * @return	void
		 */
		protected function _onFacetAdded( event:MetadataEvent ):void
		{
			trace( "Facet Added!" + describeType( event.facet ) );
			if( event.facet && event.facet is TemporalFacet )
			{
				_temporalFacet = event.facet as TemporalFacet;
				_temporalFacet.addEventListener( TemporalFacetEvent.POSITION_REACHED, _onShowCaption );
				_temporalFacet.addEventListener( TemporalFacetEvent.DURATION_REACHED, _onHideCaption );
			}
		}
		
		/**
		 * When a temporal metadata facet has been removed, clean up any listeners and delete the facet
		 * 
		 * @param	event	(MetadataEvent)
		 * @return	void
		 */
		protected function _onFacetRemoved( event:MetadataEvent ):void
		{
			trace( "Facet Removed!" );
			if( event.facet && event.facet is TemporalFacet )
			{
				_temporalFacet = event.facet as TemporalFacet;
				_temporalFacet.removeEventListener( TemporalFacetEvent.POSITION_REACHED, _onShowCaption );
				_temporalFacet = null;
			}
		}
		
		/**
		 * When the player reaches the time for a caption metadata facet, show the caption in 
		 * the control bar
		 * 
		 * @param	event	(TemporalFacetEvent)
		 * @return	void
		 */
		protected function _onShowCaption( event:TemporalFacetEvent ):void
		{
			var caption:Caption = event.value as Caption;
			var ns:URL = ( event.currentTarget as TemporalFacet ).namespaceURL;
			if( caption != null && ns == CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE )
			{
				_controlBar.setClosedCaptionText( caption.text );
			}
			
		}
		
		/**
		 * Hide the caption when the caption item reaches its duration
		 * 
		 * @param	event	(TemporalFacetEvent)
		 * @return	void
		 */
		protected function _onHideCaption( event:TemporalFacetEvent ):void
		{
			_controlBar.setClosedCaptionText( "" );
		}
		
		/**
		 * Toggle on closed captions
		 * 
		 * @param	event	(ControlBarEvent)
		 * @return	void
		 */
		protected function _onDisplayClosedCaption( event:ControlBarEvent ):void
		{
			if( _temporalFacet )
			{
				_temporalFacet.enable = true;
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
			if( _temporalFacet )
			{
				_temporalFacet.enable = false; // Disable the temporal facet and its timers for performance
			}
		}
	}
}