package com.realeyes.osmfplayer.model.config.skin
{
	/**
	 * Interface for skin elements
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public interface ISkinElement
	{
		/**
		 * The class path for the element	(String)
		 */
		function get elementClassString():String;	
		function set elementClassString( value:String ):void	
	}	
}