package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Dmut extends Bitmap
	{
		private var t : uint = 0;
		private var dir : uint = 0;
		private var lastX : Number = 0;
		private var lastY : Number = 0;
		private var sprite : Vector.<BitmapData> = new Vector.<BitmapData>(16, true);//animation//
		public var speedMultiplier : Number = 1.0; //Multiply by BASE_SPEED
		public function Dmut(bmp : BitmapData = null, speedMulti : Number = 1.0, animated : Boolean = true) 
		{
			speedMultiplier = speedMulti;
			if (bmp != null)
			{
				if (animated)
				{
					for (var i : int = 0 ; i < 4; i++)
					{
						for (var j : int = 0; j < 4; j++)
						{
							sprite[j + 4 * i] = new BitmapData(bmp.width / 4, bmp.height / 4, true, 0);
							sprite[j + 4 * i].copyPixels(bmp, new Rectangle(j * bmp.width / 4, i * bmp.height / 4, bmp.width / 4, bmp.height / 4), new Point());
						}
					}
					this.bitmapData = sprite[0];
				}
				else
				{
					sprite = null;
					this.bitmapData = bmp;
				}
			}
		}
		public function set posX(newX : Number):void
		{
			lastX = x;
			x = newX;
			
			//
			dir = 0;
			if (Math.abs(lastX - x) > Math.abs(lastY - y))
			{
				if (lastX < x)
				{
					dir = 0;
				}
				else
				{
					dir = 1;
				}
			}
			else
			{
				if (lastY < y)
				{
					dir = 2;
				}
				else
				{
					dir = 3;
				}
			}
			bitmapData = sprite[t % 4 + dir * 4];
			t++;
			
		}
		
		public function set posY(newY : Number):void
		{
			lastY = y;
			y = newY;
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
			//graphics.drawCircle(0, 0, 5);
		}
	}

}