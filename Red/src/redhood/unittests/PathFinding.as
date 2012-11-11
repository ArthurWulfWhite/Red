package redhood.unittests
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import redhood.surface.WalkableSurface;
	
	public class PathFinding extends Sprite 
	{	
		private const TESTED_LEVEL:int = 0;
		//*
		private var walkableSurface:WalkableSurface;
		/*/
		private var walkableSurface:WalkableSurfaceOld;
		//*/
		
		private var prevMouseX:int = -1;
		private var prevMouseY:int = -1;
		private var prevDestX:int = -1;
		private var prevDestY:int = -1;
		
		private var debugPoint:Sprite = new Sprite ();
		
		public function PathFinding() 
		{
			XMLLoader.init ();
			init ();
			loadLevel ( TESTED_LEVEL );
		}
		
		public function init ():void
		{
			walkableSurface = new WalkableSurface ( true );
			
			debugPoint.graphics.beginFill ( 0xFF0000 );
			debugPoint.graphics.drawCircle ( 0, 0, 2 );
			debugPoint.graphics.endFill ();
			
			addChild ( walkableSurface );
			addChild ( debugPoint );
			stage.addEventListener ( Event.ENTER_FRAME, onEnterFrame );
		}
		
		public function loadLevel ( lvlNum:int ):void
		{
			walkableSurface.draw ( lvlNum );
		}
		
		private function onEnterFrame ( e:Event ):void
		{
			if ( mouseX == prevMouseX && mouseY == prevMouseY ) return;
			prevMouseX = mouseX;
			prevMouseY = mouseY;
			
			walkableSurface.terrainSnapper.getClosestPoint ( mouseX, mouseY );
			if ( walkableSurface.terrainSnapper.distance < 1000 ) {
				debugPoint.x = walkableSurface.terrainSnapper.x;
				debugPoint.y = walkableSurface.terrainSnapper.y;
				if ( prevDestX != debugPoint.x || prevDestY != debugPoint.y ) {
					walkableSurface.pathFinder.makePath ( 121, 232, debugPoint.x, debugPoint.y );
					prevDestX = debugPoint.x;
					prevDestY = debugPoint.y;
				}
			}
		}
		
	}
}