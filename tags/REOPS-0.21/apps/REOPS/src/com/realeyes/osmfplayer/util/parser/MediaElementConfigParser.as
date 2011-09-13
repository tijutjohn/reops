package com.realeyes.osmfplayer.util.parser
{
	import com.realeyes.osmfplayer.model.manifest.BootstrapInfo;
	import com.realeyes.osmfplayer.model.manifest.DRMAdditionalHeader;
	import com.realeyes.osmfplayer.model.manifest.Manifest;
	import com.realeyes.osmfplayer.model.manifest.Media;
	import com.realeyes.osmfplayer.util.Base64Decoder;
	import com.realeyes.osmfplayer.util.net.NetStreamUtils;
	
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingURLResource;
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
		
		private var _rootURL:String;
		
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
		public function parse( playlist:XML, rootURL:String = null ):MediaElement
		{
			_rootURL = rootURL;
			
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
		public function parseMediaElement( mediaXML:XML, rootUrl:String=null ):MediaElement
		{
			var manifest:Manifest = new Manifest();
			
			var root:XML = new XML(mediaXML);
			
			if (root.id.length() > 0)
			{
				manifest.id = root.id.text();
			}
			
			if (root.duration.length() > 0)
			{			
				manifest.duration = root.duration.text();
			}	
			
			if (root.startTime.length() > 0)
			{		
				//TODO: should we be changing the way we store our start times?
				manifest.startTime = new Date( null, null, null, null, null, parseFloat( mediaXML.startTime.text() ) );
				//manifest.startTime = DateUtil.parseW3CDTF(root.startTime.text());
			}	
			
			if (root.mimeType.length() > 0)
			{			
				manifest.mimeType = root.mimeType.text();
			}	
			
			if (root.streamType.length() > 0)
			{			
				manifest.streamType = root.streamType.text();
			}
			
			if (root.deliveryType.length() > 0)
			{			
				manifest.deliveryType = root.deliveryType.text();
			}
			
			if (root.baseURL.length() > 0)
			{			
				manifest.baseURL = root.baseURL.text();
			}
			
			//TODO: We're putting in the URL for the manifest (config) xml, which probably is wrong.
			//So we'll need to fix this if it becomes an issue at some point.
			var baseUrl:String = (manifest.baseURL != null) ? manifest.baseURL :  _rootURL;
			
			// Media	
			
			var bitrateMissing:Boolean = false;
			
			for each (var media:XML in root.media)
			{
				var newMedia:Media = parseMedia( media, baseUrl );
				manifest.media.push(newMedia);
				bitrateMissing ||= isNaN(newMedia.bitrate);
			}	
			
			if (manifest.media.length > 1 && bitrateMissing)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_BITRATE_MISSING));
			}
			
			// DRM Metadata	
			
			for each (var data:XML in root.drmAdditionalHeader)
			{
				parseDRMAdditionalHeader(data, manifest.media, baseUrl, manifest);
			}	
			
			// Bootstrap	
			
			for each (var info:XML in root.bootstrapInfo)
			{
				parseBootstrapInfo(info, manifest.media, baseUrl, manifest);
			}	
			
			// Required if base URL is omitted from Manifest
			generateRTMPBaseURL(manifest);
			
			// MetaData facets
			for each( var facetXML:XML in mediaXML..metaData )
			{
				var ns:String = facetXML.@namespace.toString();
				
				var newMetadata:Metadata = new Metadata();
				
				for each( var valueXML:XML in facetXML..value )
				{
					var keyString:String = valueXML.@key;
					var facetValue:Object = new Object();
					
					var valueType:String = String( valueXML.@type ).toLowerCase();
					if( valueType == "class" )
					{
						var classRef:String = valueXML.attribute( valueType );
						
						//TODO: See if there is any need for this any more
						if( classRef == "org.osmf.utils.URL" || classRef == 'com.realeyes.osmfplayer.util.net.URL' )
						{
						var valueClass:Class = getDefinitionByName( classRef ) as Class;
						var url:String = facetXML.value.url;
						facetValue = new valueClass( url );
						}
						
					}
					else if( valueType == "string" )
					{
						var str:String = valueXML.id.text();
						facetValue = str;
					}
					else if( valueType == "xml" )
					{
						facetValue = new XML( valueXML.children()[0] ); // Set the first child of the value nodes on as an XML object
					}
					
					if( facetValue ) // only add it if something was created
					{
						newMetadata.addValue( keyString, facetValue );
					}
				}
				
				manifest.metadata[ns] = newMetadata;
			}
			
			//===============================================================
			/*
			var manifest:Manifest = new Manifest();
			
			var root:XML = mediaXML;
			
			if (mediaXML.id.length() > 0)
			{
				manifest.id = mediaXML.id.text();
			}
			
			if (mediaXML.startTime.length() > 0)
			{			
				manifest.startTime = Date( 0, 0, 0, 0, 0, parseFloat( mediaXML.startTime.text() );
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
				manifest.baseURL = mediaXML.baseURL.text();
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
			
			*/
			
			//TODO: We're putting in the URL for the manifest (config) xml, which probably is wrong.
			//So we'll need to fix this if it becomes an issue at some point.
			var resource:MediaResourceBase = createResource( manifest, new URLResource( _rootURL ) );
			
			return _mediaFactory.createMediaElement( resource );
		}
		
		/**
		 * Parses a media node into a Media object
		 * 
		 * @param	value	(XML)
		 * @return	Media
		 */
		private function parseMedia( value:XML, baseURL:String ):Media
		{
			
			///===================================
			var decoder:Base64Decoder;
			var media:Media = new Media();
			
			if (value.attribute('url').length() > 0)
			{
				media.url = value.@url;
			}
			else  //Raise parse error
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
			}
			
			if (value.attribute('bitrate').length() > 0)
			{
				media.bitrate = value.@bitrate;
			}
			
			if (value.attribute('drmAdditionalHeaderId').length() > 0)
			{
				media.drmAdditionalHeader.id = value.@drmAdditionalHeaderId;
			}
			/* CHANGED
			if (value.attribute('drmMetadataId').length() > 0)
			{
				media.drmMetadataId = value.@drmMetadataId;
			}
			*/
			
			if (value.attribute('bootstrapInfoId').length() > 0)
			{
				media.bootstrapInfo = new BootstrapInfo();
				media.bootstrapInfo.id = value.@bootstrapInfoId;
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
				decoder = new Base64Decoder();
				decoder.decode(value.moov.text());
				media.moov = decoder.drain();
			}
			
			if (value.metadata.length() > 0)
			{
				decoder = new Base64Decoder();
				decoder.decode(value.metadata.text());
				
				var data:ByteArray = decoder.drain();
				data.position = 0;
				data.objectEncoding = 0;
				
				try
				{
					var header:String = data.readObject() as String;
					var metaInfo:Object = data.readObject();
					media.metadata = metaInfo;			
				}
				catch (e:Error)
				{
				}			
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
		/*
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
		*/
		/**
		 * Parses XML for application startup and applies it to
		 * all media.
		 * 
		 * @param	value		(XML)
		 * @param	allMedia	(Vector.<Media>)
		 * @return	void
		 */
		private function parseBootstrapInfo(value:XML, allMedia:Vector.<Media>, baseUrl:String, manifest:Manifest):void
		{		
			var media:Media;	
			
			var url:String = null;
			var bootstrapInfo:BootstrapInfo = new BootstrapInfo();
			
			if (value.attribute('profile').length() > 0)
			{
				bootstrapInfo.profile = value.@profile;
			}
			else  // Raise parse error
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_PROFILE_MISSING));
			}
			
			if (value.attribute("id").length() > 0)
			{
				bootstrapInfo.id = value.@id; 
			}
			
			if (value.attribute("url").length() > 0)
			{
				url = value.@url;
				if (!isAbsoluteURL(url) && baseUrl != null)
				{
					url = baseUrl + "/" + url;
				}
				bootstrapInfo.url = url;
			}
			else
			{			
				var metadata:String = value.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				bootstrapInfo.data = decoder.drain();
			}
			
			for each (media in allMedia)
			{
				if (media.bootstrapInfo == null) //No per media bootstrap. Apply it to all items.
				{
					media.bootstrapInfo = bootstrapInfo;
				}
				else if (media.bootstrapInfo.id == bootstrapInfo.id)
				{
					media.bootstrapInfo = bootstrapInfo;
				}						
			}
			/*
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
			*/
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
		
		
		public function isAbsolute( p_url:String ):Boolean
		{
			if( p_url.indexOf(":/") == -1 )
			{
				return false;
			}
			
			return true;
			
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
		//TODO: Figure out how to get a manifestResource or avoid it
		public function createResource( value:Manifest, manifestResource:URLResource = null ):MediaResourceBase
		{			
			var drmMetadata:Metadata = null;
			var httpMetadata:Metadata = null;
			var resource:StreamingURLResource;
			var media:Media;
			var serverBaseURLs:Vector.<String>;
			var url:String;
			var bootstrapInfoURLString:String;
			
			var manifestURL:URL = new URL(manifestResource.url); 
			var cleanedPath:String = "/" + manifestURL.path;
			cleanedPath = cleanedPath.substr(0, cleanedPath.lastIndexOf("/"));
			var manifestFolder:String = manifestURL.protocol + "://" +  manifestURL.host + (manifestURL.port != "" ? ":" + manifestURL.port : "") + cleanedPath;
			
			if(value.media.length == 1)  //Single Stream/Progressive Resource
			{	
				media = value.media[0] as Media;
				url = value.media[0].url;
				
				var baseURLString:String = null;
				if (isAbsoluteURL(url))
				{
					// The server base URL needs to be extracted from the media's
					// URL.  Note that we assume it's the same for all media.
					baseURLString = media.url.substr(0, media.url.lastIndexOf("/"));
				}
				else if (value.baseURL != null)
				{
					baseURLString = value.baseURL;
				}
				else
				{
					baseURLString = manifestFolder;
				}
				
				if (isAbsoluteURL(url))
				{
					resource = new StreamingURLResource(url, value.streamType);
				}				
				else if (value.baseURL != null)	// Relative to Base URL					
				{
					resource = new StreamingURLResource(value.baseURL + "/" + url, value.streamType);
				}
				else // Relative to F4M file  (no absolute or base urls or rtmp urls).
				{
					resource = new StreamingURLResource(manifestFolder + "/" + url, value.streamType);
				}
				
				if (media.bootstrapInfo	!= null)
				{
					serverBaseURLs = new Vector.<String>();
					serverBaseURLs.push(baseURLString);
					
					bootstrapInfoURLString = media.bootstrapInfo.url;
					if (media.bootstrapInfo.url != null &&
						isAbsoluteURL(media.bootstrapInfo.url) == false)
					{
						bootstrapInfoURLString = manifestFolder + "/" + bootstrapInfoURLString;
						media.bootstrapInfo.url = bootstrapInfoURLString;
					}
					httpMetadata = new Metadata();
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY, media.bootstrapInfo);
					if (serverBaseURLs.length > 0)
					{
						httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY, serverBaseURLs);
					}
				}
				
				if (media.metadata != null)
				{
					if (httpMetadata == null)
					{
						httpMetadata = new Metadata();
					}
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY, media.metadata);					
				}
				
				if (media.xmp != null)
				{
					if (httpMetadata == null)
					{
						httpMetadata = new Metadata();
					}
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY, media.xmp);					
				}
				
				if (media.drmAdditionalHeader != null)
				{					
					drmMetadata = new Metadata();
					if (Media(value.media[0]).drmAdditionalHeader != null && Media(value.media[0]).drmAdditionalHeader.data != null)
					{
						drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY, Media(value.media[0]).drmAdditionalHeader.data);
						
						resource.drmContentData = extractDRMMetadata(Media(value.media[0]).drmAdditionalHeader.data);
					}
				}	
				
				if (httpMetadata != null)
				{
					resource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
				}
				if (drmMetadata != null)
				{
					resource.addMetadataValue(MetadataNamespaces.DRM_METADATA, drmMetadata);
				}
			}				
			else if (value.media.length > 1) // Dynamic Streaming //else if(value.baseURL && NetStreamUtils.isRTMPStream(value.baseURL))//Dynamic Streaming
			{	
				
				var baseURL:String = value.baseURL != null ? value.baseURL : manifestFolder;
				serverBaseURLs = new Vector.<String>();
				serverBaseURLs.push(baseURL);
				
				// TODO: MBR streams can be absolute (with no baseURL) or relative (with a baseURL).
				// But we need to map them into the DynamicStreamingResource object model, which
				// assumes the latter.  For now, we only support the latter input, but we should
				// add support for the former (absolute URLs with no base URL).
				var dynResource:DynamicStreamingResource = new DynamicStreamingResource(baseURL, value.streamType);
				
				dynResource.streamItems = new Vector.<DynamicStreamingItem>();
				
				// Only put this on HTTPStreaming, not RTMPStreaming resources.   RTMP resources always get a generated base url.
				if (NetStreamUtils.isRTMPStream(baseURL) == false)
				{
					httpMetadata = new Metadata();
					dynResource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY, serverBaseURLs);
				}
				
				for each (media in value.media)
				{	
					var stream:String;
					
					if (isAbsoluteURL(media.url))
					{
						stream = NetStreamUtils.getStreamNameFromURL(media.url);
					}
					else
					{
						stream = media.url;
					}					
					var item:DynamicStreamingItem = new DynamicStreamingItem(stream, media.bitrate, media.width, media.height);
					dynResource.streamItems.push(item);
					if (media.drmAdditionalHeader != null)
					{						
						if (dynResource.getMetadataValue(MetadataNamespaces.DRM_METADATA) == null)
						{
							drmMetadata = new Metadata();
							dynResource.addMetadataValue(MetadataNamespaces.DRM_METADATA, drmMetadata);
						}						
						if (media.drmAdditionalHeader != null && media.drmAdditionalHeader.data != null)
						{
							drmMetadata.addValue(item.streamName, extractDRMMetadata(media.drmAdditionalHeader.data));	
							drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + item.streamName, media.drmAdditionalHeader.data);
						} 						
					}
					
					if (media.bootstrapInfo	!= null)
					{
						bootstrapInfoURLString = media.bootstrapInfo.url ? media.bootstrapInfo.url : null;
						if (media.bootstrapInfo.url != null &&
							isAbsoluteURL(media.bootstrapInfo.url) == false)
						{
							bootstrapInfoURLString = manifestFolder + "/" + bootstrapInfoURLString;
							media.bootstrapInfo.url = bootstrapInfoURLString; 
						}
						httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + item.streamName, media.bootstrapInfo);
					}
					
					if (media.metadata != null)
					{
						httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + item.streamName, media.metadata);					
					}
					
					if (media.xmp != null)
					{
						httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + item.streamName, media.xmp);					
					}
				}
				resource = dynResource;
			}
			else if (value.baseURL == null)
			{	
				// This is a parse error, we need an rtmp url
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));					
			}		
			
			if (value.mimeType != null)
			{
				resource.mediaType = MediaType.VIDEO;
				resource.mimeType = value.mimeType;			
			}
			
			// Add subclip info from original resource
			var streamingManifestResource:StreamingURLResource = manifestResource as StreamingURLResource;
			if (streamingManifestResource != null)
			{
				resource.clipStartTime = streamingManifestResource.clipStartTime;
				resource.clipEndTime = streamingManifestResource.clipEndTime;
			}
			
			for( var ns:String in value.metadata )
			{
				var meta:Metadata = value.metadata[ns]
				resource.addMetadataValue( ns, meta  ); 
			}
			
			
			return resource;
		}
		
		private function parseDRMAdditionalHeader(value:XML, allMedia:Vector.<Media>, baseUrl:String, manifest:Manifest):void
		{
			var url:String = null;
			var media:Media;
			
			var drmAdditionalHeader:DRMAdditionalHeader = new DRMAdditionalHeader();	
			
			if (value.attribute("id").length() > 0)
			{
				drmAdditionalHeader.id = value.@id; 
			}
			
			if (value.attribute("url").length() > 0)
			{
				url = value.@url;
				if (!isAbsoluteURL(url))
				{
					url = baseUrl + "/" + url;
				}
				drmAdditionalHeader.url = url;
			}
			else
			{			
				var metadata:String = value.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				drmAdditionalHeader.data = decoder.drain();
			}
			
			manifest.drmAdditionalHeaders.push(drmAdditionalHeader);
			
			for each (media in allMedia)
			{
				if (media.drmAdditionalHeader.id == drmAdditionalHeader.id)
				{
					media.drmAdditionalHeader = drmAdditionalHeader;					
				}
			}
		}	
		
		private function isAbsoluteURL(url:String):Boolean
		{
			var theURL:URL = new URL(url);
			return theURL.absolute;
		}
		
		private function extractDRMMetadata(data:ByteArray):ByteArray
		{
			var metadata:ByteArray = null;
			
			data.position = 0;
			data.objectEncoding = 0;
			
			try
			{
				var header:Object = data.readObject();
				var encryption:Object = data.readObject();
				var enc:Object = encryption["Encryption"];
				var params:Object = enc["Params"];
				var keyInfo:Object = params["KeyInfo"];
				var fmrmsMetadata:Object = keyInfo["FMRMS_METADATA"];
				var drmMetadata:String = fmrmsMetadata["Metadata"] as String;
				
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(drmMetadata);
				metadata = decoder.drain();
			}
			catch (e:Error)
			{
				metadata = null;	
			}
			
			return metadata;
		}
	}
}