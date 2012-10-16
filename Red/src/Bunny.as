package  
{
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Bunny extends Dmut
	{
		[Embed(source = 'sprites/bunny.png')]
		private var BunnySprite : Class;
		public function Bunny() 
		{
			super(new BunnySprite().bitmapData, 0.5);
		}
		
	}

}