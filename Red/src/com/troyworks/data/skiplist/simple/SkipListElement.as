package com.troyworks.data.skiplist.simple {

public class SkipListElement
{
	
	public function SkipListElement( key:Number, value:Object)
	{
	  this.key = key;
	  this.values = [value];
	}
	
	public var key:Number;
	public var values:Array;

	public var forward:Vector.<SkipListElement>;

	public var done:Boolean = false;
	private var lastObject:int = 0;

	public function insertObjects ( a:Array ):void
	{
		for ( var i:int = 0; i < a.length ; i++ ) {
			if ( values.indexOf(a[i]) == -1 ) values.push ( a[i] );
		}
		done = lastObject >= values.length;
	}

	public function getObject ():Object
	{
		var o:Object = values[lastObject];
		lastObject++;
		done = lastObject >= values.length;
		return o;
	}
	
	public function removeObject ( o:Object ):void
	{
		for ( var i:int = 0; i < values.length; i++ ) {
			if ( values[i] == o ) {
				if ( lastObject >= i ) lastObject --;
				values.splice ( i, 1 );
				done = lastObject >= values.length;
				return;
			}
		}
	}

}
}