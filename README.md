LambdaMacro
===========

Lambda with shorts using macros

Usage:

```
var a = ['a', 'b', 'c'];
var cnt = a.count(x => x == 'b');
var cnt = a.count(x => { trace(x); x != 'b'; } );
		
a.iter(trace('$_ in lambdamacro!'));
a.iter(trace(_));
```