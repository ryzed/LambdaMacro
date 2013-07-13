package ;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import ryz.utils.LambdaMacro;

/**
 * ...
 * @author ryz
 */

using ryz.utils.LambdaMacro;
 
class LambdaMacroTest
{
	var tf:TextField;
	var list:Array<Int>;
	var useCommon:Bool = true;
	
	public function new()
	{
		var stage = Lib.current.stage;
		
		list = new Array<Int>();
		for (n in 0...1024)
		{
			list.push(n);
		}
		
		{
			var tf = new TextField();
			tf.x = 300;
			tf.text = 'press any key to switch lambdas';
			tf.textColor = 0xffffff;
			tf.autoSize = TextFieldAutoSize.LEFT;
			stage.addChild(tf);
		}
		
		
		tf = new TextField();
		tf.x = 300;
		tf.y = 32;
		tf.textColor = 0xff0000;
		tf.autoSize = TextFieldAutoSize.LEFT;
		stage.addChild(tf);
		
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
	}
	
	function onKey(e:KeyboardEvent):Void
	{
		useCommon = !useCommon;
	}
	
	function onFrame(e:Event):Void
	{
		if (useCommon)
		{
			onFrameCommon();
		}
		else
		{
			onFrameMacro();
		}
	}
	
	function onFrameCommon()
	{
		var t = Lib.getTimer();
		for (n in 0...1024)
		{
			var sum1 = 0;
			Lambda.iter(list, function(x) sum1 += x);
		}
		var t = Lib.getTimer() - t;
		tf.text = 'common Lambda time in ms = $t';
	}
	function onFrameMacro()
	{
		var t = Lib.getTimer();
		for (n in 0...1024)
		{
			var sum1 = 0;
			LambdaMacro.iter(list, x => sum1 += x);
		}
		var t = Lib.getTimer() - t;
		tf.text = 'LambdaMacro time in ms = $t';
	}
	
	
	static function main() 
	{
		var t = ['qwe'];
		var tt = ['asd'];
		
		
		trace('concat:');
		var t = LambdaMacro.concat(t, tt);
		trace(t);
		t.iter(x => trace(x));
		
		var t = t.array();
		
		var a = ['a', 'b', 'c'];
		
		trace('foreach:');
		trace(a.foreach(_ != 'qwe'));
		trace(a.foreach(_ == 'qwe'));
		
		trace('map:');
		var b = LambdaMacro.map(a, _ + 'from map');
		trace(b);
		
		trace('mapi:');
		var b = a.mapi([i, v] => 'in mapi val=$v at idx=$i');
		trace(b);
		var b = a.mapi(i => 'in mapi with single val=$_ at idx=$i');
		trace(b);
		var b = a.mapi([i] => 'in mapi with arr1 val=$_ at idx=$i');
		trace(b);
		
		
		trace('exists:');
		trace(a.exists(x => x == 'b'));
		
		trace('has:');
		trace(a.has('qwe'));
		
		trace('count:');
		var cnt = a.count(x => x == 'b');
		trace(cnt);
		
		var cnt = a.count(x => { trace('from cnt $x'); x != 'b'; } );
		trace(cnt);
		
		trace('iter:');
		a.iter(x => trace(x));
		
		trace('filter:');
		trace(LambdaMacro.filter(a, _ != 'b'));
		
		trace('countany:');
		trace(a.countAny());
		
		trace('empty:');
		trace(a.empty());
		trace([].empty());
		
		trace('index of:');
		trace(a.indexOf('qwe'));
		trace(a.indexOf('a'));
		trace(a.indexOf('b'));
		trace(a.indexOf('c'));
		
		
		trace('multi iter:');
		var a = ['a', 'b', 'c'];
		var b = ['1', '2', '3', '4'];
		var c = [a, b];
		
		c.iter(x =>
			x.iter(y => 
				trace('value $y from $x')));
		
		c.iter(x => { var cnt = x.countAny(); trace('countAny in $x = $cnt'); } );

		trace('total cnt:');
		var totalCnt = 0;
		c.iter(x => { totalCnt += x.countAny(); } );
		trace(totalCnt);
		
		trace('total cnt with x=> x=>:');
		var totalCnt = 0;
		c.iter(x => { totalCnt += x.count(x => x != '2'); } );
		trace(totalCnt);
		
		trace('total cnt with x=> y=>:');
		var totalCnt = 0;
		c.iter(x => { totalCnt += x.count(y => y != '2'); } );
		trace(totalCnt);

		trace('multi join x=>y:');
		var s = 'multi join = ';
		c.iter(x => x.iter(y => s += y) );
		trace(s);
		
		trace('multi join x=>x:');
		var s = 'multi join = ';
		c.iter(x => x.iter(x => s += x) );
		trace(s);

		
		new LambdaMacroTest();
	}

}