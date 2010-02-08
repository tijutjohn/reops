package com.realeyes.osmfplayer.controls
{
	import flash.display.MovieClip;
	
//TODO - should this be dynamic or not?	
	/**
	 * Base class for skin elements used in instantiation and layout of
	 * the components through the config file.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public dynamic class SkinElementBase extends MovieClip
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		/**
		 * How many pixels should the component be shifted horizontally?	(Number)
		 */
		public var hAdjust:Number;
		/**
		 * How many pixels should the component be shifted vertically?	(Number)
		 */
		public var vAdjust:Number;
		
		/**
		 * How should the element scale? (FIT, SELECT, or NONE)	(String)
		 */
		public var scaleMode:String;
		
		/**
		 * How should the element align horizontally? (LEFT, CENTER, RIGHT, or NONE)	(String)
		 */
		public var hAlign:String;
		
		/**
		 * How should the element align vertically? (TOP, CENTER, BOTTOM, or NONE)	(String)
		 */
		public var vAlign:String;
		
		/**
		 * Should the element automatically be positioned in its container?	(Boolean)
		 */
		public var autoPosition:Boolean;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function SkinElementBase()
		{
			super();
		}
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		
	}
}