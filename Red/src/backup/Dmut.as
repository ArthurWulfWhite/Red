package  
{
	import flash.display.Shape;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Dmut extends Shape
	{
		public var speedMultiplier : Number = 1.0; //Multiply by BASE_SPEED
		public function Dmut(color : uint = 0x888888, speedMulti : Number = 1.0) 
		{
			this.speedMultiplier = speedMulti;
			graphics.beginFill(color);
			graphics.lineStyle(1, color);
			drawSelf();
		}
		
		//public function sees(tx : Number, ty : Number):Boolean
		public function sees(d : Dmut):Boolean
		{
			var visible : Boolean = true;
			var res : Number = Main.distance(x, y, d.x, d.y) / 5;
			for (var i : int = 0; visible == true && i < res; i++)
			{
				visible = parent.hitTestPoint
				(
					this.x * (res - i) / res + d.x * i / res,
					this.y * (res - i) / res + d.y * i / res,
					true
				);
			}
			return visible;
		}
		
		
		protected function drawSelf():void
		{
			graphics.drawCircle(0, 0, 5);
		}
	}

}