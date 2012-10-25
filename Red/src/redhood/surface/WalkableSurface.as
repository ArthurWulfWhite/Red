package redhood.surface
{
	import flash.display.Sprite;
	import XMLLoader;
	
	import redhood.surface.TerrainSnapper;
	import redhood.surface.PathFinder;
	
	public class WalkableSurface extends Sprite
	{
		private var terrainSnapper:TerrainSnapper;
		private var pathFinder:PathFinder;
		
		private var grass : Grass = new Grass();
		
		private var debugLayer:Sprite;		
		private var cache:Object;
		
		public function WalkableSurface( debug:Boolean = false ) 
		{
			if ( debug ) debugLayer = new Sprite ();
			terrainSnapper = new TerrainSnapper ( debugLayer );
			pathFinder = new PathFinder ( debugLayer );
		}
		
		public function draw ( lvlNum:int ):void
		{
			while ( numChildren ) removeChildAt ( 0 );
			graphics.clear();
			graphics.lineStyle(24, 0x8800);
			graphics.lineBitmapStyle(grass);
			drawAreas ( lvlNum );
			drawPaths ( lvlNum );
			
			if ( debugLayer ) addChild ( debugLayer );
			terrainSnapper.init ( this );
			pathFinder.init ( this );
			if ( debugLayer ) {
				terrainSnapper.drawDebug ();
				pathFinder.drawDebug ();
			}
			cache = { };
		}
		
		public function makePath ( x:int, y:int, x2:int, y2:int ):void
		{
			pathFinder.makePath ( x, y, x2, y2 );
		}
		
		/**
		 * Find the closest point to mouse position
		 */
		public function getClosestPoint ():Vector.<int>
		{
			if ( !cache[mouseX] ) cache[mouseX] = { };
			var p:Object = cache[mouseX][mouseY];
			if ( p ) return new <int>[p.x, p.y, p.x * p.x + p.y * p.y];
			
			var vector:Vector.<int> = terrainSnapper.getClosestPoint ( mouseX, mouseY );
			//not caching when mouse is over terrain, as it's not expensive to compute that:
			if ( vector[2] ) cache[mouseX][mouseY] = { x: vector[0], y: vector[1] };
			return vector;
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