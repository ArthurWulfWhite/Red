package redhood.surface
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import XMLLoader;
	
	import flash.utils.getTimer;
	
	import redhood.structs.Cell;
	
	public class WalkableSurface extends Sprite 
	{
		private var grass : Grass = new Grass();
		public var debug:Boolean = false;
		
		private var debugLayer:Sprite = new Sprite ();
		
		private var bitmapGrids : Vector.<BitmapData> = new Vector.<BitmapData>;
		
		private var gridDebugColors : Array = [ 0xAAAAAA, 0xFFFFFF, 0xFF, 0xFF00, 0xFF0000, 0xFFFF, 0xFFFF00, 0x010101, 0xFFFFFF ];
		
		private var averageTime:Number = -1;
		private var timesTested:int = 0;
		
		private var mouseXcache:Vector.<int>;
		private var mouseYcache:Vector.<int>;
		private var levelMultiplier:Vector.<int>;
		/*
		override public function get mouseX ():Number
		{
			return 200;
		}
		*/
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
			
			mouseXcache = new Vector.<int>(bitmapGrids.length, true);
			mouseYcache = new Vector.<int>(bitmapGrids.length, true);
			levelMultiplier = new Vector.<int>(bitmapGrids.length, true);
			for ( var i:int = 0; i < bitmapGrids.length; i++ ) {
				levelMultiplier[i] = bitmapGrids[0].width * Math.pow ( 2, totalLevels - i );
			}
			
			
			if ( debug ) {
				showGrids ( true );
				var bmp:Bitmap = new Bitmap ( bitmapGrids[3] );
				var bmp2:Bitmap = new Bitmap ( bitmapGrids[4] );
				var bmp3:Bitmap = new Bitmap ( bitmapGrids[5] );
				bmp3.width = bmp3.height = bmp2.width = bmp2.height = bmp.width = bmp.height = stage.stageWidth;
				bmp3.alpha = bmp2.alpha = bmp.alpha = .25;
				addChild ( bmp );
				addChild ( bmp2 );
				addChild ( bmp3 );
				addChild ( debugLayer );
			}
		}
		
		/**
		 * Find the closest point to given coordinates
		 * @param	x typically Mouse X
		 * @param	y typically Mouse Y
		 * @return	x and y in an <int> vector
		 */
		
		public function getClosestPoint1():Vector.<int> 
		{
			//*
			var t:int = getTimer ();
			for ( var i:int = 1; i < 100; i ++ ) {
				getClosestPoint  ();
			}
			t = getTimer () - t;
			timesTested ++;
			averageTime = averageTime * (timesTested - 1) / timesTested + t / timesTested;
			trace ( averageTime, "   ", t ); 
			//*/
			return getClosestPoint  ();
		}
		
		//private var parentCells:Vector.<Cell> = new <Cell>[new Cell()];
		//private var childCells:Vector.<Cell> = new Vector.<Cell>;
		
		private var parentX:Vector.<int>;
		private var parentY:Vector.<int>;
		private var parentMin:Vector.<int>;
		
		private var childX:Vector.<int>;
		private var childY:Vector.<int>;
		private var childMin:Vector.<int>;
		
		public function getClosestPoint  ():Vector.<int>
		{
			if ( debug ) debugLayer.graphics.clear ();
			if ( bitmapGrids[bitmapGrids.length - 1].getPixel(mouseX, mouseY) ) return new <int>[mouseX, mouseY];
			
			var numberCells:int = 0;
			
			var x:int, y:int, i:int;
			
			parentX = new <int>[0];
			parentY = new <int>[0];
			parentMin = new <int>[0];
			
			childX = new Vector.<int>;
			childY = new Vector.<int>;
			childMin = new Vector.<int>;
			
			//parentCells = new <Cell>[new Cell()];
			//childCells = new Vector.<Cell>;
			
			var smallestMax:int;
			
			for ( i = 0; i < bitmapGrids.length; i++ ) {
				mouseXcache[i] = Math.floor ( mouseX / levelMultiplier[i] );
				mouseYcache[i] = Math.floor ( mouseY / levelMultiplier[i] );
			}
			
			for ( var level:int = 0; level <= totalLevels; level ++ ) {
				smallestMax = int.MAX_VALUE;
				for ( i = 0; i < parentX.length; i++ ) {
					x = parentX[i] * 2;
					y = parentY[i] * 2;
					smallestMax = Math.min ( smallestMax,
						pushCell (  x, y, level ),
						pushCell (  x+1, y, level ),
						pushCell (  x, y+1, level ),
						pushCell (  x+1, y+1, level )
					);
				}
				parentX.length = 0;
				parentY.length = 0;
				parentMin.length = 0;
				for ( i = 0; i < childX.length; i++ ) {
					if ( childMin[i] <= smallestMax ) {
						numberCells ++;
						parentX.push ( childX[i] );
						parentY.push ( childY[i] );
						parentMin.push ( childMin[i] );
						if ( debug ) drawDebugCell ( childX[i], childY[i], level );
					}
				}
				childX.length = 0;
				childY.length = 0;
				childMin.length = 0;
			}
			
			var closest:int = -1;
			var distance:int = int.MAX_VALUE;
			for ( i = 0; i < parentX.length; i++ ) {
				var dx:int = mouseX - parentX[i];
				var dy:int = mouseY - parentY[i];
				var dist:int = dx * dx + dy * dy;
				if ( dist < distance ) {
					distance = dist;
					closest = i;
				}
			}
			trace ( " NUMBER CELLS: ", numberCells );
			return new <int>[parentX[closest], parentY[closest]];
		}
		
		private function drawDebugCell ( x:int, y:int, level:int ):void
		{
			x = toGlobal ( x, level );
			y = toGlobal ( y, level );
			if ( gridDebugColors[level] ) {
				debugLayer.graphics.lineStyle ( 1, gridDebugColors[level], 1 );
				var dim:Number = getLevelMultiplier ( level ) / 2;
				debugLayer.graphics.drawRect ( x - dim, y - dim, dim*2, dim*2 );
			}
		}
		
		private function pushCell ( x:int, y:int, level:int ):int {
			//if ( bitmapGrids[level].width < x + 1 || bitmapGrids[level].height < y + 1 ) return int.MAX_VALUE;
			//trace ( mouseXcache[level], x, mouseYcache[level], y );
			//if ( x > mouseXcache[level] + 1 ) return int.MAX_VALUE;
			///if ( x < mouseXcache[level] - 1 ) return int.MAX_VALUE;
			//if ( y > mouseYcache[level] + 1 ) return int.MAX_VALUE;
			//if ( y < mouseYcache[level] - 1 ) return int.MAX_VALUE;
			
			if ( !bitmapGrids[level].getPixel(x, y) ) return int.MAX_VALUE;
			//trace ( x, y );
			
			//childCells.push ( new Cell(x, y, cellDistance(false, x, y, level)) );
			childX.push ( x );
			childY.push ( y );
			childMin.push ( cellDistance(false, x, y, level) );
			return cellDistance ( true, x, y, level );
		}
		
		/**
		 * square of distance between given point (mouse cursor) and furthest point of a cell.
		 * @return TEST
		 */
		private function cellDistance ( max:Boolean, cellX:int, cellY:int, level:int ):int
		{
			var x:int = mouseX;
			var y:int = mouseY;
			
			var dim:int = levelMultiplier[level];
			//var dim:int = getLevelMultiplier ( level );
			
			//cellX = Math.floor ( x / dim );
			//cellY = Math.floor ( y / dim );
			
			var left:int = cellX * dim;
			var right:int = left + dim;
			var top:int = cellY * dim;
			var bot:int = top + dim;
			
			var dx:int, dy:int;
			if ( max ) {
				if ( x < left ) dx = x - right;
				else if ( x > right ) dx = x - left;
				else {
					dx = x % dim;
					if ( dx < dim *.5 ) dx = dim - dx; 
				}
				
				if ( y < top ) dy = y - bot;
				else if ( y > bot ) dy = y - top;
				else {
					dy = y % dim;
					if ( dy < dim *.5 ) dy = dim - dy;
				}
			} else {
				if ( x < left ) dx = x - left;
				else if ( x > right ) dx = x - right;
				else {
					dx = x % dim;
					if ( dx > dim  *.5 ) dx = dim - dx; 
				}
				
				if ( y < top ) dy = y - top;
				else if ( y > bot ) dy = y - bot;
				else {
					dy = y % dim;
					if ( dy > dim * .5 ) dy = dim - dy;
				}
			}
			
			return dx * dx + dy * dy;
		}
		
		
		private function get totalLevels ():int { return bitmapGrids.length - 1 }
		private function getLevelMultiplier ( level:int ):int { 
			return bitmapGrids[0].width * Math.pow ( 2, totalLevels - level )
		}
		private function toGlobal ( v:int, level:int ):Number { return ( v + .5 ) * getLevelMultiplier ( level ) }
		
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
				
				bdataBuffer.draw ( bmp, matrix, new ColorTransform (50, 50, 50) );
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