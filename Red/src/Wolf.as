package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class Wolf extends Dmut
	{
		[Embed(source = 'sprites/wolf.png')]
		private var WolfSprite : Class;
		public var path : Array = null;
		public var way : Number = 0;
		public var patrol : Boolean = false;
		public var chase : Boolean = false;
		public function Wolf() 
		{
			super(new WolfSprite().bitmapData, 1.2);
		}
		public function walk():void
		{
			var newSpot : Number = Math.abs(way);
			var len : int = (path.length / 2 - 1);
			var i : int = Math.floor(newSpot * len);
			newSpot = newSpot * len - i;
			//trace(i +" / " + path.length);
			//newSpot = (path.length/2 - 1) * newSpot - (i / (path.length/2 - 1));
			posX = path[2 * i] * (1 - newSpot) + newSpot * path[2 * i + 2];
			posY = path[2 * i + 1] * (1 - newSpot) + newSpot * path[2 * i + 3];
		}
	}

}