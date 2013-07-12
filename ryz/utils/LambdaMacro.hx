package ryz.utils;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

/**
 * ...
 * @author ryz
 */

using haxe.macro.Context;
 
class LambdaMacro
{
	
	macro public static function array(a:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var ret = macro
		{
			var r = new Array<$outType>();
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				r.push(it.next());
			}
			r;
		}
		
		return ret;
	}
	macro public static function list(a:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var ret = macro
		{
			var r = new List<$outType>();
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				r.add(it.next());
			}
			r;
		}
		
		return ret;
	}
	
	
	
	static function arrowDecompose(f:Expr)
	{
		// need find left and right values in f
		// left - ident
		// right - expr
		
		var lVal:Expr = null;
		var rVal:Expr = null;
		
		switch(f.expr)
		{
			case EBinop(OpArrow, e1, e2):
			{
				lVal = e1;
				rVal = e2;
			}
			default: rVal = f;
		}
		
		return { L:lVal, R:rVal };
	}
	static function leftName(lVal:Expr)
	{
		return leftNames(lVal)[0];
	}
	static function leftNames(lvalue:Expr, minCnt:Int = 1)
	{
		var names:Array<String> = null;
		if (lvalue != null)
		{
			names = switch(lvalue.expr)
			{
				case EConst(CIdent(s)): [s];
				case EArrayDecl(els): els.map(function(e)
					return switch(e.expr)
					{
						case EConst(CIdent(s)): s; 
						default: '_';
					});
				case _: [];
			}
		}
		if (names == null)
		{
			names = [];
		}
		
		var t = '';
		while (names.length < minCnt)
		{
			names.push(t += '_');
		}
		return names;
	}

	macro public static function count(a:Expr, pred:Expr):Expr
	{
		var fDec = arrowDecompose(pred);
		
		var lName = leftName(fDec.L);
		var rVal = fDec.R;
		
		return macro
		{
			var n = 0;
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				var $lName = it.next();
				if ($rVal)
				{
					n++;
				}
			}
			n;
		}
	}

	
	
	macro public static function map(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		
		var lName = leftName(fDec.L);
		
		var rVal = fDec.R;
		var tmp = macro
		{
			var $lName = $a.iterator().next();
			var bVal = $rVal;
			bVal;
		}
		var outType = tmp.typeof().toComplexType();
		
		
		var ret = macro
		{
			var r = new List<$outType>();
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				var $lName = it.next();
				r.add($rVal);
			}
			r;
		}
		
		return ret;
	}
	

	
	macro public static function mapi(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		
		var lNames = leftNames(fDec.L, 2);
		var lNameIndex = lNames[0];
		var lNameValue = lNames[1];
		
		var rVal = fDec.R;
		var tmp = macro
		{
			var $lNameValue = $a.iterator().next();
			var $lNameIndex = 0;
			var bVal = $rVal;
			bVal;
		}
		var outType = tmp.typeof().toComplexType();
		
		
		var ret = macro
		{
			var r = new List<$outType>();
			var it = $a.iterator();
			var n = 0;
			while ( it.hasNext() )
			{
				var $lNameIndex = n++;
				var $lNameValue = it.next();
				r.add($rVal);
			}
			r;
		}
		
		return ret;
	}
	
	
	
	macro public static function has(a:Expr, b:Expr):Expr
	{
		return macro
			{
				var answer = false;
				var it = $a.iterator(); 
				while ( it.hasNext() )
				{
					var elem = it.next();
					if (elem == $b)
					{
						answer = true;
						break;
					}
				}
				answer;
			}
	}

	macro public static function exists(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		return macro
			{
				var answer = false;
				var it = $a.iterator(); 
				while ( it.hasNext() )
				{
					var $lName = it.next();
					if ($rVal)
					{
						answer = true;
						break;
					}
				}
				answer;
			}
	}
	
	
	
	macro public static function foreach(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		return macro
			{
				var answer = true;
				var it = $a.iterator(); 
				while ( it.hasNext() )
				{
					var $lName = it.next();
					if (!$rVal)
					{
						answer = false;
						break;
					}
				}
				answer;
			}
	}

	
	macro public static function iter(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		return macro
			{
				var it = $a.iterator(); 
				while ( it.hasNext() )
				{
					var $lName = it.next();
					$rVal;
				}
			}
	}
	
	
	macro public static function filter(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		
		var lName = leftName(fDec.L);
		var rVal = fDec.R;
		
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var ret = macro
		{
			var r = new List<$outType>();
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				var tmpElem = it.next();
				var $lName = tmpElem;
				if ($rVal)
				{
					r.add(tmpElem);
				}
			}
			r;
		}
		
		return ret;
	}
	
	
	
	
	
	macro public static function countAny(a:Expr):Expr
	{
		return macro
		{
			var n = 0;
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				it.next();
				n++;
			}
			n;
		}
	}

	
	
	macro public static function empty(a:Expr):Expr
	{
		return macro !$a.iterator().hasNext();
	}
	
	
	
	macro public static function indexOf(a:Expr, b:Expr):Expr
	{
		return macro
			{
				var answer = -1;
				
				var n = 0;
				var it = $a.iterator(); 
				while ( it.hasNext() )
				{
					var elem = it.next();
					if (elem == $b)
					{
						answer = n;
						break;
					}
					n++;
				}
				answer;
			}
	}
	
	
	
	macro public static function concat(a:Expr, b:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var ret = macro
		{
			var r = new List<$outType>();
			var it = $a.iterator(); 
			while ( it.hasNext() )
			{
				r.add(it.next());
			}
			var it = $b.iterator(); 
			while ( it.hasNext() )
			{
				r.add(it.next());
			}
			r;
		}
		
		return ret;
	}

}