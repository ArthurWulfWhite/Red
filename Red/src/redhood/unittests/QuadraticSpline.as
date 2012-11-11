package redhood.unittests 
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Etherlord
	 */
	public class QuadraticSpline extends Sprite 
	{
		
		public function QuadraticSpline() 
		{
			graphics.lineStyle ( 3, 0xFF0000 );
			graphics.moveTo ( 410, 0 );
			graphics.lineTo ( 410, 500 );
			
			graphics.lineStyle ( 3, 0xFFFFFF );
			graphics.moveTo ( 10, 10 );
			graphics.curveTo ( 410, 210, 10, 410 );
			
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(2, 0xAAAA00 );
			line.graphics.moveTo( 10, 10 );
			 
			// store values where to lineTo
			var posx:Number;
			var posy:Number;
			var anchor1:Point = new Point ( 10, 10 );
			var anchor2:Point = new Point ( 10, 410 );
			var control1:Point = new Point ( 410, 210 );
			 
			//loop through 100 steps of the curve
			for (var u:Number = 0; u <= 1; u += 1/20) {
				posx = RedUtils.quadPoint ( anchor1.x, control1.x, anchor2.x, u );
				posy = RedUtils.quadPoint ( anchor1.y, control1.y, anchor2.y, u );
				
				graphics.beginFill ( 0xFF );
				graphics.drawCircle ( posx, posy, 4 );
				graphics.endFill ();
				
				//line.graphics.lineTo(posx,posy);
			 
			}
			 
			//Let the curve end on the second anchorPoint
			 
			line.graphics.lineTo(anchor2.x,anchor2.y);
			 
			addChild(line);
			var t:int = getTimer ();
			for ( var i:int = 1; i < 100000; i++ ) {
				anchor1.x = i / 1000;
				RedUtils.quadLength ( anchor1.x, anchor1.y, control1.x, control1.y, anchor2.x, anchor2.y );
			}
			trace ( "Time taken for 100000 calculations of quadratic spline length:", getTimer() - t, "ms" ); // 31 ms for me
			
		}
		
		
		

		
	}

}