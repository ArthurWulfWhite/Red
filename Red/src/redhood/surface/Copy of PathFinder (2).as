package redhood.surface 
{
	import com.troyworks.data.skiplist.simple.SkipListElement;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	//import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	import com.troyworks.data.skiplist.simple.SkipList;
	
	/**
	 * Path Finder class calculates the shortest path in lower resolution of a map and returns points on 16x16 px grid.
	 * This class is designed to work with project dimensions set to 512x512, although it seems it will work on other dimensions as well.
	 * @author Markus Smoliński
	 */
	public class PathFinder 
	{
		private var Maze:Class;
		
		private const LOW_RES:int = 128;
		
		private const SQRT2:Number = Math.SQRT2//+0.1;
		
		private var debugLayer:Sprite;
		
		private var highRes:BitmapData;
		private var lowRes:BitmapData;
		
		private var lowResGrid:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(LOW_RES, true);
		
		private var skipList:SkipList;
		
		private var strengthenColor:ColorTransform = new ColorTransform ( 100, 100, 100 );
		
		private const PREDICTION_PENALTY:Number = 1.1;
		
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
		private var pointsX:Vector.<int> = new Vector.<int>(10000, true); //TODO: check max numPoints and set to it.
		private var pointsY:Vector.<int> = new Vector.<int>(10000, true);
		private var pointsDone:Vector.<Boolean> = new Vector.<Boolean>(10000, true);
		private var pointsT:Vector.<Number> = new Vector.<Number>(10000, true);
		private var index:Object;
		private var numPoints:int;
		private var maxTime:Number;
		
		private function drawCircle ( x:int, y:int, r:Number, c:int ):void
		{
			if ( !debugLayer ) return;
			debugLayer.graphics.beginFill ( c, .2 );
			debugLayer.graphics.drawCircle ( frLow(x), frLow(y), r );
			debugLayer.graphics.endFill ();
		}
		
		public function makePath ( x:int, y:int, x2:int, y2:int ):int
		{
			/*
			makePath2 ( x, y, x2, y2 );
			//makePath2 ( 121, 232, 309, 67 );
			trace ( numPoints );
			return 0;
			
			/*/
			var t:int = getTimer ();
			for ( var i:int = 0; i < 1; i++ ) {
				//makePath2 ( 121, 232, 242, 74 );
				makePath2 ( x, y, x2, y2 );
				//trace ( x, y, x2, y2 );
			}
			trace ( getTimer () - t );
			return getTimer () - t;
			//*/
		}
		
		private var searching:Boolean = false;
		
		public function makePath2 ( x:int, y:int, x2:int, y2:int ):void
		{
			var i:int;
			if ( debugLayer ) {
				debugLayer.graphics.clear ();
			
				drawCircle ( toLow(x2), toLow(y2), 5, 0xFFFF00 );
			}
			
			index = { };
			
			x = toLow ( x );
			y = toLow ( y );
			destX = toLow ( x2 );
			destY = toLow ( y2 );
			
			//addIndex ( x, y, 0 );
			numPoints = 1;
			
			skipList = new SkipList ();
			skipList.initWithProbability ( 0.25, 10);
			
			var o:Object = { };
			o.x = x;
			o.y = y;
			o.t = 0.0;
			o.done = false;
			var skipListElement:SkipListElement = new SkipListElement ( minTime(destX, destY, o.x, o.y) * PREDICTION_PENALTY, o ); 
			skipList.insert ( skipListElement );
			addO ( o );
			
			var rightBorder:int = lowRes.width - 1;
			var botBorder:int = lowRes.height - 1;
			
			searching = true;
			var counter:int = 0;
			for ( i = 0; i < 1000; i ++ ) {
				skipListElement = skipList.myHeader;
				counter = 0;
				do {
					skipListElement = skipListElement.forward[0];
					counter ++;
					//trace ( i, counter++ );
				} while ( skipListElement.done );
				//if ( counter ) trace ( skipListElement.key );
				if ( skipListElement.key == SkipList.NIL_KEY ) {
					//trace ( "END" );
					return; //NOT FOUND!
				}
				o = skipListElement.getObject ();
				//if ( o.x == 31 && o.y == 23 ) trace (skipListElement.values.length);
				//trace ( i, o.x, o.y, skipListElement.key );
				
				drawCircle ( o.x, o.y, 3, 0xFF0000 );
				var left:int = Math.max ( 0, o.x - 1 );
				var right:int = Math.min ( rightBorder, o.x + 1 );
				var top:int = Math.max ( 0, o.y - 1 );
				var bot:int = Math.min ( botBorder, o.y + 1 );
				for ( x = left; x <= right; x++ ) {
					for ( y = top; y <= bot; y++ ) {
						//if ( x == 26 ) trace ( x, y );
						if ( x != o.x || y != o.y ) processCell ( o, x, y );
					}
				}
				o.done = true;
				skipListElement.removeObject ( o );
				//if ( !skipListElement.values.length ) skipList.remove ( skipListElement.key );
				if ( !searching ) break;
			}
			/*
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
						o = getO ( x, y );
						if ( o.t < time ) {
							x2 = o.x;
							y2 = o.y;
							time = o.t;
						}
					}
				}
				drawCircle ( x2, y2, 4, 0x555500 );
			}
			//*/
		}
		
		private function processCell ( o:Object, x:int, y:int ):void
		{
			if ( x == destX && y == destY ) {
				searching = false;
				//trace ( "FINISH", x, y );
				return; //FINISH!
			}
			
			
			var red2:int = lowResGrid[x][y] >> 16;
			if ( red2 < 200 ) return;
			
			var red:int = lowResGrid[o.x][o.y] >> 16;
			//var dx:int = Math.abs ( o.x - x );
			//var dy:int = Math.abs ( o.y - y );
			//var diagonal:Boolean = dx + dy == 2; 
			
			if ( o.y == y || o.x == x ) var diagonal:Boolean = false;
			else diagonal = true;
			
			var dt:Number = 1;// (256 - red);
			if ( diagonal ) dt *= SQRT2;
			var t:Number = o.t + dt;
			
			var o2:Object = getO ( x, y );
			if ( !o2 ) {
				o2 = { };
				o2.x = x;
				o2.y = y;
				o2.done = false; //remove "done"
				o2.t = t;
				addO ( o2 );
			} else if ( o2.t > t ) {
				o2.t = t;
				o2.done = false;
			}
			
			
			if ( !o2.done ) {
				var priority:Number =  minTime ( destX, destY, x, y ) * PREDICTION_PENALTY;
				var skipListElement:SkipListElement = new SkipListElement ( priority, o2 );
				skipList.insert ( skipListElement );
			}
			/*trace ( o.element );
			if ( o.element ) {
				skipListElement.removeObject ( o );
				if ( !skipListElement.values.length ) skipList.remove ( skipListElement.key );
			}*/
			//o.element = skipListElement;
		}
		
		
		private function addO ( o:Object ):void
		{ index[o.y * LOW_RES + o.x] = o }
			
		private function getO ( x:int, y:int ):Object
		{ return index[y * LOW_RES + x] }
		
		private function minTime ( x1:int, y1:int, x2:int, y2:int ):Number
		{
			var dx:int = Math.max ( x1, x2 ) - Math.min ( x1, x2 );
			var dy:int = Math.max ( y1, y2 ) - Math.min ( y1, y2 );
			var bigger:int = Math.max ( dx, dy );
			var diagonal:int = Math.min ( dx, dy );
			var straight:int = bigger - diagonal;
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
		
		private function createGrids ( bdata:BitmapData ):void
		{
			var bmp:Bitmap = new Bitmap ( bdata );
			
			lowRes = new BitmapData ( LOW_RES, LOW_RES, false, 0 );
			var scaledown:Number = LOW_RES / bdata.width;
			var matrix:Matrix = new Matrix ();
			matrix.scale ( scaledown, scaledown );
			lowRes.draw ( bmp, matrix );
			
			//create vector for faster access
			for ( var i:int = 0; i < LOW_RES; i ++ ) {
				var vec:Vector.<uint> = new Vector.<uint>(LOW_RES, true);
				lowResGrid[i] = vec;
				for ( var j:int = 0; j < LOW_RES; j ++ ) {
					vec[j] = lowRes.getPixel ( i, j );
				}
			}
			
		}	
		
	}
}