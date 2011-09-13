package com.realeyes.osmfplayer.model.config.skin
{
	/**
	 * Class representing a skin element for the control bar
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ControlBarSkinElement extends SkinElement
	{
		/**
		 * How the component should scale(FIT, SELECT, or NONE)	(String)
		 */
		public var scaleMode:String;
		
		/**
		 * Can the the control bar be dragged?	(Boolean)
		 */
		public var draggable:Boolean;
		
		/**
		 * Should the control bar hide when the user is not interacting?	(Boolean)
		 */
		public var autoHide:Boolean;
		
		public function ControlBarSkinElement()
		{
			super();
		}
		
	}
}