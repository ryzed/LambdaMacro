LambdaMacro
===========

Lambda with shorts using macros

Based on hxshort ideas by Simn.
Main difference - lambda inlined into code, for speed reasons.

fold not implemented.

Best used through 'using ryz.utils.LambdaMacro' syntax, except map, concat and filter for arrays.


Speed difference up to 20 times with no side effects.
Check LambdaMacroTest.hx or online at 



Short syntax:
===========
```
arg => body
[arg] => body
[arg1, arg2] => body
```

Underscores:
===========
```
iter(body) same as iter(_ => body)
mapi(body) same as mapi([_, __] => body)
mapi(x => body) same as mapi([x, _] => body)
mapi([x] => body) same as mapi([x, _] => body)
```

Exampe usage:
===========
```
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
```