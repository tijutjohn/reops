/*****************************************************
 *  Copyright 2010 Realeyes Media, LLC.  All Rights Reserved.
 *  
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS" basis, 
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. 
 *  See the License for the specific language governing 
 *  rights and limitations under the License.
 *  
 *  The Initial Developer of the Original Code is Realeyes Media, LLC..
 *  Portions created by Realeyes Media, LLC. are Copyright (C) 2010 Realeyes Media 
 *  All Rights Reserved. 
 *****************************************************/
package com.realeyes.osmfplayer.model.config
{
	import com.realeyes.osmfplayer.model.Plugin;
	import com.realeyes.osmfplayer.model.config.skin.SkinConfig;
	import com.realeyes.osmfplayer.util.parser.MediaElementConfigParser;
	
	import flash.media.Video;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.video.VideoElement;

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
		 * Player playback type	(String)
		 */
		public var playbackType:String;
		
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
			scaleMode = configXML.@scaleMode;
			updateInterval = configXML.@updateInterval;
			
			if( String( configXML.@autoPlay ).toLowerCase() == "true" )
			{
				autoPlay = true;
			}
			else
			{
				autoPlay = false;
			}
			
			// Get the skin config
			skinConfig = new SkinConfig( new XML( configXML.skin ) );
			
			hasCaptions = String( configXML.@hasCaptions ).toLowerCase() == "true" ? true:false;
			
			var pluginsXML:XMLList = configXML..plugin;
			
			// If we have plugins, create a plugin object for each one
			if( pluginsXML.length() )
			{
				loadPlugins = true;
				for each( var pluginXML:XML in pluginsXML )
				{
					var newPlugin:Plugin = new Plugin();
					newPlugin.parsePluginXML( pluginXML );
					addPlugin( newPlugin );
				}
			}			
		}
		
		/**
		 *Parses the mediaElement node in the PlayerConfig XML data. 
		 * @return MediaElement The base MediaElement for playback
		 * 
		 */
		private function _parseMediaElements( playlist:XML ):MediaElement
		{
			var baseElement:MediaElement;
			var playlistParser:MediaElementConfigParser = new MediaElementConfigParser( _mediaFactory );
			
			return playlistParser.parse( playlist );
		}

		public function set mediaElement(value:MediaElement):void
		{
			_mediaElement = value;
		}
		public function get mediaElement():MediaElement
		{
			return _parseMediaElements( configXML.playlist[0] );
		}

	}
}