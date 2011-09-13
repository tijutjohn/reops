package
{
	import com.realeyes.osmf.plugins.tracking.GTrackPluginInfo;
	
	import flash.display.Sprite;
	
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	
	public class GTrackPlugin extends Sprite
	{
		private var _pluginInfo:PluginInfo;
		
		public function GTrackPlugin()
		{
			trace( "GTrackPlugin()" );
			_pluginInfo = new GTrackPluginInfo();
		}
		
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
	}
}