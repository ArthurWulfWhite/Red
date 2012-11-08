package redhood
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import redhood.surface.WalkableSurface;
	
	public class Game extends Sprite 
	{
		private const RED:String = 'red';
		private const BUNNY:String = 'bunny';
		private const CARROT:String = 'carrot';
		private const GRANDMA:String = 'grandma';
		private const WOLF:String = 'wolf';
		
		private var objects:Object = { };
		
		private var currentLevel:int = -1;
		private var surface:Sprite = new Sprite ();
		private var walkableSurface:WalkableSurface;
		private var overlay:Sprite = new Sprite ();
		
		//stars
		private var red : Red = new Red();
		private var carrot : Carrot = new Carrot();
		private var bunny : Bunny = new Bunny();
		private var wolf : Wolf = new Wolf();
		private var grandma : Grandma = new Grandma();
		
		private var debugPoint:Sprite = new Sprite ();
		
		private var prevMouseX:int = -1;
		private var prevMouseY:int = -1;
		private var prevDestX:int = -1;
		private var prevDestY:int = -1;
		
		public function Game() 
		{
		}
		
		public function getCurrentLevel ():int { return currentLevel };
		
		public function init ():void
		{
			walkableSurface = new WalkableSurface ( true );
			
			debugPoint.graphics.beginFill ( 0xFF0000 );
			debugPoint.graphics.drawCircle ( 0, 0, 2 );
			debugPoint.graphics.endFill ();
			
			objects[RED] = red;
			objects[BUNNY] = bunny;
			objects[CARROT] = carrot;
			objects[GRANDMA] = grandma;
			objects[WOLF] = wolf;
			
			addChild ( surface );
			addChild ( walkableSurface );
			//addChild ( grandma );
			//addChild ( carrot );
			addChild ( red );
			//addChild ( bunny );
			//addChild ( wolf );
			addChild ( overlay );
			addChild ( debugPoint );
			
			stage.addEventListener ( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener ( Event.ENTER_FRAME, onEnterFrame );
			red.alpha = .4;
		}
		
		public function loadLevel ( lvlNum:int ):void
		{
			currentLevel = lvlNum;
			setCharacters ();
			walkableSurface.draw ( lvlNum );
			spawnForest ();
		}
		
		private function onKeyDown ( e:KeyboardEvent ):void
		{
			
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
					walkableSurface.debug ( walkableSurface.pathFinder.makePath ( red.x, red.y, debugPoint.x, debugPoint.y ) );
					prevDestX = debugPoint.x;
					prevDestY = debugPoint.y;
				}
			}
			
			//trace ( debugPoint.x, debugPoint.y );
			/*
			//I always move red//
			//I always check if she reached grandmas house//
			if (wolf.hitTestObject(red)) gameOver("You were eaten by a wolf");
			if (red.hitTestObject(grandma)) drawShalav(++currentLevel);
			//red's movement//
			red.speedMultiplier = 0.05 + 
				Math.max(0, (stage.stageWidth / 2 - distance(red.x, red.y, mouseX, mouseY))) / (stage.stageWidth/2);
			var angle : Number = Math.atan2(mouseY - red.y, mouseX - red.x);
			var stepX : int = BASE_SPEED * red.speedMultiplier * Math.cos(angle);
			var stepY : int = BASE_SPEED * red.speedMultiplier * Math.sin(angle);
			var move : Boolean = true;
			while (Math.abs(stepX) + Math.abs(stepY) > 0 && move && distance(red.x, red.y, mouseX, mouseY) > 2)
			{
				move = false;
				if (stepX)
				{
					if (hitTestPoint(red.x + sign(stepX) * red.size, red.y, true))
					{
						red.x += sign(stepX) * Math.min(Math.abs(stepX), 1);
						move = true;
						stepX -= sign(stepX) * Math.min(Math.abs(stepX), 1);
					}
				}
				if (stepY)
				{
					if (hitTestPoint(red.x, red.y  + sign(stepY) * red.size, true))
					{
						red.y += sign(stepY) * Math.min(Math.abs(stepY), 1);
						move = true;
						stepY -= sign(stepY) * Math.min(Math.abs(stepY), 1);
					}
				}				
			}
			//affected by the distance from the pointer//
			//affected by the time she is moving
			switch(gameState)
			{
				case START:
					if (wolf.way >= 0.99) wolf.way = -0.99;
					wolf.way += 0.004;
					wolf.walk();
					if (wolf.sees(red)) gameState = WOLF;
					if (red.hitTestObject(carrot))
					{
						gameState = BUNNY;
						removeChild(carrot);
						//play ding sound
					}
				break;
				
				case WOLF:
					if (wolf.way >= 0.99) wolf.way = -0.99;
					wolf.way += 0.004;
					chase(wolf, red);
					if (wolf.hitTestObject(bunny))
					{
						gameState = NONE;
						//slowly remove..
						removeChild(bunny);
					}
					if (red.hitTestObject(carrot))
					{
						gameState = BOTH;
						removeChild(carrot);
						//play ding sound
					}
				break;
				
				case BUNNY:
					//+move red
					wolf.way += 0.004;
					wolf.walk();
					if (wolf.sees(red)) gameState = BOTH;
					chase(bunny, red);
					if (bunny.hitTestObject(red)) gameOver("You were bitten by a rabid bunny");
					//carrot is not being checked
				break;
				
				case BOTH:
					//+move red
					chase(wolf, red);
					chase(bunny, red);
					if (bunny.hitTestObject(red)) gameOver("You were bitten by a rabid bunny");
					if (wolf.hitTestObject(bunny))
					{
						gameState = NONE;
						//slowly remove..
						removeChild(bunny);
					}
					//carrot not available
				break;
				
				case NONE:
					//+move red
					//check if red is touching wolf// ?? always
				break;
				
			}*/
		}
		
		private function setCharacters ():void
		{
			for (var name:String in objects ) 
			{
				var data:Array = String ( XMLLoader.xml.shalav[currentLevel][name] ).split ( "," );
				var sprite:Dmut = objects[name] as Dmut;
				sprite.x = Number( data[0] );
				sprite.y = Number( data[1] );
			}
		}
		
		private function spawnForest ():void
		{
			
		}
		
	}
}