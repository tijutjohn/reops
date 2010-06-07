package com.realeyes.osmfplayer.util
{
	import com.realeyes.osmfplayer.model.Plugin;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.osmf.events.PluginManagerEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.plugin.PluginManager;
	import org.osmf.utils.URL;
	
	/**
	 * Class for loading in plug-ins.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class PluginLoader extends EventDispatcher
	{
		////////////////////////////////////////
		// Declarations
		////////////////////////////////////////
		
		private var _mediaFactory:MediaFactory;
		private var _pluginManager:PluginManager;
		private var _plugins:Vector.<Plugin>;
		
		
		////////////////////////////////////////
		// Init
		////////////////////////////////////////
		/**
		 * Constructor
		 * 
		 * @param	mediaFactory	(MediaFactory)
		 * @param	target			(IEventDispatcher) defaults to null
		 * @return	PluginLoader
		 */
		public function PluginLoader( mediaFactory:MediaFactory, target:IEventDispatcher=null )
		{
			super( target );
			
			_mediaFactory = mediaFactory;
			
			_init();
		}
		
		/**
		 * Creates a plug-in manager and listens for events on it
		 * 
		 * @return	void
		 */
		private function _init():void
		{
			_pluginManager = new PluginManager( _mediaFactory );
			_pluginManager.addEventListener( PluginManagerEvent.PLUGIN_LOAD, _onPluginLoaded, false, 0, true );
			_pluginManager.addEventListener( PluginManagerEvent.PLUGIN_LOAD_ERROR, _onPluginLoadFault, false, 0, true );
			_pluginManager.addEventListener( PluginManagerEvent.PLUGIN_UNLOAD, _onPluginUnloaded, false, 0, true );
		}
		
		
		////////////////////////////////////////
		// Control Methods
		////////////////////////////////////////
		
		/**
		 * Loads the collection of Plugins. 
		 * @param plugins Vector A collection of com.realeyes.osmfplayer.Plugin objects to load
		 * 
		 */
		public function loadPlugins( plugins:Vector.<Plugin> ):void
		{
			for each( var plugin:Plugin in plugins )
			{
				_pluginManager.loadPlugin( plugin.resource );
			}
			
		}
		
		public function loadPlugin( plugin:Plugin ):void
		{
			_pluginManager.loadPlugin( plugin.resource );
		}
		
		/**
		 * Unloads the specifed resource.
		 * @param resource MediaResourceBase The resource to unload
		 * 
		 */
		public function unloadPlugin( resource:MediaResourceBase ):void
		{
			_pluginManager.unloadPlugin( resource );
		}
		
		////////////////////////////////////////
		// Handlers
		////////////////////////////////////////
		/**
		 * When the plug-in loads successfully ...
		 * 
		 * @param	event	(PluginLoadEvent) PluginLoadEvent.PLUGIN_LOADED
		 * @return	void
		 */
		private function _onPluginLoaded( event:PluginManagerEvent ):void
		{
			trace( "Plugin loaded successfully." );
		}
		
		/**
		 * When the plug-in fails to load successfully ...
		 * 
		 * @param	event	(PluginLoadEvent) PluginLoadEvent.PLUGIN_LOAD_FAILED
		 * @return	void
		 */
		private function _onPluginLoadFault( event:PluginManagerEvent ):void
		{
			trace( "Plugin failed to load." );
		}
		
		/**
		 * When the plug-in unloads successfully ...
		 * 
		 * @param	event	(PluginLoadEvent) PluginLoadEvent.PLUGIN_UNLOADED
		 * @return	void
		 */
		private function _onPluginUnloaded( event:PluginManagerEvent ):void
		{
			trace( "Plugin was unloaded." );	
		}
	}
}