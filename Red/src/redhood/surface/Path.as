package redhood.surface 
{
	/**
	 * ...
	 * @author Markus Smoliński
	 */
public class Path 
{
	private static const CURVED_PART:Number = .4;
	private var _path:Array = [];
	private var currentSegment:int = 0;
	private var _distanceTravelled:Number = 0;
	private var _totalDistance:Number = 0;
	
	private var currentX:Number = -1;
	private var currentY:Number = -1;
	
	public function get x ():Number { return currentX } 
	public function get y ():Number { return currentY }
	public function get totalDistance ():Number { return _totalDistance }
	public function get distanceTravelled():Number { return _distanceTravelled }
	
	public function travel ( distance:Number ):void
	{
		var x:Number = currentX;
		var y:Number = currentY;
		
		_distanceTravelled += distance;
		if ( _distanceTravelled >= _totalDistance ) {
			currentX = _path[_path.length - 1].x2;
			currentY = _path[_path.length - 1].y2;
			return;
		}
		while ( _path[currentSegment].end < _distanceTravelled ) {
			currentSegment++;
		}
		
		var o:Object = _path[currentSegment];
		var delta:Number = _distanceTravelled;
		if ( currentSegment ) delta -= _path[currentSegment - 1].end;
		
		delta /= o.len;
		if ( o.cx === undefined ) {
			//straight segment
			currentX = (1 - delta) * o.x1  +  delta * o.x2;
			currentY = (1 - delta) * o.y1  +  delta * o.y2;
		} else {
			
			//curved segment
			currentX = RedUtils.quadPoint ( o.x1, o.cx, o.x2, delta );
			currentY = RedUtils.quadPoint ( o.y1, o.cy, o.y2, delta );
		}
	}
	
	public function Path ( path:Array ) 
	{
		var dx:Number;
		var dy:Number;
		for ( var i:int = 1; i < path.length; i++ ) {
			var x1:Number = path[i - 1].x;
			var y1:Number = path[i - 1].y;
			

			
			var x2:Number = path[i].x;
			var y2:Number = path[i].y;
			if ( i>1 ) {
				dx = x2 - x1;
				dy = y2 - y1;
				x1 += dx * CURVED_PART;
				y1 += dy * CURVED_PART;
			}
			var cx:Number = x2;
			var cy:Number = y2;
			
			if ( i + 1 == path.length ) addStraightSegment ( x1, y1, x2, y2 );
			else {
				dx = x2 - x1;
				dy = y2 - y1;
				x2 -= dx * CURVED_PART;
				y2 -= dy * CURVED_PART;
				addStraightSegment ( x1, y1, x2, y2 );
				
				x1 = x2;
				y1 = y2;
				x2 = path[i + 1].x;
				y2 = path[i + 1].y;
				dx = x2 - cx;
				dy = y2 - cy;
				x2 = cx + dx * CURVED_PART;
				y2 = cy + dy * CURVED_PART;
				addCurveSegment ( x1, y1, cx, cy, x2, y2 );
			}
		}
	}
	
	private function addStraightSegment ( x1:Number, y1:Number, x2:Number, y2:Number ):void
	{
		var o:Object = { };
		var dx:Number = x1 - x2;
		var dy:Number = y1 - y2;
		o.len = Math.sqrt ( dx * dx + dy * dy );
		objectHelper ( o, x1, y1, x2, y2 );
	}
	
	private function addCurveSegment ( x1:Number, y1:Number, cx:Number, cy:Number, x2:Number, y2:Number ):void
	{
		var o:Object = { };
		o.cx = cx;
		o.cy = cy;
		o.len = RedUtils.quadLength ( x1, y1, cx, cy, x2, y2 );
		objectHelper ( o, x1, y1, x2, y2 );
	}
	
	private function objectHelper ( o:Object, x1:Number, y1:Number, x2:Number, y2:Number ):void
	{
		o.x1 = x1;
		o.y1 = y1;
		o.x2 = x2;
		o.y2 = y2;
		o.end = o.len;
		if ( _path.length ) o.end += _path[_path.length - 1].end;
		_totalDistance = o.end;
		_path.push ( o );
	}
	
	
}
}