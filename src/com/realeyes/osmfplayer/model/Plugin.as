package com.realeyes.osmfplayer.model 
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.utils.URL;

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
			resource = new URLResource( new URL( path ) );
			
			// TODO: Parse the meta and add to the resource
		}
	}
}