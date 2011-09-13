package com.realeyes.osmfplayer.media
{
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.SoundLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.NetLoader;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	
	public class REMediaFactory extends MediaFactory
	{
		protected var _f4mLoader:F4MLoader;
		protected var _netConnectionFactory:NetConnectionFactory;
		
		public function REMediaFactory( netConnectionFactory:NetConnectionFactory=null )
		{
			super();
			
			_netConnectionFactory = netConnectionFactory;
			
			_init();
		}
		
		protected function _init():void
		{
			_f4mLoader = new F4MLoader(this);
			
			// The order of these matter becuase of the way that the metadata is resolved for the media's type
			addItem( new MediaFactoryItem( "org.osmf.f4m", _f4mLoader.canHandleResource, _createF4MLoaderElement ) );
			addItem( new MediaFactoryItem( "org.osmf.video.dynamicStreaming", new RTMPDynamicStreamingNetLoader( _netConnectionFactory ).canHandleResource, _createVideoElement ) );
			addItem( new MediaFactoryItem( "org.osmf.video.httpstreaming", new HTTPStreamingNetLoader().canHandleResource, _createVideoElement ) );
			addItem( new MediaFactoryItem( "org.omsf.video", new NetLoader().canHandleResource, _createVideoElement ) );		
			addItem( new MediaFactoryItem( "org.osmf.swf", new SWFLoader().canHandleResource, _createSWFElement )	);
			addItem( new MediaFactoryItem( "org.osmf.image", new ImageLoader().canHandleResource, _createImageElement ) );
			addItem( new MediaFactoryItem( "org.osmf.audio.streaming", new NetLoader( _netConnectionFactory ).canHandleResource, _createAudioElement ) );
			addItem( new MediaFactoryItem( "org.osmf.audio", new SoundLoader().canHandleResource, _createAudioElement ) );
		}
		
		protected function _createF4MLoaderElement():F4MElement
		{
			return new F4MElement( null, _f4mLoader );
		}
		
		protected function _createVideoElement():VideoElement
		{
			trace( "Create Video Element!" );
			return new VideoElement();
		}
		
		protected function _createAudioElement():AudioElement
		{
			trace( "Create Audio Element!" );
			return new AudioElement();
		}
		
		protected function _createImageElement():ImageElement
		{
			return new ImageElement();
		}
		
		protected function _createSWFElement():SWFElement
		{
			return new SWFElement();
		}
	}
}