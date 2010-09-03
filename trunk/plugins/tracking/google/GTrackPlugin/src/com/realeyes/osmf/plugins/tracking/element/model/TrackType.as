package com.realeyes.osmf.plugins.tracking.element.model
{
	public class TrackType
	{
		// PageView Tracking
		static public const PAGE_VIEW:String = "pageView";

		// Time based tracking
		static public const PERCENT_WATCHED:String = "percentWatched";
		static public const TIME_WATCHED:String = "timeWatched";
		
		// ProxyPlugin based tracking
		static public const AUTO_SWITCH_CHANGE:String = "autoSwitchChange";
		static public const BUFFERING_CHANGE:String = "bufferingChange";
		static public const BUFFER_TIME_CHANGE:String = "bufferTimeChange";
		static public const BYTES_TOTAL_CHANGE:String = "bytesTotalChange";
		static public const CAN_PAUSE_CHANGE:String = "canPauseChange";
		static public const COMPLETE:String = "complete";
		static public const DISPLAY_OBJECT_CHANGE:String = "displayObjectChange";
		static public const DURATION_CHANGE:String = "durationChange";
		static public const LOADSTATE_CHANGE:String = "loadStateChange";
		static public const MEDIA_SIZE_CHANGE:String = "mediaSizeChange";
		static public const MUTED_CHANGE:String = "mutedChange";
		static public const NUM_DYNAMIC_STREAMS_CHANGE:String = "numDynamicStreamsChange";
		static public const PAN_CHANGE:String = "panChange";
		static public const PLAY_STATE_CHANGE:String = "playStateChange";
		static public const SEEKING_CHANGE:String = "seekingChange";
		static public const SWITCHING_CHANGE:String = "switchingChange";
		static public const TRAIT_ADD:String = "traitAdd";
		static public const TRAIT_REMOVE:String = "traitRemove";
		static public const VOLUME_CHANGE:String = "volumeChange";
		static public const RECORDING_CHANGE:String = "recordingChange";
		static public const DRM_STATE_CHANGE:String = "drmStateChange";
	}
}