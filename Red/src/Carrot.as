package  
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Carrot extends Dmut
	{
		[Embed(source = 'sprites/carrot.png')]
		private var CarrotSprite : Class;
		public function Carrot() 
		{
			super(new CarrotSprite().bitmapData,0,false);
		}
		
	}

}