

# Introduction #
The GTrack plugin has been built as an example of an OSMF proxy plugin. The plugin is able to send page tracking and event tracking for an OSMF MediaElement. The GTrack plugin uses the [gaforflash](http://code.google.com/p/gaforflash/) library to send tracking to google analytics.

## Page Tracking ##
Page tracking is per MediaElement. Basically when the MediaElement is loaded and begins to play the URL of the resource is sent as a pageView to Google Analytics. You can also configure the value that is sent by adding metadata to the URLResource for the MediaElement. An example of this can be found in the Configuration section.

## Event Tracking ##
Events are sent to Google Analytics based on an XML configuration. Each of the MediaElements main traits can be configured to send a tracking event.

# Configuration #
The GTrack plugin determines which tracking should be sent and what values are sent to Google Analytics via XML configuration.

### The `<account>` node ###
This node specifies the Google Account to associate the tracking with. You can specify multiple `<account>` nodes to send tracking to multiple accounts. The value for this node can be found in your Google Analytics account and should look similar to - 'UA-1234567-1'.

Example:
```
	<account><![CDATA[UA-1782464-4]]></account>
	<account><![CDATA[UA-1782464-5]]></account>
```

### The `<url>` node ###
The `<url>` node is the URL that was set as the profile URL to be tracked by Google Analytics.

Example:
```
	<url><![CDATA[http://osmf.realeyes.com]]></url>
```

### The `<event>` node ###
The `<event>` node is what defines the tracking that will be sent to your Google Analytics account. The 'name' attribute of the node is the key that tells the GTrack plugin to send an event. So, the names much match exactly. There are multiple types of events that can be tracked:

#### Percent watched ####

Example:
```
	<event name="percentWatched" category="video" action="percentWatched">
		<marker percent="0" label="start" />
		<marker percent="25" label="25PercentView" />
		<marker percent="50" label="50PercentView" />
		<marker percent="75" label="75PercentView" />
	</event>
```
This configuration example will track the start, 25, 50 & 75 percent markers as the media item is played. The complete is tracked by the complete event see MediaElement Events below.

#### Time watched ####

Example:
```
	<event name="timeWatched" category="video" action="timeWatched">
		<marker time="5" label="5sec" />
		<marker time="10" label="10sec" />
		<marker time="20" label="20sec" />
	</event>
```
This example will send tracking at 5, 10, & 20 seconds respectively

#### MediaElement Events ####
MediaElement events are based off of the MediaElement's available Traits. If the MediaElement supports a specific trait and there is an event that can be associated with the trait tracking can be defined for it.
Example:
```
	<event name="complete" category="video" action="complete" label="trackingTesting" value="1" />
```
This example will send tracking when the MediaElement has completed playing.

### The `<updateInterval>` node ###
The `<updateInterval>` node defines the interval that the GTrack plugin checks the current time and position of the currently playing MediaElement to determine when to send the time and/or percentage based tracking.

### The `<debug>` node ###
The `<debug>` node is not currently used but is planned to be implemented as a custom logging & debugging feature.

## Node Attributes ##
The node attributes (except for the name attribute) correspond to the tracking values defined in the [Google Analytics Tracking API for Event Tracking](http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEventTracking.html)
  * category: String - The general event category (e.g. "Videos").
  * action: String - The action for the event (e.g. "Play").
  * label: String - An optional descriptor for the event.
  * value: Int - An optional value associated with the event. You can see your event values in the Overview, Categories, and Actions reports, where they are listed by event or aggregated across events, depending upon your report view.

Sample XML configuration:
```
<value key="reTrackConfig" type="class" class="com.realeyes.osmf.plugins.tracking.google.config.RETrackConfig">
	<!-- Set your analytics account ID -->
	<account><![CDATA[UA-1782464-4]]></account>

	<!-- You can track to multiple analytics accounts by adding additional <account /> nodes -->
	<!-- <account><![CDATA[{ADDITIONAL_GA_ID}]]></account> -->
	
	<!-- Set the url that you registered with your GA account -->
	<url><![CDATA[http://osmf.realeyes.com]]></url>
	
	<!-- Set up the percent based tracking -->
	<event name="percentWatched" category="video" action="percentWatched">
		<marker percent="0" label="start" />
		<marker percent="25" label="view" />
		<marker percent="50" label="view" />
		<marker percent="75" label="view" />
	</event>
	
	<!-- Set up the event tracking for the completed event -->
	<event name="complete" category="video" action="complete" label="trackingTesting" value="1" />

	<!-- Set up the event tracking for the completed event -->
	<event name="pageView" />
	
	<!-- These are the other available events that can be tracked -->
	<!--
	<event name="autoSwitchChange" category="video" action="autoSwitchChange" />
	<event name="bufferingChange" category="video" action="bufferingChange" />
	<event name="bufferTimeChange" category="video" action="bufferTimeChange" />
	<event name="bytesTotalChange" category="video" action="bytesTotalChange" />
	<event name="canPauseChange" category="video" action="canPauseChange"  />
	<event name="displayObjectChange" category="video" action="displayObjectChange"  />
	<event name="durationChange" category="video" action="durationChange"  />
	<event name="loadStateChange" category="video" action="loadStateChange"  />
	<event name="mediaSizeChange" category="video" action="mediaSizeChange"  />
	<event name="mutedChange" category="video" action="mutedChange"  />
	<event name="numDynamicStreamsChange" category="video" action="numDynamicStreamsChange"  />
	<event name="panChange" category="video" action="panChange"  />
	<event name="playStateChange" category="video" action="playStateChange"  />
	<event name="seekingChange" category="video" action="seekingChange"  />
	<event name="switchingChange" category="video" action="switchingChange"  />
	<event name="traitAdd" category="video" action="traitAdd" />
	<event name="traitRemove" category="video" action="traitRemove"  />
	<event name="volumeChange" category="video" action="volumeChange" />
	<event name="recordingChange" category="dvr" action="recordingChange" />
	-->
	<!-- Time based tracking (in seconds)-->
	<!--				
	<event name="timeWatched" category="video" action="timeWatched">
		<marker time="5" label="start" />
		<marker time="10" label="start" />
		<marker time="20" label="start" />
	</event>
	-->
	<debug><![CDATA[true]]></debug>
	<!-- How often you want the timer to check the current position of the media (milliseconds) -->
	<updateInterval><![CDATA[250]]></updateInterval>
</value>
```

### Page Tracking Setup ###
  1. Add the `<event>` node to the XML configuration
```
	<event name="complete" category="video" action="complete" label="trackingTesting" value="1" /> 
```
  1. Add a MetadataValue to the URLResource object for the MediaElement
```
	var resource:URLResource = new URLResource( PROGRESSIVE_PATH );
	resource.addMetadataValue( GTRACK_NAMESPACE, {pageURL:"AnalyticsTestVideo"} );
```
  1. Create the MediaElement
```
	var element:MediaElement = mediaFactory.createMediaElement( resource ); 
```
This will track the String 'AnalyticsTestVideo' instead of the URL of the media resource.

# Usage Example #
  1. Set up the player
```
	protected function initPlayer():void
	{
		mediaFactory = new DefaultMediaFactory();
		player = new MediaPlayer();
		container = new MediaContainer();			
		this.addChild( container );
		loadPlugin( {PATH_TO_GTRACK_PLUGIN_SWF} );
	}
```
  1. Set up a loadPlugin() method.
  1. Create a URLResource that points to the GTrackPlugin.swf
```
	var pluginResource:MediaResourceBase = new URLResource( {PATH_TO_GTRACK_PLUGIN_SWF} ); 
```
  1. Add the XML configuration to the pluginResource as a MetaData value - 'gTrackPluginConfigXML' is an XML variable
```
	pluginResource.addMetadataValue( "http://www.realeyes.com/osmf/plugins/tracking/google", gTrackPluginConfigXML );
```
  1. Listen for the plugin load events
```
	mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded );
	mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed );
```
  1. Load the plugin
```
	mediaFactory.loadPlugin( pluginResource );
```
  1. The loadPlugin() method should look something like:
```
	private function loadPlugin( source:String ):void
	{
		// Create the plugin resource
		var pluginResource:MediaResourceBase = new URLResource( source );
		
		// Add the configuration data as Metadata to the pluginResource
		pluginResource.addMetadataValue( GTRACK_NAMESPACE, gTrackPluginConfigXML );
		
		// Set up the plugin listeners
		mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded );
		mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed );
		
		// Load the plugin
		mediaFactory.loadPlugin( pluginResource );
	}
```
  1. Once the plugin is loaded, remove the plugin listeners and load the media
```
	protected function onPluginLoaded( event:MediaFactoryEvent ):void
	{
		// Remove the plugin listeners
		mediaFactory.removeEventListener( MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded );
		mediaFactory.removeEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed );
		
		// Create the media resource
		var resource:URLResource = new URLResource( PROGRESSIVE_PATH );
		
		// Set up the page tracking
		resource.addMetadataValue( GTRACK_NAMESPACE, { pageURL:"AnalyticsTestVideo" } );
		
		// Create & set the MediaElement
		var element:MediaElement = mediaFactory.createMediaElement( resource );
		player.media = element;
		container.addMediaElement( element );
	}
```

# Source #
http://code.google.com/p/reops/source/browse/#svn/trunk/plugins/tracking/google/GTrackPlugin

# Licence #
  * The gaforflash API  is released under a [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
  * The REOPS project & the GTrack OSMF Plugin is released under the [Mozilla Public License 1.1](http://www.mozilla.org/MPL/)