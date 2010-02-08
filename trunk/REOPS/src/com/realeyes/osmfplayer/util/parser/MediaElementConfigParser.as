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
package com.realeyes.osmfplayer.util.parser
{
	import com.realeyes.osmfplayer.model.manifest.Manifest;
	import com.realeyes.osmfplayer.model.manifest.Media;
	import com.realeyes.osmfplayer.util.parser.net.NetStreamUtils;	
	import flash.net.NetConnection;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.composition.ParallelElement;
	import org.osmf.composition.SerialElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MediaType;
	import org.osmf.metadata.MediaTypeFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.ObjectIdentifier;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.NetLoader;
	import org.osmf.net.dynamicstreaming.DynamicStreamingItem;
	import org.osmf.net.dynamicstreaming.DynamicStreamingResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.Base64Decoder;
	import org.osmf.utils.DateUtil;
	import org.osmf.utils.FMSURL;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;
	
	/**
	 *Parses the <playlist> XML node from the player config. Most of the code that determines the 
	 * MediaElement type is "borrowed" from the OSMF library F4MParser/Manifest/Media - these were marked as
	 * excludes and internal classes, so I broke them out into the re library. 
	 * We'll prob need to relocate them package-wise.
	 *  
	 * @author Realeyes Media
	 * 
	 */
	public class MediaElementConfigParser
	{
		private var _mediaFactory:MediaFactory;
		
		/**
		 * Constructor
		 * @param	mediaFactory	(MediaFactory)
		 */
		public function MediaElementConfigParser( mediaFactory:MediaFactory )
		{
			if( mediaFactory )
			{
				_mediaFactory = mediaFactory
			}
			else
			{
				_mediaFactory = new DefaultMediaFactory();
			}
			
		}
		
		/**
		 * Turns a playlist XML node into a media element.
		 * 
		 * @param	playlist	(XML)
		 * @return	MediaElement
		 */
		public function parse( playlist:XML ):MediaElement
		{
			var children:XMLList = playlist.children();
			var mediaElement:MediaElement;
			
			var len:int = children.length();
			for( var i:int = 0; i < len; i++ )
			{
				var child:XML = children[ i ];
				var nodeName:String = child.name();
				switch( nodeName.toLowerCase() )
				{
					case "mediaelement":
					{
						mediaElement = parseMediaElement( child );
						break;
					}
					case "parallel":
					{
						mediaElement = parseParallelElement( child );
						break;
					}
					case "sequence":
					{
						mediaElement = parseSerialElement( child );
						break;
					}
					default:
					{
						throw new Error( "The playlist configuration value '" + nodeName + "' is invalid." );
					}
				}
			}
			
			return mediaElement;
		}
		
		/**
		 * Parses an XMLList of mediaElement, parallel, or sequence nodes into
		 * a media element.
		 * 
		 * @param	children	(XMLList)
		 * @return	MediaElement
		 */
		private function _parseChildren( children:XMLList ):MediaElement
		{
			var mediaElement:MediaElement;
			
			var len:int = children.length();
			for( var i:int = 0; i < len; i++ )
			{
				var child:XML = children[ i ];
				var nodeName:String = child.name();
				switch( nodeName.toLowerCase() )
				{
					case "mediaelement":
					{
						mediaElement = parseMediaElement( child );
						break;
					}
					case "parallel":
					{
						mediaElement = parseParallelElement( child );
						break;
					}
					case "sequence":
					{
						mediaElement = parseSerialElement( child );
						break;
					}
					default:
					{
						throw new Error( "The playlist configuration value '" + nodeName + "' is invalid." );
					}
				}
			}
			
			return mediaElement;
		}
		
		/**
		 * Parses an XML node defining a parallel element into a
		 * ParallelElement.
		 * 
		 * @param	parallelXML	(XML)
		 * @return	ParallelElement
		 */
		public function parseParallelElement( parallelXML:XML ):ParallelElement
		{
			var parallelElement:ParallelElement = new ParallelElement();
			var len:int = parallelXML.children.length();
			for( var i:int = 0; i < len; i++ )
			{
				var child:XML = parallelXML.children()[0];
				if( child.name == "parallel" || child.name() == "sequence" )
				{
					parallelElement.addChild( _parseChildren( child as XMLList ) );	
				}
				
			}
			return parallelElement;
		}
		
		/**
		 * Parses an XML node defining a serial element into a
		 * SerialElement.
		 * 
		 * @param	serialXML	(XML)
		 * @return	SerialElement
		 */
		public function parseSerialElement( serialXML:XML ):SerialElement
		{
			var serialElement:SerialElement = new SerialElement();
			var len:int = serialXML.children().length();
			for( var i:int = 0; i < len; i++ )
			{
				var child:XML = serialXML.children()[i];
				if( child.name == "parallel" )
				{
					serialElement.addChild( parseParallelElement( child ) );
				}
				else if( child.name() == "sequence" )
				{
					serialElement.addChild( parseSerialElement( child ) );
				}
				else
				{
					serialElement.addChild( parseMediaElement( child ) );
				}
			}
			return serialElement;
		}
		
		/**
		 * Parses a media element node into a MediaElement object
		 * 
		 * @param	mediaXML	(XML)
		 * @return	MediaElement
		 */
		public function parseMediaElement( mediaXML:XML ):MediaElement
		{
			var manifest:Manifest = new Manifest();
			
			var root:XML = mediaXML;
			
			if (mediaXML.id.length() > 0)
			{
				manifest.id = mediaXML.id.text();
			}
			
			if (mediaXML.startTime.length() > 0)
			{			
				manifest.clipStart = parseFloat( mediaXML.startTime.text() );
			}	
			
			if (mediaXML.duration.length() > 0)
			{			
				manifest.duration = mediaXML.duration.text();
			}	
			
			if (mediaXML.startTime.length() > 0)
			{			
				manifest.startTime = DateUtil.parseW3CDTF(mediaXML.startTime.text());
			}	
			
			if (mediaXML.mimeType.length() > 0)
			{			
				manifest.mimeType = mediaXML.mimeType.text();
			}	
			
			if (mediaXML.streamType.length() > 0)
			{			
				manifest.streamType = mediaXML.streamType.text();
			}
			
			if (mediaXML.deliveryType.length() > 0)
			{			
				manifest.deliveryType = mediaXML.deliveryType.text();
			}
			
			if (mediaXML.baseURL.length() > 0)
			{			
				manifest.baseURL = new URL(mediaXML.baseURL.text());
			}
			
			//Media	
			
			var bitrateMissing:Boolean = false;
			
			for each (var media:XML in mediaXML.media)
			{
				var newMedia:Media = parseMedia(media);
				manifest.media.push(newMedia);
				bitrateMissing ||= isNaN(newMedia.bitrate);
			}	
			
			if (manifest.media.length > 1 && bitrateMissing)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_BITRATE_MISSING));
			}
			
			// MetaData facets
			for each( var facetXML:XML in mediaXML..keyValueFacet )
			{
				var ns:String = facetXML.@namespace.toString();
				var newFacet:KeyValueFacet = new KeyValueFacet( new URL( ns ) );
				
				var keyString:String = facetXML.key.text();
				var key:ObjectIdentifier = new ObjectIdentifier( keyString );
				var facetValue:Object;
				
				var valueType:String = String( facetXML.value.@type ).toLowerCase();
				if( valueType == "class" )
				{
					var classRef:String = facetXML.value.attribute( valueType );
					if( classRef == "org.osmf.utils.URL" )
					{
						var valueClass:Class = getDefinitionByName( classRef ) as Class;
						var url:String = facetXML.value.url;
						facetValue = new valueClass( url );	
					}
				}
				
				newFacet.addValue( key, facetValue );
				
				manifest.facets.push( newFacet );
			}
			
			//DRM Metadata	
			
			for each (var data:XML in mediaXML.drmMetadata)
			{
				parseDRMMetadata(data, manifest.media);
			}	
			
			//Bootstrap	
			
			for each (var info:XML in mediaXML.bootstrapInfo)
			{
				parseBootstrapInfo(info, manifest.media);
			}	
			
			//Required if base URL is omitted from Manifest
			generateRTMPBaseURL(manifest);
			
			var resource:MediaResourceBase = createResource( manifest );
			
			return _mediaFactory.createMediaElement( resource );
		}
		
		/**
		 * Parses a media node into a Media object
		 * 
		 * @param	value	(XML)
		 * @return	Media
		 */
		private function parseMedia( value:XML ):Media
		{
			var media:Media = new Media();
			
			if (value.attribute('url').length() > 0)
			{
				media.url = new URL(value.@url);
			}
			else  //Raise parse error
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
			}
			
			if (value.attribute('bitrate').length() > 0)
			{
				media.bitrate = value.@bitrate;
			}
			
			if (value.attribute('drmMetadataId').length() > 0)
			{
				media.drmMetadataId = value.@drmMetadataId;
			}
			
			if (value.attribute('bootstrapInfoId').length() > 0)
			{
				media.bootstrapInfoId = value.@bootstrapInfoId;
			}
			
			if (value.attribute('height').length() > 0)
			{
				media.height = value.@height;
			}
			
			if (value.attribute('width').length() > 0)
			{
				media.width = value.@width;
			}
			
			if (value.moov.length() > 0)
			{		
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(value.moov.text());
				media.moov = decoder.drain();	
			}
			
			return media;
		}
		
		/**
		 * Parses an XML node defining DRM metadata, and applies it to 
		 * all media.
		 * 
		 * @param	value		(XML) 
		 * @param	allMedia	(Vector.<Media>)
		 * @return	void
		 */
		private function parseDRMMetadata(value:XML, allMedia:Vector.<Media>):void
		{
			var id:String = null;
			var url:URL = null;
			var data:ByteArray;
			var media:Media;	
			
			if (value.attribute("id").length() > 0)
			{
				id = value.@id;
			}
			
			if (value.attribute("url").length() > 0)
			{
				url = new URL(value.@url);
			}
			else
			{			
				var metadata:String = value.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				data = decoder.drain();
			}
			
			for each (media in allMedia)
			{
				if (media.drmMetadataId == id)
				{
					if (url != null)
					{
						media.drmMetadataURL = url;
					}
					else
					{
						media.drmMetadata = data;
					}					
				}						
			}	
			
		}		
		
		/**
		 * Parses XML for application startup and applies it to
		 * all media.
		 * 
		 * @param	value		(XML)
		 * @param	allMedia	(Vector.<Media>)
		 * @return	void
		 */
		private function parseBootstrapInfo(value:XML, allMedia:Vector.<Media>):void
		{			
			var id:String = null;								
			var url:URL = null;
			var data:ByteArray;
			var media:Media;	
			var profile:String;
			
			if (value.attribute('profile').length() > 0)
			{
				profile = value.@profile;
			}
			else  //Raise parse error
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_PROFILE_MISSING));
			}
			
			if (value.attribute("id").length() > 0)
			{
				id = value.@id;
			}
			
			if (value.attribute("url").length() > 0)
			{
				url = new URL(value.@url);
			}
			else
			{			
				var metadata:String = value.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				data = decoder.drain();
			}
			
			for each (media in allMedia)
			{
				if (media.bootstrapInfoId == id)
				{
					media.bootstrapProfile = profile; 
					if (url != null)
					{
						media.bootstrapInfoURL = url;
					}
					else
					{
						media.bootstrapInfo = data;
					}					
				}						
			}								
		}		
		
		/**
		 * @private
		 * Ensures that an RTMP based Manifest has the same server for all
		 * streaming items, and extracts the base URL from the streaming items
		 * if not specified. 
		 */ 
		private function generateRTMPBaseURL(manifest:Manifest):void
		{
			if (manifest.baseURL == null)
			{						
				for each(var media:Media in manifest.media)
				{
					if (NetStreamUtils.isRTMPStream(media.url))
					{					 	
						manifest.baseURL = media.url;
						break; 
					}
				}
			}
		}
		
		// TODO: Need to be able to handle Image and SWF Resources
		/**
		 * Takes a manifest and uses it to create a media resource. If the manifest
		 * contains only a single stream or a progressive resource, it will create
		 * a URLResource from the media's URL, and apply metadata to the media, if
		 * applicable.
		 * 
		 * For dynamic resources, it creates a DynamicStreamingResource with a
		 * collection of DynamicStreamingItems. It will also apply metadata to the
		 * media if applicable.
		 * 
		 * @param	value	(Manifest)
		 * @return	MediaResourceBase
		 */
		public function createResource( value:Manifest ):MediaResourceBase
		{			
			var drmFacet:KeyValueFacet;
			var resource:MediaResourceBase;
			
			var url:URL;
			
			if(value.media.length == 1)  //Single Stream/Progressive Resource
			{									
				url = value.media[0].url;
				
				if (url.absolute)
				{
					if (NetStreamUtils.isRTMPStream(url))
					{
						resource = new URLResource(new FMSURL(url.rawUrl));
					}
					else
					{
						resource = new URLResource(url);
					}					
				}				
				else if (value.baseURL != null)	//Relative to Base URL					
				{
					resource = new URLResource(new FMSURL(value.baseURL.rawUrl + url.rawUrl));
				}
				else //Relative to f4m file  (no absolute or base urls or rtmp urls).
				{					
					/*var cleanedPath:String = "/" + manifestLocation.path;
					cleanedPath = cleanedPath.substr(0, cleanedPath.lastIndexOf("/",0)+1);
					var base:String = manifestLocation.protocol + "://" +  manifestLocation.host + (manifestLocation.port != "" ? ":" + manifestLocation.port : "") + cleanedPath;
					resource = new URLResource(new URL(base + url.rawUrl));*/
					throw new Error( "Resource does not exist." );
				}
				
				if( Media( value.media[0] ).drmMetadata != null )
				{
					drmFacet = new KeyValueFacet(MetadataNamespaces.DRM_METADATA);
					drmFacet.addValue(new ObjectIdentifier(MetadataNamespaces.DRM_CONTENT_METADATA_KEY), Media(value.media[0]).drmMetadata);
					resource.metadata.addFacet(drmFacet);
				}					
			}				
			else if(value.baseURL && NetStreamUtils.isRTMPStream(value.baseURL))//Dynamic Streaming
			{	
				
				var baseURL:FMSURL = new FMSURL(value.baseURL.rawUrl);
				
				var dynResource:DynamicStreamingResource = new DynamicStreamingResource(baseURL, value.streamType);
				
				dynResource.streamItems = new Vector.<DynamicStreamingItem>();
				
				for each (var media:Media in value.media)
				{	
					var stream:String;
					
					if (media.url.absolute)
					{
						stream = NetStreamUtils.getStreamNameFromURL(media.url);
					}
					else
					{
						stream = media.url.rawUrl
					}					
					var item:DynamicStreamingItem = new DynamicStreamingItem(stream, media.bitrate, media.width, media.height);
					dynResource.streamItems.push(item);
					if (media.drmMetadata != null)
					{
						if (dynResource.metadata.getFacet(MetadataNamespaces.DRM_METADATA) == null)
						{
							drmFacet = new KeyValueFacet(MetadataNamespaces.DRM_METADATA);
							dynResource.metadata.addFacet(drmFacet);
						}						
						drmFacet.addValue(new ObjectIdentifier(item), media.drmMetadata);	
					}
				}
				resource = dynResource;
			}
			else if (value.baseURL == null)
			{	
				//This is a parse error, we need an rtmp url
				throw new ArgumentError( OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING ) );					
			}	
			
			if (value.mimeType != null)
			{
				resource.metadata.addFacet(new MediaTypeFacet(MediaType.VIDEO, value.mimeType));			
			}
			
			if( value.facets.length )
			{
				for each( var facet:KeyValueFacet in value.facets )
				{
					resource.metadata.addFacet( facet ); 
				}
			}
			
			
			return resource;
		}
	}
}