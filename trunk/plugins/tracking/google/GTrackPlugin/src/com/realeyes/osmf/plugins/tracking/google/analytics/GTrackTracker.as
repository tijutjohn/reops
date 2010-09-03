package com.realeyes.osmf.plugins.tracking.google.analytics
{
	import com.google.analytics.core.Buffer;
	import com.google.analytics.core.GIFRequest;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.external.AdSenseGlobals;
	import com.google.analytics.utils.Environment;
	import com.google.analytics.v4.Configuration;
	import com.google.analytics.v4.Tracker;
	
	public class GTrackTracker extends Tracker
	{
		private var _trackingCount:int = 0;
		
		public function GTrackTracker( account:String, config:Configuration, debug:DebugConfiguration, info:Environment, buffer:Buffer, gifRequest:GIFRequest, adSense:AdSenseGlobals )
		{
			super( account, config, debug, info, buffer, gifRequest, adSense );
		}
		
		/**
		 * Overriden to provide a tracking count for the session so if we hit 500+ tracking events we can at least send that info
		 *  
		 * @param category
		 * @param action
		 * @param label
		 * @param value
		 * @return Boolean if the call was sent successfully
		 * 
		 */
		override public function trackEvent(category:String, action:String, label:String=null, value:Number=NaN):Boolean
		{
			_checkTrackingCount();
			return super.trackEvent( category, action, label, value );
		}

		/**
		 * Overriden to provide a tracking count for the session so if we hit 500+ tracking events we can at least send that info
		 * 
		 * @param pageURL String The URL of the page view
		 * 
		 */
		override public function trackPageview( pageURL:String="" ):void
		{
			_checkTrackingCount();
			return super.trackPageview( pageURL );
		}
		
		override public function resetSession():void
		{
			_trackingCount = 0; // reset the count
			super.resetSession();
		}
		
		private function _checkTrackingCount():void
		{
			_trackingCount++;
			
			if( _trackingCount == 499 ) // Check the limit of 500 and send an overflow if we are there. Additional tracking calls will be ignored by Google after this.
			{
				super.trackEvent( "tracking", "trackingOverflow", "Tracking limit of 500 calls per session has been reached.", 1 );
			}
		}
	}
}