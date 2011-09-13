package com.realeyes.osmf.plugins.tracking.util
{
	import com.realeyes.osmf.plugins.tracking.element.model.Marker;
	import com.realeyes.osmf.plugins.tracking.events.DurationMarkerEvent;
	
	import flash.events.EventDispatcher;
	
	[Event( name="timeMarker", type="com.realeyes.osmf.plugins.tracking.events.DurationMarkerEvent" )]
	[Event( name="percentMarker", type="com.realeyes.osmf.plugins.tracking.events.DurationMarkerEvent" )]
	[Event( name="completeMarker", type="com.realeyes.osmf.plugins.tracking.events.DurationMarkerEvent" )]
	public class DurationTracker extends EventDispatcher
	{
		//////////////////////////////////////
		// Declarations
		//////////////////////////////////////
		
		private var _currentTime:int = 0;
		private var _previousCurrentTime:int = 0;
		private var _duration:int = 0;
		private var _timeViewed:Number = 0;
		private var _timeCompare:Number = 0;
		private var _completeViewedMarkers:Array;
		private var _timeViewedMarkers:Array;
		private var _percentViewedMarkers:Array;
		
		
		//////////////////////////////////////
		// Init Methods
		//////////////////////////////////////
		
		public function DurationTracker()
		{
		}
		
		
		//////////////////////////////////////
		// Control Methods
		//////////////////////////////////////
		
		public function checkTime( currentTime:Number, duration:Number ):void
		{
			_duration = duration;
			_previousCurrentTime = _currentTime;
			_currentTime = currentTime;
			
			_timeViewed = _currentTime;
			
			checkTimeMarkers();
			checkPercentMarkers();
			checkCompleteMarkers();
		}
		
		public function addTimeMarker( marker:Marker ):void
		{
			if( !_timeViewedMarkers )
			{
				_timeViewedMarkers = new Array();
			}
			
			_timeViewedMarkers.push( marker );
		}
		
		public function addPercentMarker( marker:Marker ):void
		{
			if( !_percentViewedMarkers )
			{
				_percentViewedMarkers = new Array();
			}
			
			_percentViewedMarkers.push( marker );
		}
		
		public function addCompleteMarker( marker:Marker ):void
		{
			if( !_completeViewedMarkers )
			{
				_completeViewedMarkers = new Array();
			}
			
			_completeViewedMarkers.push( marker );
		}
		
		public function resetViewData():void
		{
			_duration = -1;
			_timeViewed = 0;
			
			clearDispatchMarkers( _timeViewedMarkers );
			clearDispatchMarkers( _percentViewedMarkers );
			clearDispatchMarkers( _completeViewedMarkers );	
		}
		
		private function checkTimeMarkers():void
		{
			if( _timeViewedMarkers && _timeViewedMarkers.length > 0 )
			{
				var len:uint = _timeViewedMarkers.length;
				for( var i:uint = 0; i < len; i++ )
				{
					//trace("_timeViewedMarkers[i].marker:" + _timeViewedMarkers[i].marker);
					if( _timeViewed >= _timeViewedMarkers[i].marker && !_timeViewedMarkers[i].dispatched )
					{
						//DISPATCH
						
						this.dispatchEvent( new DurationMarkerEvent( DurationMarkerEvent.TIME_MARKER, _timeViewedMarkers[i], percentViewed, _timeViewed ) ); 
						
						_timeViewedMarkers[i].dispatched = true;
						
						break;
					}
				}
			}
		}
		
		private function checkPercentMarkers():void
		{
			if( _percentViewedMarkers && _percentViewedMarkers.length > 0 )
			{
				//trace("percentViewed: " + percentViewed);
				
				var len:uint = _percentViewedMarkers.length;
				for( var i:uint = 0; i < len; i++ )
				{
					
					if( percentViewed >= _percentViewedMarkers[i].marker && !_percentViewedMarkers[i].dispatched )
					{
						//DISPATCH
						
						this.dispatchEvent( new DurationMarkerEvent( DurationMarkerEvent.PERCENT_MARKER, _percentViewedMarkers[i], percentViewed, _timeViewed ) );
						
						_percentViewedMarkers[i].dispatched = true;
						
						break;
					}
				}
			}
		}
		
		private function checkCompleteMarkers():void
		{
			var nsPercent:Number =  Math.round( ( _currentTime / _duration) * 100 );
			
			//trace( "complete check: " + nsPercent);
			
			if( _completeViewedMarkers && _completeViewedMarkers.length > 0 )
			{
				var len:uint = _completeViewedMarkers.length;
				for( var i:uint = 0; i < len; i++ )
				{
					
					if( nsPercent >= _completeViewedMarkers[i].marker && !_completeViewedMarkers[i].dispatched )
					{
						//DISPATCH
						
						this.dispatchEvent( new DurationMarkerEvent( DurationMarkerEvent.COMPLETE_MARKER, _completeViewedMarkers[i], nsPercent, _currentTime ) );
						
						_completeViewedMarkers[i].dispatched = true;
					}
				}
			}
		}
		
		public function clearDispatchMarkers( p_array:Array ):void
		{
			if( p_array )
			{
				var len:uint = p_array.length;
				for( var i:uint = 0; i < len; i++ )
				{
					p_array[i].dispatched = false;
				}
			}
		}
		
		public function clearCompleteMarkers():void
		{
			_completeViewedMarkers = new Array();
		}
		
		public function clearPercentMarkers():void
		{
			_percentViewedMarkers = new Array();
		}
		
		public function clearTimeMarkers():void
		{
			_timeViewedMarkers = new Array();
		}
		
		/////////////////////////////////////////
		// Getter/Setters
		/////////////////////////////////////////
		
		public function get percentViewed():int
		{
			return Math.round( ( _timeViewed / _duration ) * 100 ); 
		}
		
		public function get duration():Number
		{
			return _duration;
		}

		public function get currentTime():int
		{
			return _currentTime;
		}

	}
}