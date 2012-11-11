package redhood.surface 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	
	/**
	 * Path Finder class calculates the shortest path in lower resolution of a map and returns points on 16x16 px grid.
	 * This class is designed to work with project dimensions set to 512x512, although it seems it will work on other dimensions as well.
	 * @author Markus Smoliński
	 */
	public class PathFinder 
	{
		/**
		 * Initialize anywhere.
		 * @param	debugLayer set it if you want to draw for debugging
		 */
		public function PathFinder ( debugLayer:Sprite )
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
		 * Find the shortest path from source to destination
		 */
		public function makePath ( sourceX:Number, sourceY:Number, destinationX:int, destinationY:int ):Path
		{ return _makePath ( sourceX, sourceY, destinationX, destinationY ) }
		
		/***********************************************
		 *   IMPLEMENTATION
		 ***********************************************/
		
		private var highResBdata:BitmapData;
		private const LOW_RES:int = 128;
		private const FROM_LOW_RES:Number = LOW_RES / 512;
		private const TO_LOW_RES:Number = 512 / LOW_RES;
		
		private var debugLayer:Sprite;
		private var lowRes:BitmapData;
		private var lowResGrid:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(LOW_RES, true);
		private var index:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(LOW_RES, true);
		private var strengthenColor:ColorTransform = new ColorTransform ( 100, 100, 100 );
		
		private function _constructor ( debugLayer:Sprite ):void
		{
			this.debugLayer = debugLayer;
		}		
		
		private function _init ( terrain:DisplayObject ):void
		{
			highResBdata = new BitmapData ( terrain.stage.stageWidth, terrain.stage.stageHeight, false, 0 );
			highResBdata.draw ( terrain, null, strengthenColor );
			
			createGrids ( highResBdata );
		}
		
		private function _drawDebug ():void
		{
			var bmp:Bitmap = new Bitmap ( lowRes );
			bmp.width = debugLayer.stage.stageWidth;
			bmp.height = debugLayer.stage.stageHeight;
			bmp.alpha = .2;
			//debugLayer.addChild ( bmp );
			//*/
			
			var smallbmp:Bitmap = new Bitmap ( lowRes );
			smallbmp.width = smallbmp.height = 64;
			//debugLayer.addChild ( smallbmp );
		}
		
		private var destX:int;
		private var destY:int;
		private var pointsX:Vector.<int> = new Vector.<int>(10000, true); //TODO: check max numPoints and set to it.
		private var pointsY:Vector.<int> = new Vector.<int>(10000, true);
		private var pointsDone:Vector.<Boolean> = new Vector.<Boolean>(10000, true);
		private var pointsT:Vector.<Number> = new Vector.<Number>(10000, true);
		
		private var numPoints:int;
		private var maxTime:Number;
		
		private var targetX:int;
		private var targetY:int;
		
		private function drawCircle ( x:int, y:int, r:Number, c:int ):void
		{
			if ( !debugLayer ) return;
			debugLayer.graphics.lineStyle ( );
			debugLayer.graphics.beginFill ( c );
			debugLayer.graphics.drawCircle ( frLow(x), frLow(y), r );
			debugLayer.graphics.endFill ();
		}
		
		private function _makePath ( x:Number, y:Number, x2:int, y2:int ):Path
		{
			//*
			return makePath2 ( x2, y2, x, y );
			//makePath2 ( 121, 232, 309, 67 );
			
			
			/*/
			var t:int = getTimer ();
			for ( var i:int = 0; i < 1; i++ ) {
				//makePath2 ( 121, 232, 309, 67 );
				makePath2 ( x2, y2, x, y );
			}
			//trace ( numPoints);
			//return getTimer () - t;
			//*/
		}
		
		private var startX:int;
		private var startY:int;
		
		private function makePath2 ( x:Number, y:Number, x2:Number, y2:Number ):Path
		{
			var path:Array = [ {x:x2, y:y2} ];
			targetX = x;
			targetY = y;
			
			var i:int;
			if ( debugLayer ) debugLayer.graphics.clear ();
			//index = { };
			
			for ( i = 0; i < LOW_RES; i ++ ) {
				var indexVec:Vector.<int> = new Vector.<int>(LOW_RES, true)
				index[i] = indexVec;
			}
			
			x = toLow ( x );
			y = toLow ( y );
			pointsX[0] = x;
			pointsY[0] = y;
			pointsT[0] = 0;
			pointsDone[0] = false;
			addIndex ( x, y, 0 );
			numPoints = 1;
			
			
			
			destX = toLow ( x2 );
			maxTime = Number.MAX_VALUE;
			destY = toLow ( y2 );			
			
			var rightBorder:int = lowRes.width - 1;
			var botBorder:int = lowRes.height - 1;
			
			for ( i = 0; i < numPoints; i++ ) {
				if ( pointsDone[i] ) continue;
				pointsDone[i] = true;
				if ( minTime(destX, destY, pointsX[i], pointsY[i]) + pointsT[i] > maxTime ) continue;
				
				var left:int = Math.max ( 0, pointsX[i] - 1 );
				var right:int = Math.min ( rightBorder, pointsX[i] + 1 );
				var top:int = Math.max ( 0, pointsY[i] - 1 );
				var bot:int = Math.min ( botBorder, pointsY[i] + 1 );
				for ( x = left; x <= right; x++ ) {
					for ( y = top; y <= bot; y++ ) {
						if ( x != pointsX[i] || y != pointsY[i] ) processCell ( i, x, y );
					}
				}	
			}
			
			
			//create path
			x2 = destX;
			y2 = destY;
			var prevTime:Number = 0;
			var time:Number = Number.MAX_VALUE;
			
			while ( prevTime != time ) {
				prevTime = time;
				left = Math.max ( 0, x2 - 1 );
				right = Math.min ( rightBorder, x2 + 1 );
				top = Math.max ( 0, y2 - 1 );
				bot = Math.min ( botBorder, y2 + 1 );
				for ( x = left; x <= right; x++ ) {
					for ( y = top; y <= bot; y++ ) {
						var pos:int = getIndex ( x, y );
						if ( pointsT[pos] < time ) {
							x2 = pointsX[pos];
							y2 = pointsY[pos];
							time = pointsT[pos];
						}
					}
				}
				if ( x2 != toLow ( targetX ) || y2 != toLow ( targetY ) ) path.push ( { x:frLow(x2), y:frLow(y2) } );
			}
			
			path.push ( { x:targetX, y:targetY} );
			//smooth path 
			
			for ( i = 0; i < path.length; i++ ) {
				while ( i + 4 < path.length) {
					if ( !sees(path[i].x, path[i].y, path[i+4].x, path[i+4].y) ) break;
					path.splice ( i + 1, 3 );
				}
			}
			
			//repeat
			for ( i = 0; i < path.length; i++ ) {
				while ( i + 2 < path.length) {
					if ( !sees(path[i].x, path[i].y, path[i+2].x, path[i+2].y) ) break;
					path.splice ( i + 1, 1 );
				}
			}
			
			var _path2:Path = new Path ( path );
			
			//*
			var _path:Path = new Path ( path );
			
			for ( i = 0; i < _path.totalDistance; i += 3 ) {
				_path.travel ( 3 );
				debugLayer.graphics.beginFill ( 0xFF );
				debugLayer.graphics.drawCircle ( _path.x, _path.y, 1 );
				debugLayer.graphics.endFill ();
			}
			//*/
			
			return _path2;
		}
		
		private function sees ( x1:int, y1:int, x2:int, y2:int ):Boolean
		{
			/*
			x1 = frLow ( x1 );
			y1 = frLow ( y1 );
			x2 = frLow ( x2 );
			y2 = frLow ( y2 );
			*/
			
			var dx:int = x2 - x1;
			var dy:int = y2 - y1;
			
			var absDx:int = Math.abs ( dx );
			var absDy:int = Math.abs ( dy );
			
			if ( absDx > absDy ) var numSteps:int = absDx;
			else numSteps = absDy;
			
			var stepX:Number = dx / numSteps;
			var stepY:Number = dy / numSteps;
			
			var x:Number = x1;
			var y:Number = y1;
			var seeable:Boolean = true;
			for ( var i:int = 0; i < numSteps; i++ ) {
				x += stepX;
				y += stepY;
				if ( highResBdata.getPixel(Math.floor(x), Math.floor(y)) == 0 ) {
					seeable = false;
					break;
				}
				/*
				debugLayer.graphics.lineStyle ( );
				debugLayer.graphics.beginFill ( 0xFFFFFF );
				debugLayer.graphics.drawCircle ( Math.floor(x), Math.floor(y), 1 );
				debugLayer.graphics.endFill ();
				*/
			}
			
			return seeable;
		}
		
		private function processCell ( i:int, x:int, y:int ):void
		{
			//drawCircle ( x, y, 2, 0xFF0000 );
			if ( lowResGrid[x][y] < 200 ) return;
			var red:uint = lowResGrid[pointsX[i]][pointsY[i]];
			
			if ( pointsY[i] == y || pointsX[i] == x ) var diagonal:Boolean = false;
			else diagonal = true;
			
			var dt:Number = 256 - red;
			if ( diagonal ) dt *= Math.SQRT2;
			
			var t:Number = pointsT[i] + dt;
			if ( x == destX && y == destY ) {
				if ( maxTime > t ) maxTime = t;
				return;
			}
			
			var pos:int = getIndex ( x, y );
			if ( pointsT[pos] > t ) {
				pointsT[pos] = t;
				pointsDone[pos] = false;
			}
		}
		
		
		private function addIndex ( x:int, y:int, i:int ):void
		{ index[x][y] = i+1 }
			
		private function getIndex ( x:int, y:int ):int
		{ 
			if ( index[x][y] == 0 ) {
				pointsX[numPoints] = x;
				pointsY[numPoints] = y;
				pointsT[numPoints] = Number.MAX_VALUE;
				pointsDone[numPoints] = false;
				numPoints++
				index[x][y] = numPoints - 1 + 1;
			}
			return index[x][y] - 1;
		}
		
		private function minTime ( x1:int, y1:int, x2:int, y2:int ):Number
		{
			var dx:int = Math.max ( x1, x2 ) - Math.min ( x1, x2 );
			var dy:int = Math.max ( y1, y2 ) - Math.min ( y1, y2 );
			var bigger:int = Math.max ( dx, dy );
			var diagonal:int = Math.min ( dx, dy );
			var straight:int = bigger - diagonal;
			return straight + diagonal * Math.SQRT2;
		}
		
		private function toLow ( v:Number ):int
		{
			return Math.floor ( v * FROM_LOW_RES );
		}
		
		private function frLow ( v:int ):int
		{
			return v * TO_LOW_RES + TO_LOW_RES/2;
		}
		
		private function createGrids ( bdata:BitmapData ):void
		{
			var bmp:Bitmap = new Bitmap ( bdata );
			
			
			lowRes = new BitmapData ( LOW_RES, LOW_RES, false, 0 );
			var scaledown:Number = LOW_RES / bdata.width;
			var matrix:Matrix = new Matrix ();
			matrix.scale ( scaledown, scaledown );
			lowRes.draw ( bmp, matrix );
			
			//create vector of RED value for faster access
			for ( var i:int = 0; i < LOW_RES; i ++ ) {
				var vec:Vector.<uint> = new Vector.<uint>(LOW_RES, true);
				lowResGrid[i] = vec;
				for ( var j:int = 0; j < LOW_RES; j ++ ) {
					vec[j] = lowRes.getPixel ( i, j ) >> 16 ;
				}
			}
			
		}	
		
	}
}