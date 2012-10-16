package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Grass extends BitmapData
	{	
		private var pn : BitmapData;
		private var n : BitmapData;
		
		public function Grass(size : uint = 512)
		{
			super(size, size);
			pn = new BitmapData(size / 2, size / 2);
			n = new BitmapData(size / 2, size / 2);
			gen();
		}
		
		public function gen(t : Number = 0.5):void
		{
			var rnd : Number = int.MAX_VALUE * Math.random();
			n.noise(rnd, 155, 189, 7, true);
			rnd = int.MAX_VALUE * Math.random();
			pn.perlinNoise(101, 126, 14, rnd, true, true, 7, true);
			var color: uint = 0;
			for (var i : int = 0; i < width; i++)
			{
				for (var j : int = 0; j < width; j ++)
				{
					color = multiColor(n.getPixel(j / 2, i / 2), t) + multiColor(pn.getPixel(j / 2, i / 2), (1 - t));
					setPixel(j, i, multiColor2(color, 0xeebb70));//decColorDepth(color * 0x0D0B07 , 6 ));
				}
			}
		}
		
		private function multiColor2(color : uint, color2 : Number):uint
		{
			var red : uint = Math.floor(color / 0x10000) * Math.floor(color2 / 0x10000)/256;
			var grn : uint = Math.floor((color % 0x10000) / 0x100) * Math.floor((color2 % 0x10000) / 0x100)/256;
			var blu : uint = Math.floor((color % 0x100)) * Math.floor((color % 0x100)) / 256;
			return (0x10000 * red + 0x100 * grn + 0x1 * blu);
		}
		
		private function multiColor(color : uint, val : Number):uint
		{
			var red : uint = val * Math.floor(color / 0x10000);
			var grn : uint = val * Math.floor((color % 0x10000) / 0x100);
			var blu : uint = val * Math.floor((color % 0x100));
			return (0x10000 * red + 0x100 * grn + 0x1 * blu);
		}
		
		private function decColorDepth(color : uint, bits : uint):uint
		{
			var colorGap : uint = Math.pow(2, 7 - bits);
			
			var red : uint = Math.floor(color / 0x10000);
			red = red - (red % colorGap);
			var grn : uint = Math.floor((color % 0x10000) / 0x100);
			grn = grn - (grn % colorGap);
			var blu : uint = Math.floor((color % 0x100));
			blu = blu - (blu % colorGap);
			return (0x10000 * red + 0x100 * grn + 0x1 * blu);
		}
	}
}