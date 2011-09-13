package com.realeyes.osmfplayer.model 
{
	import flash.utils.getDefinitionByName;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;

	/**
	 * Stores data representing a player plug-in. Parses plug-in XML.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */ 
	public class Plugin
	{
		static public const SWF:String = "swf";
		static public const CLASS:String = "class";
		
		/**
		 * Config XML for the plug-in	(XML)
		 */
		public var pluginXML:XML;
		
		/**
		 * URL for the plug-in SWF	(String)
		 */
		public var path:String;
		
		/**
		 * Array of metadata facets for this plug-in	(Array)
		 */
		public var meta:Array; // Array of meta facets
		
		/**
		 * The loaded instance of the plug-in, stored as a URLResource	(MediaResourceBase)
		 */
		public var resource:MediaResourceBase;
		
		public function Plugin()
		{
		}
		
		/**
		 * Parse the plug-in XML and store the data
		 * 
		 * @param	pluginConfigXML
		 * @return	void
		 */
		public function parsePluginXML( pluginConfigXML:XML ):void
		{
			pluginXML = pluginConfigXML; 
			path = pluginXML.@path;
			
			// We are only loading SWF plugins 
			resource = new URLResource(  path  );
			
			
			
			// Parse the meta and add to the resource
			for each( var metadataXML:XML in pluginXML..metaData )
			{
				var newMetadata:Metadata = new Metadata();
				var ns:String = metadataXML.@namespace.toString();
				//var newFacet:KeyValueFacet = new KeyValueFacet( ns );
				for each( var valueXML:XML in metadataXML..value )
				{
					var keyString:String = valueXML.@key;
					//var key:ObjectIdentifier = new ObjectIdentifier( keyString );
					var facetValue:Object = new Object();
					
					var valueType:String = String( valueXML.@type ).toLowerCase();
					
					if( valueType == "class" )
					{
						var classRef:String = valueXML.attribute( valueType );
						switch( classRef )
						{
							case "org.osmf.utils.URL":
							{
								var valueClass:Class = getDefinitionByName( classRef ) as Class;
								var url:String = valueXML.url;
								facetValue = new valueClass( url );
								break;
							}
							case "com.realeyes.osmf.plugins.tracking.google.config.GTrackConfig":
							{
								facetValue = new XML( valueXML );
								break;
							}
						}
						
					}
					
					if( facetValue )
					{
						newMetadata.addValue( keyString, facetValue );
					}
				}
				
				resource.addMetadataValue( ns, newMetadata );
				
				//TODO: It appears we're not using the meta property anywhere. If we want it populated,
				//we need to initialize it in the constructor and populate it here.
				//meta.push( newMetadata );
			}
		}
	}
}