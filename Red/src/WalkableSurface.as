package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import XMLLoader;
	/**
	 * ...
	 * @author Etherlord
	 */
	public class WalkableSurface extends Sprite 
	{
		private var grass : Grass = new Grass();
		
		private var bitmaps : Vector.<BitmapData> = new Vector.<BitmapData>;
		
		public function WalkableSurface() 
		{
			
		}
		
		public function draw ( lvlNum:int ):void
		{
			graphics.clear();
			graphics.lineStyle(24, 0x8800);
			graphics.lineBitmapStyle(grass);
			drawAreas ( lvlNum );
			drawPaths ( lvlNum );
			//draw itself on a bitmap and scale it down 8 times.
			var bdata:BitmapData = new BitmapData ( stage.stageWidth, stage.stageHeight, true, 0 );
			var bmp:Bitmap = new Bitmap ( bdata );
			bdata.draw ( this );
			
			var bdataSmall:BitmapData = new BitmapData ( bdata.width, bdata.height, true, 0 );
			var matrix:Matrix = new Matrix ();
			matrix.scale ( 1 / 8, 1 / 8 );
			
			bdataSmall.draw ( bmp, matrix );
			var bmpSmall:Bitmap = new Bitmap ( bdataSmall );
			
			bitmaps.push ( bdataSmall );
			/*
			addChild ( bmpSmall );
			graphics.clear ();
			//*/
		}
		
		/**
		 * Find the closest point to given coordinates
		 * @param	x typically Mouse X
		 * @param	y typically Mouse Y
		 * @return	x and y in an <int> vector
		 */
		public function getClosestPoint ( x:int, y:int ):Vector.<int>
		{
			var distance:int = 9999999999999;
			
			var resultX:int = 0;
			var resultY:int = 0;
			for ( var px:int = 0; px < bitmaps[0].width; px++ )
				for ( var py:int = 0; py < bitmaps[0].height; py++ )
					if ( bitmaps[0].getPixel(px, py) ) {
						var dx:int = px*8+4 - x;
						var dy:int = py*8+4 - y;
						var distance2:int = dx * dx + dy * dy;
						if ( distance2 < distance ) {
							distance = distance2;
							resultX = px;
							resultY = py;
						}
					}
			
			trace ( resultX*8, resultY*8 );
			return new <int>[resultX*8, resultY*8];
		}
		
		private function drawAreas ( lvlNum:int ):void
		{
			var i:int;
			for each(var a : XML in XMLLoader.xml.shalav[lvlNum].area)
			{
				graphics.beginFill(0x8404);
				graphics.beginBitmapFill(grass);
				var data:Array = String(a).split(",");
				for ( i = 0; i < data.length; i++)
				{
					data[i] = Number(data[i]);
				}
				graphics.moveTo(data[0], data[1]);
				for (i = 0; i < data.length - 2; i += 2)
				{
					graphics.curveTo
					(
						data[i], data[i + 1],
						(data[i] + data[i + 2]) / 2,
						(data[i+1] + data[i + 3])/2
					);
				}
				graphics.endFill();
			}
		}
		
		private function drawPaths ( lvlNum:int ):void
		{
			var i:int;
			for each( var p : XML in XMLLoader.xml.shalav[lvlNum].path )
			{
				var data:Array = String(p).split(",");
				for (i = 0; i < data.length; i++)
				{
					data[i] = Number(data[i]);
				}
				graphics.moveTo(data[0], data[1]);
				for (i = 0; i < data.length - 2; i += 2)
				{
					graphics.curveTo
					(
						data[i], data[i + 1],
						(data[i] + data[i + 2]) / 2,
						(data[i+1] + data[i + 3])/2
					);
				}
				graphics.lineTo(data[i], data[i + 1]);
			}
		}
		
	}
}