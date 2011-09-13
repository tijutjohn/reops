 package com.realeyes.osmf.plugins.tracking
{
	import com.realeyes.osmf.plugins.tracking.element.GTrackingProxyElement;
	import com.realeyes.osmf.plugins.tracking.element.config.GTrackConfiguration;
	
	import flash.utils.describeType;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	
	public class GTrackPluginInfo extends PluginInfo
	{
		static public const GTRACK_NS:String = "http://www.realeyes.com/osmf/plugins/tracking/google";
		
		private var _trackingElement:GTrackingProxyElement;
		private var _trackingConfig:GTrackConfiguration;
		
		public function GTrackPluginInfo()
		{
			trace( "GTrackPuginInfo()" );
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			// Let the MediaFactory know what kinda of media the plugin can handle - for now we'll go with the built in NetLoader.canHandleResource
			// 	- we may want to limit to things with time traits or something later
			var loader:NetLoader = new NetLoader();
			var item:MediaFactoryItem = new MediaFactoryItem( 
					"com.realeyes.osmf.plugins.GTrackPluginInfo", 
					loader.canHandleResource, 
					_createMediaElement,
					MediaFactoryItemType.PROXY
			);
			
			items.push( item );
			
			super( items );
		}
		
		protected function mediaElementCreated( mediaElement:MediaElement ):void
		{
			trace( "Media element created!" );
			_trackingElement = new GTrackingProxyElement( null, _trackingConfig );
			//_trackingElement.container = mediaElement;
		}
		
		public function _createMediaElement():GTrackingProxyElement
		{
			// Create the tracking element
			_trackingElement = new GTrackingProxyElement( null, _trackingConfig );
			return _trackingElement;
		}
		
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			// This is where we get the metadata associated with the resource, so we can pass in data here.
			var configXML:XML;
			var metadata:Object = resource.getMetadataValue( GTRACK_NS );
			
			if( metadata is String )
			{
				metadata = new XML( metadata )
			}
			
			if( metadata is XML )
			{
				configXML = metadata as XML;
				_trackingConfig = new GTrackConfiguration( configXML );
			}
			else
			{
				throw new Error( "GTrackPlugin expects XML configuration content" );
			}
		}
	}
}