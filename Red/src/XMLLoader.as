package  
{
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	import flash.utils.ByteArray;
	
	public class XMLLoader 
	{
		[Embed(source='shalav.xml', mimeType = "application/octet-stream")]
		public static const GameData :Class;
		public static var xml : XML;

		public static function init():void 
		{
			var file	:	ByteArray	= new GameData();
			var str		:	String		= file.readUTFBytes(file.length);
			xml = new XML(str);
			//trace("xml loaded successfully");
		}
		
	}

}