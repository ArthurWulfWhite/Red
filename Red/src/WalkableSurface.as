package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import XMLLoader;
	
	import flash.utils.getTimer;
	
	public class WalkableSurface extends Sprite 
	{
		private var grass : Grass = new Grass();
		
		private var debugLayer:Sprite = new Sprite ();
		
		private var bitmapGrids : Vector.<BitmapData> = new Vector.<BitmapData>;
		
		private var gridDebugColors : Array = [ 0xAAAAAA, 0xFFFFFF, 0xFF, 0xFF00, 0xFF0000, 0xFFFF, 0xFFFF00 ];
		
		public function WalkableSurface() 
		{
			
		}
		
		public function draw ( lvlNum:int ):void
		{
			while ( numChildren ) removeChildAt ( 0 );
			graphics.clear();
			graphics.lineStyle(24, 0x8800);
			graphics.lineBitmapStyle(grass);
			drawAreas ( lvlNum );
			drawPaths ( lvlNum );
			
			//draw itself on a bitmap and scale it down
			var bdata:BitmapData = new BitmapData ( stage.stageWidth, stage.stageHeight, false, 0 );
			bdata.draw ( this );
			createGrids ( bdata );
			
			showGrids ( true );
			
			//graphics.clear ();
			var bmp:Bitmap = new Bitmap ( bitmapGrids[3] );
			var bmp2:Bitmap = new Bitmap ( bitmapGrids[4] );
			bmp2.width = bmp2.height = bmp.width = bmp.height = stage.stageWidth;
			bmp2.alpha = bmp.alpha = .2;
			addChild ( bmp );
			addChild ( bmp2 );
			addChild ( debugLayer );
		}
		
		/**
		 * Find the closest point to given coordinates
		 * @param	x typically Mouse X
		 * @param	y typically Mouse Y
		 * @return	x and y in an <int> vector
		 */
		public function getClosestPoint ():Vector.<int>
		{	
			debugLayer.graphics.clear ();
			var arr:Array = new Array ();
			
			//The funny thing is that these two loops serve a single pixel :D
			for ( var x:int = 0; x < bitmapGrids[0].width; x++ ) {
				for ( var y:int = 0; y < bitmapGrids[0].height; y++ ) {
					if ( !bitmapGrids[0].getPixel(x, y) ) continue;
					arr.push ( { x:toGlobal(x,0), y:toGlobal(y,0), nextLevel: {x:x,y:y} } );
				}
			}
			//arr.length == 1 :D
			
			var winner:int = findClosestInArray ( arr );
			return chooseOneFromFour ( arr[winner].nextLevel.x, arr[winner].nextLevel.y, 1 );
			//at this moment it could be as well: return chooseOneFromFour ( 0, 0, 2 );
		}
		
		private function get totalLevels ():int { return bitmapGrids.length - 1 }
		private function getLevelMultiplier ( level:int ):int { return Math.pow ( 2, totalLevels - level ) }
		private function toGlobal ( v:int, level:int ):Number { return ( v + .5 ) * getLevelMultiplier ( level ) }
		
		private var debug:Boolean = false;
		
		private function chooseOneFromFour ( x:int, y:int, level:int ):Vector.<int>
		{
			//if ( level == 2 ) trace ( x, y );
			var realX1:Number = toGlobal ( x, level );
			var realX2:Number = toGlobal ( x + 1, level );
			var realY1:Number = toGlobal ( y, level );
			var realY2:Number = toGlobal ( y + 1, level );
			
			var arr:Array = new Array ();
			arr.push ( { x:realX1, y:realY1, color:bitmapGrids[level].getPixel(x,y) } );
			arr.push ( { x:realX2, y:realY1, color:bitmapGrids[level].getPixel(x+1,y) } );
			arr.push ( { x:realX1, y:realY2, color:bitmapGrids[level].getPixel(x,y+1) } );
			arr.push ( { x:realX2, y:realY2, color:bitmapGrids[level].getPixel(x+1,y+1) } );
			
			var winner:int = findClosestInArray ( arr );
			if ( winner % 2 ) x ++;
			if ( winner > 1 ) y ++;
			
			if ( gridDebugColors[level] ) {
				debugLayer.graphics.lineStyle ( 1, gridDebugColors[level], 1 );
				var dim:Number = getLevelMultiplier ( level ) / 2;
				debugLayer.graphics.drawRect ( arr[winner].x - dim, arr[winner].y - dim, dim*2, dim*2 );
			}
			
			if ( level == totalLevels ) return new <int>[x, y];
			else return chooseOneFromFour ( x*2, y*2, level + 1 ); //recurrency FTW
		}
		
		private function findClosestInArray ( arr:Array ):int
		{
			var distance:int = 123456789;
			var resultIndex:int;
			for ( var i:int = 0; i < arr.length; i++ ) {
				if ( arr[i].color == 0 ) continue;
				var dx:int = mouseX - arr[i].x;
				var dy:int = mouseY - arr[i].y;
				var distance2:int = dx * dx + dy * dy;
				if ( distance2 < distance ) {
					distance = distance2;
					resultIndex = i;
				}
			}
			return resultIndex;
		}
		
		private function createGrids ( bdata:BitmapData ):void
		{
			bitmapGrids.length = 0;
			bitmapGrids.push ( bdata );
			var matrix:Matrix = new Matrix ();
			matrix.scale ( .5, .5 );
			do {
				var bdataBuffer:BitmapData = new BitmapData ( bdata.width / 2, bdata.height / 2, false, 0 );
				var bmp:Bitmap = new Bitmap ( bdata );
				//bdataBuffer.draw ( bdata, matrix ); //bad!
				
				bdataBuffer.draw ( bmp, matrix, new ColorTransform (5, 5, 5) );
				bdata = bdataBuffer;
				bitmapGrids.unshift ( bdata );
				
			} while ( bdata.width > 1 && bdata.height > 1 );
		}
		
		private function showGrids ( fixedWidth:Boolean = false ):void
		{
			var offset:Number = 0;
			for ( var i:int = 0; i < bitmapGrids.length; i++ ) {
				var bmp:Bitmap = new Bitmap ( bitmapGrids[i] );
				addChild ( bmp );
				if ( fixedWidth ) bmp.width = bmp.height = 50;
				bmp.y = stage.stageHeight - bmp.height;
				bmp.x = offset;
				offset += bmp.width;
			}
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