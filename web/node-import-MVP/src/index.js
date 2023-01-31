import { add, multiply, subtract, divide } from "#module/operations"
import euler from 'eulejs';

const diagram = euler({
  a: [1, 2, 3],
  b: [2, 3, 4],
  c: [3, 4, 5],
  d: [3, 5, 6],
});

/* Euler dictionary:
 *	 {
 *		'a,b': [2],
 * 		'b,c': [4],
 * 		'a,b,c,d': [3],
 *		'c,d': [5],
 *		'd': [6],
 *		'a': [1]
 *	 }
 */
console.log(diagram);

const a = 3;
const b = 4;

console.log("     add(a, b): "+add(a, b))
console.log("multiply(a, b): "+multiply(a, b))
console.log("subtract(a, b): "+subtract(a, b))
console.log("  divide(a, b): "+divide(a, b))
