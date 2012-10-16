package  
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Forest extends Shape
	{
		public function Forest() 
		{	
			/*
			for (var i : int = 0; i < height; i+= height / detail)
			{
				//testmode
				var scale : Number = 1 - Math.min(1, i / height);

				graphics.lineStyle(1, 0x030400 * (Math.floor((1 - scale) * 32)  + 4));
				for (var j : int = 0; j < detail * 2; j ++)
				{
					var angle : Number = j / (detail * 2) * Math.PI * 2;
					var modScale : Number = (0.93 + 0.15 * Math.random()) * Math.pow(scale, 0.8);
					graphics.beginFill(0x030400 * (Math.floor((1 - scale) * 32) + 8));
					graphics.drawCircle(scale * f(scale) * Math.cos(angle) * width / 2, scale * f(scale) * Math.sin(angle) * width / 2 + height * (0.3 + 0.7 *Math.pow(scale, 1.7)), scale * f(scale) * width / (detail * 1.4));					
					graphics.drawCircle(200 + (modScale) * Math.cos(angle) * width / 2, (modScale) * Math.sin(angle) * width / 2 + height - i, (modScale) * width / (detail * 1.2));					
				}
				graphics.beginFill(0x030400 * (Math.floor((1 - scale) * 32) + 8));
				graphics.lineStyle(1, 0x030400 * (Math.floor((1 - scale) * 32) + 8));
				graphics.drawCircle(0, + height * (0.3 + 0.7 *Math.pow(scale, 1.7)), 1.1 * scale * f(scale) * Math.cos(angle) * width / 2);
				graphics.drawCircle(200, + height - i, 1.1 * (modScale) * Math.cos(angle) * width / 2);
			}
			*/

			//genTree();
		}
		
		public function spawnForest(area : Shape):void //the area is the area to avoid..
		{
			graphics.clear();
			var even : Boolean = true;
			for (var i : int = 0; i < stage.stageHeight; i += 40 +Math.random() * 15)
			{
				even = !even;
				for (var j : int = 0; j < stage.stageWidth; j += 40 +Math.random() * 15)
				{
					if (//Math.random() > 0.1 &&
					checkArea(area, j, i, 35, 35))
					{
						genTree(j - int(even) * 30 , i);
					}
				}
			}
		}
		
		private function checkArea(area : Shape, dx : uint, dy : uint, w : uint, h : uint):Boolean //checks if you can plant a tree there
		{
			var canPlant : Boolean = true;
			for (var i : int = 0; i <= h * 1.8 && canPlant; i+= h / 7)
			{
				for (var j: int = - 0.4 * w ; j <= w * 1.2 && canPlant; j+= w / 7)
				{
					canPlant = !area.hitTestPoint(dx + j, dy + i, true); 
				}
			}
			return canPlant;
		}
		
		public function genTree( dx : uint = 0, dy : uint = 0, base : uint = 0xb0f000, low : Number = 0.3, high : Number = 0.8, detail : uint = 7, w : uint = 32, h : uint = 32):void
		{	
			/*
			graphics.beginFill(0x402000);
			graphics.lineStyle(3, 0x362001);
			//graphics.drawRect(1.2 * w / 2 - w / 5, h / 2, w / 2.5, 1.3 * h);
			*/
			graphics.beginFill(0x625239);
			graphics.lineStyle(3, 0x6D4E1F);
			graphics.drawCircle(dx+ 1.2 * w / 2, dy + 1.65 * h, w / 7);
			for (var i : int = h; i > 0; i -= h / (detail * 1.2))
			{
				var scale : Number = i / Number(h);
				graphics.lineStyle(2, multiColor(base, (high - low) * (1-scale) + low));
				for (var j : int = 0; j < (1.5 * detail) ; j++)
				{
					var angle : Number = (3/4) * Math.PI + ((j + Math.random()/3) / (detail * 1.5)) * Math.PI * 1.5;
					var modScale : Number = (1 - 0.1 * Math.random()) * Math.pow(scale, 0.75);
					graphics.beginFill(multiColor(base, (high - low - 0.05) * (1-scale) + (low + 0.05)));
					graphics.drawCircle(dx+ (1.2 + modScale * Math.cos(angle)) * w / 2, dy + h/10 + i - modScale * Math.sin(angle) * (w / 2), (modScale * w) / (detail * 1.21)); 
				}
				graphics.lineStyle(2, multiColor(base, (high - low) * (1-scale) + low));
				graphics.beginFill(multiColor(base, (high - low) * (1-scale) + low));
				graphics.drawCircle(dx + 1.2 * w/2, dy + h/10 + i, 0.9 * modScale * w / 2);//change this to 1.1 to create mountain like imagery//
			}
			graphics.beginFill(multiColor(base, 0.85 * (1-scale) + 0.15));
			graphics.drawEllipse(dx+ 1.2 * w/2 - 0.5 * modScale * (w / 2), dy+ h/10, 1 * modScale * w / 2, 2 * modScale * w / 2);
			
		}
		
		public function genBush():void
		{
			
		}
		
		private function getBitmapData():BitmapData
		{
			return null;
		}
		
		private function multiColor(color : uint, val : Number):uint
		{
				var red : uint = val * Math.floor(color / 0x10000);
				var grn : uint = val * Math.floor((color % 0x10000) / 0x100);
				var blu : uint = val * Math.floor((color % 0x100));
				return (0x10000 * red + 0x100 * grn + 0x1 * blu);
		}
	
		private function f(val : Number):Number
		{
			return Math.sin(val * Math.PI);
		}
	}
}