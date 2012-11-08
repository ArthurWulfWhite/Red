package redhood 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class DebugSmoothness extends Sprite 
	{
		private var tester:Shape = new Shape ();
		
		public function DebugSmoothness() 
		{
			tester.x = 200;
			tester.y = 30;
			
			tester.graphics.beginFill ( 0xcccccc );
			tester.graphics.moveTo ( -5, -10 );
			tester.graphics.lineTo ( 5, -10 );
			tester.graphics.lineTo ( -5, 10 );
			tester.graphics.lineTo ( 5, 10 );
			tester.graphics.lineTo ( -5, -10 );
			tester.graphics.endFill ();
			
			addChild ( tester );
			
			addEventListener ( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame ( e:Event ):void
		{
			tester.rotation +=2;
		}
		
	}

}