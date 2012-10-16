package  
{
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Red extends Dmut
	{
		[Embed(source = 'sprites/red_edit.png')]
		private var RedSprite : Class;
		
		public const size : int = 6;
		public function Red() 
		{
			super(new RedSprite().bitmapData);
		}
		
	}

}