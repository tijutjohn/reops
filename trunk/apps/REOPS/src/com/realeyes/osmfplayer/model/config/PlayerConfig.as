package com.realeyes.osmfplayer.model.config
{
	import com.realeyes.osmfplayer.model.Plugin;
	import com.realeyes.osmfplayer.model.config.skin.SkinConfig;
	import com.realeyes.osmfplayer.model.playlist.Playlist;
	import com.realeyes.osmfplayer.model.playlist.PlaylistItem;
	import com.realeyes.osmfplayer.util.parser.MediaElementConfigParser;
	
	import flash.utils.getDefinitionByName;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;

	/**
	 * Parses and stores config data for the player, including 
	 * plug-ins
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class PlayerConfig
	{
		// Media Types
		static public var IMAGE:String = "IMAGE";
		static public var SWF:String = "SWF";
		static public var AUDIO:String = "AUDIO";
		static public var VIDEO:String = "VIDEO";
		
		// Stream Types
		static public var PROGRESSIVE:String = "PROGRESSIVE";
		static public var STREAMING:String = "STREAMING";
		static public var DYNAMIC_STREAMING:String = "DYNAMIC_STREAMING";
		
		/**
		 * Config XML content	(XML)
		 */
		public var configXML:XML;
		
		/**
		 * Is the playback live?	(Boolean)
		 */
		public var isLive:Boolean;
		
		/**
		 * Should the media play automatically	(Boolean
		 */
		public var autoPlay:Boolean;
		
		/**
		 * How frequently will the player update?	(int)
		 */
		public var updateInterval:int;
		
		/**
		 * Config information for the skin	(SkinConfig)
		 */
		public var skinConfig:SkinConfig;
		
		/**
		 * The base URL for the applicatoin	(String)
		 */ 
		public var base:String;
		
		/**
		 * Should plug-ins be automatically loaded?	(Boolean)
		 */
		public var loadPlugins:Boolean;
		
		/**
		 * Plug-ins for the player	(Vector.<Plugin>)
		 */
		public var plugins:Vector.<Plugin>;

		/**
		 * Width of the player	(Number)
		 */
		public var width:Number;
		
		/**
		 * Height of the player	(Number)
		 */
		public var height:Number;
		
		/**
		 * How should the player scale?	(String)
		 */
		public var scaleMode:String;
		
		/**
		 * An array of domains that are allowed to play this media. If null or empty, any domain can play.
		 */
		public var allowedDomains:Array;
		
		/**
		 * The URL of the page hosting the SWF
		 */
		public var playerURL:String;
		
		/**
		 * An playlist object with an array of either URLs or media element objects to be played, as
		 * well as some additional settings
		 */
		public var playlist:Playlist;
		
		/**
		 * Are there captions for any of the media. If yes we need to load the CC plugin
		 * <p>If hasCaptions == true. Then the CaptioningPlugin will be loaded. You must then also define 
		 * 	the KeyValueFacet in the <mediaElement> node for the media that has the captions.</p>
		 * EX: 
		 * <code>
		 * <mediaElement>
		 *	<id>akamai10yearf8512K</id>
		 *	<mimeType>video/x-flv</mimeType>
		 *	<streamType>recorded</streamType>
		 *	<deliveryType>streaming</deliveryType>
		 *	<media url="rtmp://cp67126.edgefcs.net/ondemand/mediapm/osmf/content/test/akamai_10_year_f8_512K" width="800" height="600" />
		 *	<keyValueFacet namespace="http://www.osmf.org/captioning/1.0">
		 *		<key><![CDATA[uri]]></key>
		 *		<value type="class" class="org.osmf.utils.URL">
		 *			<url><![CDATA[http://mediapm.edgesuite.net/osmf/content/test/captioning/akamai_sample_caption.xml]]></url>
		 *		</value>
		 *	</keyValueFacet>
		 * </mediaElement>
		 * </code>
		 */
		public var hasCaptions:Boolean;
		
		private var _mediaFactory:MediaFactory;
		private var _mediaElement:MediaElement;
		
		public function PlayerConfig( mediaFactory:MediaFactory=null )
		{
			_mediaFactory = mediaFactory;	
		}
		
		/**
		 * Loads in and stores a new Plugin
		 * 
		 * @param	plugin	(Plugin)
		 * @return	void
		 */
		public function addPlugin( plugin:Plugin ):void
		{
			if( !plugins )
			{
				plugins = new Vector.<Plugin>;
			}
			plugins.push( plugin );
			loadPlugins = true;
		}
		
		/**
		 * Extracts values from the config XML file, setting the values
		 * for use in the player. It also adds any plug-ins from the config
		 * and loads in the skin config XML.
		 * 
		 * @param	configXML	(XML)
		 * @return	void
		 */
		public function parseConfigXML( configXML:XML ):void
		{
			this.configXML = configXML;
			
			width = parseFloat( configXML.@width );
			height = parseFloat( configXML.@height );
			scaleMode = String( configXML.@scaleMode ).toLowerCase();
			updateInterval = configXML.@updateInterval;
			
			autoPlay = String( configXML.@autoPlay ).toLowerCase() == "true" ? true:false;
			isLive = String( configXML.@isLive ).toLowerCase() == "true" ? true:false;
			hasCaptions = String( configXML.@hasCaptions ).toLowerCase() == "true" ? true:false;
			
			// Get the skin config
			skinConfig = new SkinConfig( new XML( configXML.skin ) );
			
			var pluginsXML:XMLList = configXML..plugin;
			
			//Get the allowed domains, if specified
			if( configXML.allowedDomains && configXML.allowedDomains.hasComplexContent() )
			{
				allowedDomains = new Array();
				for each( var domainXML:XML in configXML.allowedDomains..domain )
				{
					allowedDomains.push( domainXML.@url.toString() );
				}
			}
			
			// If we have plugins, create a plugin object for each one
			if( pluginsXML.length() )
			{
				loadPlugins = true;
				var len:int = pluginsXML.length();
				for( var i:int = 0; i < len; i++ )
				{
					var pluginXML:XML = pluginsXML[i];
					var newPlugin:Plugin = new Plugin();
					newPlugin.parsePluginXML( pluginXML );
					addPlugin( newPlugin );
				}
			}
			
			if( configXML.playlist && configXML.playlist.hasComplexContent() )
			{
				var playlistXML:XML = XML( configXML.playlist );
				var newPlaylist:Playlist = new Playlist();
				newPlaylist.autoProgress = String( playlistXML.@autoProgress ).toLowerCase() == "true" ? true:false;
				newPlaylist.loopPlayback = String( playlistXML.@loopPlayback ).toLowerCase() == "true" ? true:false;
				newPlaylist.userNavigable = String( playlistXML.@userNavigable ).toLowerCase() == "true" ? true:false;
				
				var itemClass:Class = PlaylistItem;
				if( playlistXML.@itemClass )
				{
					itemClass = getDefinitionByName( playlistXML.@itemClass ) as Class;
				}
				
				var playlistItems:XMLList = playlistXML..playlistItem;
				for each( var item:XML in playlistItems )
				{
					var vo:PlaylistItem = new itemClass() as PlaylistItem;
					if( item.children()[0].hasComplexContent() )
					{
						vo.mediaElement = item.children()[0];
					}
					else
					{
						vo.mediaElement = item.children()[0].toString();
					}
					
					var attributes:XMLList = item.attributes();
					for each( var attribute:XML in attributes )
					{
						var attrValue:String = attribute.toString();
						vo[ attribute.name().toString() ] = attrValue;
						
					}
					
					newPlaylist.media.push( vo );
				}
				
				playlist = newPlaylist;
			}
		}
		
		/**
		 * Returns and translates a playlist item's media at a given index
		 * 
		 * @param	index	(uint)
		 * @return	MediaElement
		 */
		public function getPlaylistMediaElement( index:uint ):MediaElement
		{
			if( playlist && playlist.length > 0 )
			{	
				var mediaObj:Object = playlist.getItemAt( index ).mediaElement;
				if( mediaObj is String )
				{
					return _mediaFactory.createMediaElement( new URLResource( mediaObj as String ) );
				}
				else
				{
					return _parseMediaElements( mediaObj as XML );
				}
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Returns a playlist item at a given index
		 * 
		 * @param	index	(uint)
		 * @return	PlaylistItem
		 */
		public function getPlaylistItem( index:uint ):PlaylistItem
		{
			if( playlist && playlist.length > 0 )
			{
				return playlist.getItemAt( index );
			}
			else
			{
				return null;
			}
		}
		
		/**
		 *Parses the mediaElement node in the PlayerConfig XML data. 
		 * @return MediaElement The base MediaElement for playback
		 * 
		 */
		private function _parseMediaElements( mediaElement:XML ):MediaElement
		{
			var baseElement:MediaElement;
			
			//TODO: Need to get rootURL and pass in to parse method.
			var mediaElementParser:MediaElementConfigParser = new MediaElementConfigParser( _mediaFactory );
			
			return mediaElementParser.parse( mediaElement, base );
		}
		
		private function getRootUrl(url:String):String
		{
			var path:String = url.substr(0, url.lastIndexOf("/"));
			
			return path;
		}

		public function set mediaElement(value:MediaElement):void
		{
			_mediaElement = value;
		}
		public function get mediaElement():MediaElement
		{
			return _parseMediaElements( configXML.mediaElement[0] );
			
		}

	}
}