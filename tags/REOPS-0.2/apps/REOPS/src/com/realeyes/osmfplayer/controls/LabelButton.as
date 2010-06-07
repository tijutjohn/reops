package com.realeyes.osmfplayer.controls
{
	import flash.text.TextField;

	/**
	 * Toggle button with a text label. Currently it doesn't resize automatically,
	 * so you would have to change the width in the skin.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class LabelButton extends ToggleButton
	{
		public var label_txt:TextField;
		
		public function LabelButton()
		{
			super();
			
			mouseChildren = false;
		}
		
		/**
		 * Label to display on the button	(String)
		 */
		public function get label():String
		{
			return label_txt.text;
		}
		public function set label( value:String ):void
		{
			label_txt.text = value;
		}
	}
}