package com.realeyes.osmfplayer.util
{
	import com.realeyes.osmfplayer.events.PluginsLoadedEvent;
	import com.realeyes.osmfplayer.model.Plugin;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	
	/**
	 * Class for loading in plug-ins.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	[Event( type="com.realeyes.osmfplayer.events.PluginsLoadedEvent", name="pluginsLoaded" )]
	public class PluginLoader extends EventDispatcher
	{
		////////////////////////////////////////
		// Declarations
		////////////////////////////////////////
		
		private var _mediaFactory:MediaFactory;
		
		private var _plugins:Vector.<Plugin>;
		private var _pluginsLoaded:int = 0;
		
		
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
			_plugins = new Vector.<Plugin>();
			_init();
		}
		
		/**
		 * Creates a plug-in manager and listens for events on it
		 * 
		 * @return	void
		 */
		private function _init():void
		{
			_mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD , _onPluginLoaded );
			_mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, _onPluginLoadFault );
		}
		
		
		////////////////////////////////////////
		// Control Methods
		////////////////////////////////////////
		
		/**
		 * Loads the collection of Plugins. 
		 * @param plugins Vector A collection of com.realeyes.osmfplayer.Plugin objects to load
		 * 
		 */
		public function loadPlugins():void
		{
			for each( var plugin:Plugin in _plugins )
			{
				_mediaFactory.loadPlugin( plugin.resource );
			}
			
		}
		
		public function addPlugin( plugin:Plugin ):void
		{
			_plugins.push( plugin );	
		}
		
		private function _checkForPluginsLoaded():void
		{
			if( _pluginsLoaded == _plugins.length )
			{
				dispatchEvent( new PluginsLoadedEvent( PluginsLoadedEvent.PLUGINS_LOADED ) );
			}
		}
		
		////////////////////////////////////////
		// Handlers
		////////////////////////////////////////
		/**
		 * When the plug-in loads successfully ...
		 * 
		 * @param	event	(MediaFactoryEvent) MediaFactoryEvent.PLUGIN_LOADED
		 * @return	void
		 */
		private function _onPluginLoaded( event:MediaFactoryEvent ):void
		{
			_pluginsLoaded++;
			_checkForPluginsLoaded();
		}
		
		/**
		 * When the plug-in fails to load successfully ...
		 * 
		 * @param	event	(PluginLoadEvent) PluginLoadEvent.PLUGIN_LOAD_FAILED
		 * @return	void
		 */
		private function _onPluginLoadFault( event:MediaFactoryEvent ):void
		{
			trace( "Plugin failed to load." );
			// TODO: Figure out how we're going to handle plugin load errors
			//	for now we'll just let things pass
			_pluginsLoaded++;
			_checkForPluginsLoaded();
		}
		
		////////////////////////////////////////
		// Getter/Setters
		////////////////////////////////////////
		
		public function hasPlugins():Boolean
		{
			return _plugins.length ? true:false;
		}
	}
}