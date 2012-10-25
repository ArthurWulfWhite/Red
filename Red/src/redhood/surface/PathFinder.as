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
	 * Path Finder class calculates the shortest path in lower resolution of a map and returns points on 16x16 px grid.
	 * This class is designed to work with project dimensions set to 512x512, although it seems it will work on other dimensions as well.
	 * @author Markus Smoliński
	 */
	public class PathFinder 
	{
		private const LOW_RES:int = 64;
		private const HIGH_RES:int = 128;
		
		private const SQRT2:Number = Math.SQRT2//+0.1;
		
		private var debugLayer:Sprite;
		
		private var highRes:BitmapData;
		private var lowRes:BitmapData;
		
		private var strengthenColor:ColorTransform = new ColorTransform ( 100, 100, 100 );
		
		/**
		 * Initialize anywhere.
		 * @param	debugLayer set it if you want to draw for debugging
		 */
		public function PathFinder ( debugLayer:Sprite ) 
		{
			this.debugLayer = debugLayer;
		}
		
		/**
		 * Prepares bitmapGrids
		 * @param	terrain a raster or vector object to draw on bitmapGrids
		 */
		public function init ( terrain:DisplayObject ):void
		{
			var bdata:BitmapData = new BitmapData ( terrain.stage.stageWidth, terrain.stage.stageHeight, false, 0 );
			bdata.draw ( terrain, null, strengthenColor );
			
			createGrids ( bdata );
		}
		
		public function drawDebug ():void
		{
			var bmp:Bitmap = new Bitmap ( lowRes );
			var bmp2:Bitmap = new Bitmap ( highRes );
			bmp2.width = bmp.width = debugLayer.stage.stageWidth;
			bmp2.height = bmp.height = debugLayer.stage.stageHeight;
			bmp2.alpha = bmp.alpha = .2;
			debugLayer.addChild ( bmp );
			debugLayer.addChild ( bmp2 );
			//*/
			
			var smallbmp:Bitmap = new Bitmap ( lowRes );
			var smallbmp2:Bitmap = new Bitmap ( highRes );
			smallbmp.width = smallbmp.height = smallbmp2.width = smallbmp2.height = 64;
			smallbmp2.x = 64;
			debugLayer.addChild ( smallbmp );
			debugLayer.addChild ( smallbmp2 );
		}
		
		private var destX:int;
		private var destY:int;
		private var pointsX:Vector.<int>;
		private var pointsY:Vector.<int>;
		private var pointsDone:Vector.<Boolean>;
		private var pointsT:Vector.<Number>;
		private var index:Object = { };
		private var maxTime:Number;
		
		private function drawCircle ( x:int, y:int, r:Number, c:int ):void
		{
			if ( !debugLayer ) return;
			debugLayer.graphics.beginFill ( c );
			debugLayer.graphics.drawCircle ( frLow(x), frLow(y), r );
			debugLayer.graphics.endFill ();
		}
		
		public function makePath ( x:int, y:int, x2:int, y2:int ):void
		{
			var i:int;
			if ( debugLayer ) {
				debugLayer.graphics.clear ();
			
				drawCircle ( toLow(x2), toLow(y2), 5, 0xFFFF00 );
				
				debugLayer.graphics.beginFill ( 0xFF );
				debugLayer.graphics.drawCircle ( frHigh(toHigh(x2)), frHigh(toHigh(y2)), 3.5 );
				debugLayer.graphics.endFill ();
			}
			
			pointsX = new Vector.<int>;
			pointsY = new Vector.<int>;
			pointsDone = new Vector.<Boolean>;
			pointsT = new Vector.<Number>;
			index = { };
			
			x = toLow ( x );
			y = toLow ( y );
			pointsX.push ( x );
			pointsY.push ( y );
			pointsT.push ( 0 );
			pointsDone.push ( false );
			addIndex ( x, y, 0 );
			
			destX = toLow ( x2 );
			destY = toLow ( y2 );
			maxTime = Number.MAX_VALUE;
			
			var rightBorder:int = lowRes.width - 1;
			var botBorder:int = lowRes.height - 1;
			do {
				var changed:Boolean = false;
				for ( i = 0; i < pointsX.length; i++ ) {
					if ( pointsDone[i] ) continue;
					pointsDone[i] = true;
					if ( minTime(destX, destY, pointsX[i], pointsY[i]) + pointsT[i] > maxTime ) continue;
					
					changed = true;
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
			} while ( changed );
			
			//go back
			var time:Number = 1000000000;
			x2 = destX;
			y2 = destY;
			while ( time > 0 ) {
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
				drawCircle ( x2, y2, 4, 0xFFFF00 );
			}
			/*
			for ( i = 0; i < pointsX.length; i ++ ) {
				var red:int = pointsT[i];
				if ( red > 255 ) {
					var green:int = red - 255;
					red = 255
					if ( green> 255 ) {
						var blue:int = green - 255
					} else blue = 0;
				} else green = 0;
				drawCircle ( pointsX[i], pointsY[i], 4, red << 16 | green << 8 | blue );
			}
			//*/
		}
		
		private function processCell ( i:int, x:int, y:int ):void
		{
			var red2:int = lowRes.getPixel ( x, y ) >> 16;
			if ( red2 < 200 ) return;
			var red:int = lowRes.getPixel ( pointsX[i], pointsY[i] ) >> 16;
			var dx:int = Math.abs ( pointsX[i] - x );
			var dy:int = Math.abs ( pointsY[i] - y );
			var diagonal:Boolean = dx + dy == 2; 
			
			var dt:Number = (256 - red) // 255;
			//dt = Math.pow ( dt, 5 );
			if ( diagonal ) dt *= SQRT2;
			var t:Number = pointsT[i] + dt;
			if ( x == destX && y == destY ) {
				if ( maxTime > t ) maxTime = t;
				return;
			}
			
			//if ( minTime(destX, destY, x, y) + t > maxTime ) return;
			
			var pos:int = getIndex ( x, y );
			if ( pointsT[pos] > t ) {
				pointsT[pos] = t;
				pointsDone[pos] = false;
			}
		}
		
		
		private function addIndex ( x:int, y:int, i:int ):void
		{ index[y * LOW_RES + x] = i }
			
		private function getIndex ( x:int, y:int ):int
		{ 
			var pos:int = y * LOW_RES + x;
			if ( index[pos] === undefined ) {
				pointsX.push ( x );
				pointsY.push ( y );
				pointsT.push ( Number.MAX_VALUE );
				pointsDone.push ( false );
				index[pos] = pointsX.length - 1;
			}
			return index[pos];
		}
		
		private function minTime ( x1:int, y1:int, x2:int, y2:int ):Number
		{
			var dx:int = Math.max ( x1, x2 ) - Math.min ( x1, x2 );
			var dy:int = Math.max ( y1, y2 ) - Math.min ( y1, y2 );
			var bigger:int = Math.max ( dx, dy );
			var diagonal:int = Math.min ( dx, dy );
			var straight:int = bigger - diagonal;
			//trace ( dx, dy, bigger, diagonal, straight );
			return straight + diagonal * SQRT2;
		}
		
		private function toLow ( v:int ):int
		{
			var multiplier:Number = LOW_RES / 512;
			return Math.floor ( v * multiplier );
		}
		
		private function frLow ( v:int ):int
		{
			var multiplier:Number = 512 / LOW_RES;
			return v * multiplier + multiplier/2;
		}
		
		private function toHigh ( v:int ):int
		{
			var multiplier:Number = HIGH_RES / 512;
			return Math.floor ( v * multiplier );
		}
		
		private function frHigh ( v:int ):int
		{
			var multiplier:Number = 512 / HIGH_RES;
			return v * multiplier + multiplier/2;
		}
		
		private function createGrids ( bdata:BitmapData ):void
		{
			var bmp:Bitmap = new Bitmap ( bdata );
			
			lowRes = new BitmapData ( LOW_RES, LOW_RES, false, 0 );
			var scaledown:Number = LOW_RES / bdata.width;
			var matrix:Matrix = new Matrix ();
			matrix.scale ( scaledown, scaledown );
			lowRes.draw ( bmp, matrix );
			
			highRes = new BitmapData ( HIGH_RES, HIGH_RES, false, 0 );
			scaledown = HIGH_RES / bdata.width;
			matrix = new Matrix ();
			matrix.scale ( scaledown, scaledown );
			highRes.draw ( bmp, matrix );
		}	
		
	}
}