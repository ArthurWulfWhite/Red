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
		
		private const OFFSET_X:Number = 15;
		private const OFFSET_Y:Number = 38;
		
		public const size : int = 6;
		
		public function Red() 
		{
			super(new RedSprite().bitmapData);
		}
		
		override public function set x ( v:Number ):void { super.x = v - OFFSET_X }
		override public function get x ():Number { return super.x + OFFSET_X }
		override public function set y ( v:Number ):void { super.y = v - OFFSET_Y }
		override public function get y ():Number { return super.y + OFFSET_Y }
		
	}

}