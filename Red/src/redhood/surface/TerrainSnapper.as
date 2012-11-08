package redhood.surface 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	/**
	 * Terrain Snapper class finds a terrain pixel being the closest to given coordinates.
	 * This class is designed to work with project dimensions set to 512x512. Some changes probably need to be done for other dimensions.
	 * @author Markus Smoliński
	 */
	public class TerrainSnapper 
	{
		/**
		 * Initialize anywhere.
		 * @param	debugLayer set it if you want to draw squares for debugging
		 */
		public function TerrainSnapper ( debugLayer:Sprite = null ) 
		{ _constructor ( debugLayer ) }
		
		/**
		 * Prepares bitmapGrids
		 * @param	terrain a raster or vector object to draw on bitmapGrids
		 */
		public function init ( terrain:DisplayObject ):void
		{ _init ( terrain ) }
		
		public function drawDebug ():void
		{ _drawDebug () }
		
		/**
		 * Find the closest point on terrain to given coordinates (e.g. mouse cursor)
		 * @param	x typically mouseX
		 * @param	y typically mouseY
		 */
		public function getClosestPoint ( x:int, y:int ):Vector.<int>
		{ return _getClosestPoint ( x, y ) }
		
		public function get x ():int { return getClosest ( 0 ) }
		public function get y ():int { return getClosest ( 1 ) }
		public function get distance ():int { return getClosest ( 2 ) }
		
		
		/***********************************************
		 *   IMPLEMENTATION
		 ***********************************************/
		
		private var debugLayer:Sprite;
		private var strengthenColor:ColorTransform = new ColorTransform ( 100, 100, 100 );
		
		private var bitmapGrids : Vector.<BitmapData> = new Vector.<BitmapData>;
		private var gridDebugColors : Array = [ 0xAAAAAA, 0xFFFFFF, 0xFF, 0xFF00, 0xFF0000, 0xFFFF, 0xFFFF00, 0x010101, 0xFFFFFF ];
		
		private var mouseXcache:Vector.<int>;
		private var mouseYcache:Vector.<int>;
		private var levelMultiplier:Vector.<int>;
		
		private var parentX:Vector.<int> = new Vector.<int>(200, true);
		private var parentY:Vector.<int> = new Vector.<int>(200, true);
		private var parentMin:Vector.<int> = new Vector.<int>(200, true);
		
		private var childX:Vector.<int> = new Vector.<int>(200, true);
		private var childY:Vector.<int> = new Vector.<int>(200, true);
		private var childMin:Vector.<int> = new Vector.<int>(200, true);
		
		private var cache:Object;
		
		private var mouseX:int;
		private var mouseY:int;
		private var parentLen:int;
		private var childLen:int;
		
		private function get lastLevel ():int { return bitmapGrids.length - 1 }
		private function getLevelMultiplier ( level:int ):int
		{ return bitmapGrids[0].width * Math.pow ( 2, lastLevel - level ) }
		private function toGlobal ( v:int, level:int ):Number { return ( v + .5 ) * getLevelMultiplier ( level ) }
		
		private function _constructor ( debugLayer:Sprite = null ):void
		{
			//this.debugLayer = debugLayer;
		}
		
		private function _init ( terrain:DisplayObject ):void
		{
			cache = { };
			var i:int;
			var bdata:BitmapData = new BitmapData ( terrain.stage.stageWidth, terrain.stage.stageHeight, false, 0 );
			bdata.draw ( terrain, null, strengthenColor );
			
			createGrids ( bdata );
			
			mouseXcache = new Vector.<int>(bitmapGrids.length, true);
			mouseYcache = new Vector.<int>(bitmapGrids.length, true);
			levelMultiplier = new Vector.<int>(bitmapGrids.length, true);
			for ( i = 0; i < bitmapGrids.length; i++ ) {
				levelMultiplier[i] = bitmapGrids[0].width * Math.pow ( 2, lastLevel - i );
			}
		}
		
		private function _drawDebug ():void
		{
			if ( !debugLayer ) return;
			for ( var i:int = 0; i < bitmapGrids.length; i++ ) {
				var bmp:Bitmap = new Bitmap ( bitmapGrids[i] );
				bmp.width = debugLayer.stage.stageWidth;
				bmp.height = debugLayer.stage.stageHeight;
				bmp.alpha = .1;
				debugLayer.addChild ( bmp );
			}
			showGrids ( true );
		}
		
		private function getCache ( x:int, y:int ):Vector.<int>
		{
			if ( !cache[x] ) cache[x] = { };
			return cache[x][y];
		}
		
		private function getClosest ( index:int ):int
		{
			var p:Vector.<int> = getCache ( mouseX, mouseY );
			if ( p ) return cache[mouseX][mouseY][index];
			else return -1;
		}
		
		private function _getClosestPoint ( pointX:int, pointY:int ):Vector.<int>
		{
			if ( getCache(pointX, pointY) ) return cache[mouseX][mouseY];
			mouseX = pointX;
			mouseY = pointY;
			
			if ( debugLayer ) debugLayer.graphics.clear ();
			if ( bitmapGrids[lastLevel].getPixel(mouseX, mouseY) ) {
				cache[mouseX][mouseY] = new <int>[mouseX, mouseY, 0];
				return cache[mouseX][mouseY];
			}
			
			var x:int, y:int, i:int, smallestMax:int;
			
			parentX[0] = 0;
			parentY[0] = 0;
			parentMin[0] = 0;
			parentLen = 1;
			childLen = 0;
			
			for ( i = 0; i < bitmapGrids.length; i++ ) {
				mouseXcache[i] = Math.floor ( mouseX / levelMultiplier[i] );
				mouseYcache[i] = Math.floor ( mouseY / levelMultiplier[i] );
			}
			
			for ( var level:int = 0; level <= lastLevel; level ++ ) {
				smallestMax = int.MAX_VALUE;
				for ( i = 0; i < parentLen; i++ ) {
					x = parentX[i] * 2;
					y = parentY[i] * 2;
					smallestMax = Math.min ( smallestMax,
						pushCell (  x, y, level ),
						pushCell (  x+1, y, level ),
						pushCell (  x, y+1, level ),
						pushCell (  x+1, y+1, level )
					);
				}
				parentLen = 0;
				for ( i = 0; i < childLen; i++ ) {
					if ( childMin[i] <= smallestMax ) {
						parentX[parentLen] = childX[i];
						parentY[parentLen] = childY[i];
						parentMin[parentLen] = childMin[i];
						parentLen++;
						if ( debugLayer ) drawDebugCell ( childX[i], childY[i], level );
					}
				}
				childLen = 0;
			}
			
			var closest:int = -1;
			var distance:int = int.MAX_VALUE;
			for ( i = 0; i < parentLen; i++ ) {
				var dx:int = mouseX - parentX[i];
				var dy:int = mouseY - parentY[i];
				var dist:int = dx * dx + dy * dy;
				if ( dist < distance ) {
					distance = dist;
					closest = i;
				}
			}
			cache[mouseX][mouseY] = new <int>[parentX[closest], parentY[closest], distance];
			return cache[mouseX][mouseY];
		}
		
		private function createGrids ( bdata:BitmapData ):void
		{
			bitmapGrids.length = 0;
			bitmapGrids.push ( bdata );
			var matrix:Matrix = new Matrix ();
			matrix.scale ( .5, .5 );
			do {
				var bdataBuffer:BitmapData = new BitmapData ( bdata.width *.5, bdata.height *.5, false, 0 );
				var bmp:Bitmap = new Bitmap ( bdata );
				//bdataBuffer.draw ( bdata, matrix ); //bad!
				
				bdataBuffer.draw ( bmp, matrix, new ColorTransform (50, 50, 50) );
				bdata = bdataBuffer;
				bitmapGrids.unshift ( bdata );
			} while ( bdata.width > 1 && bdata.height > 1 );
		}
		
		private function pushCell ( x:int, y:int, level:int ):int {
			//if ( bitmapGrids[level].width < x + 1 || bitmapGrids[level].height < y + 1 ) return int.MAX_VALUE;
			if ( !bitmapGrids[level].getPixel(x, y) ) return int.MAX_VALUE;
			childX[childLen] = x;
			childY[childLen] = y;
			childMin[childLen] = cellDistance(false, x, y, level);
			childLen ++;
			return cellDistance ( true, x, y, level );
		}
		
		/**
		 * Get distance between mouse cursor and the nearest/furthest point of a cell.
		 * @param	max - set to true for the furthest point, or false for the nearest
		 * @param	level - number of bitmapGrid to take as coordinate system
		 */
		private function cellDistance ( max:Boolean, cellX:int, cellY:int, level:int ):int
		{
			var x:int = mouseX;
			var y:int = mouseY;
			
			var dim:int = levelMultiplier[level];
			
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
		
		private function showGrids ( fixedWidth:Boolean = false ):void
		{
			var offset:Number = 0;
			for ( var i:int = 0; i < bitmapGrids.length; i++ ) {
				var bmp:Bitmap = new Bitmap ( bitmapGrids[i] );
				debugLayer.addChild ( bmp );
				if ( fixedWidth ) bmp.width = bmp.height = 50;
				bmp.y = debugLayer.stage.stageHeight - bmp.height;
				bmp.x = offset;
				offset += bmp.width;
			}
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
		
		
	}
}