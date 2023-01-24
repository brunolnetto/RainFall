import {
  assert,
  batchAssert,
  atest,
  batchAtest,
  buildAssertion,
  buildScenario,
  sketch,
} from "jestus";

import { add, multiply, subtract, divide } from "../operations";

let setup, prepare, exercise, teardown;

const expectToBe = (result, expectation) => expect(result).toBe(expectation);
const expectToThrow = (result) => expect(result).toThrow();

const emptyCallback = () => {};
const identityCallback = (fixture_) => fixture_;

/*************************** 
 * Addition cases  
 ***************************/

/*------------------------- 
 | assert design 
 *-------------------------*/
export let addTestCases;
let addItem, addItems;

addItem = [ add(1, 2), 3, expectToBe ];
addItems = [ [add(1, 2), 3, expectToBe], [add(2, 3), 5, expectToBe] ];

/*------------------------- 
 | atest design 
 *-------------------------*/
export let additionFixture = { "a": 1, "b": 2 };
export let additionScenario;

const addCallback = (fixture_) => add(fixture_.a, fixture_.b);
let expectedAddResult = 3;

setup = emptyCallback;
prepare = identityCallback;
exercise = (resources) => buildAssertion(
  addCallback(resources), 
  expectedAddResult, 
  expectToBe
);
teardown = emptyCallback;

additionScenario = buildScenario(setup, prepare, exercise, teardown);

addTestCases = [
  [
    "must sum numbers using assert", 
    () => assert(addItem)
  ],
  [
    "must sum numbers using batchAssert", 
    () => batchAssert(addItems)
  ],
  [
    "must sum numbers using atest", 
    () => atest(additionFixture, additionScenario)
  ],
  [
    "must sum numbers using batchAtest", 
    () => batchAtest(
      [additionFixture, additionFixture], [additionScenario, additionScenario]
    )
  ]
];

/*************************** 
 * Multiplication cases 
 ***************************/

/*------------------------- 
 | assert design 
 *-------------------------*/
export let multiplyTestCases;
let multiplyItem, multiplyItems;

multiplyItem = [ multiply(1, 2), 2, expectToBe ];
multiplyItems = [ [multiply(1, 2), 2, expectToBe], [multiply(2, 3), 6, expectToBe] ];

/*------------------------- 
 | atest design 
 *-------------------------*/
export let multiplicationFixture = { "a": 2, "b": 1 };
export let multiplicationScenario;

const multiplyCallback = (fixture_) => multiply(fixture_.a, fixture_.b);
let expectedMultiplicationResult = 2;

setup = emptyCallback;
prepare = identityCallback;
exercise = (resources) => buildAssertion(
  multiplyCallback(resources), expectedMultiplicationResult, expectToBe
);
teardown = emptyCallback;

multiplicationScenario = buildScenario(setup, prepare, exercise, teardown);

multiplyTestCases = [
  [
    "should multiply numbers using assert", 
    () => assert(multiplyItem)
  ],
  [
    "must multiply numbers using batchAssert",
    () => batchAssert(multiplyItems),
  ],
  [
    "must multiply numbers using atest", 
    () => atest(multiplicationFixture, multiplicationScenario)
  ],
  [
    "must multiply numbers using batchAtest", 
    () => batchAtest(
      [ multiplicationFixture, multiplicationFixture ], 
      [ multiplicationScenario, multiplicationScenario ]
    )
  ]
];

/*************************** 
 * Subtraction cases  
 ***************************/

/*------------------------- 
 | assert design 
 *-------------------------*/
export let subtractTestCases;
let subtractionItem, subtractionItems;

subtractionItem = [ subtract(2, 1), 1, expectToBe ];
subtractionItems = [ [subtract(2, 1), 1, expectToBe], [subtract(3, 2), 1, expectToBe] ];

/*------------------------- 
 | atest design 
 *-------------------------*/
export let subtractionFixture = { "a": 2, "b": 1 };
export let subtractionScenario;

const subtractCallback = (fixture_) => subtract(fixture_.a, fixture_.b);
let expectedSubtractionResult = 1;

setup = emptyCallback;
prepare = identityCallback;
exercise = (resources) => buildAssertion(
  subtractCallback(resources), 
  expectedSubtractionResult, 
  expectToBe
);
teardown = emptyCallback;

subtractionScenario = buildScenario(setup, prepare, exercise, teardown);

subtractTestCases = [
  [
    "should subtract numbers using assert", 
    () => assert(subtractionItem)
  ],
  [
    "should subtract numbers using batchAssert",
    () => batchAssert(subtractionItems),
  ],
  [
    "must subtract numbers using atest", 
    () => atest(multiplicationFixture, multiplicationScenario)
  ],
  [
    "must subtract numbers using batchAtest", 
    () => batchAtest(
      [ subtractionFixture, subtractionFixture ], 
      [ subtractionScenario, subtractionScenario ]
    )
  ]
];

/*************************** 
 * Division cases  
 ***************************/

/*------------------------- 
 | assert design 
 *-------------------------*/
export let divisionTestCases;
let divisionItem, divisionItems, invalidDivisionItem;

divisionItem = [ divide(42, 2), 21, expectToBe ];
divisionItems = [ [divide(2, 1), 2, expectToBe ], [divide(3, 2), 1.5, expectToBe ] ];
invalidDivisionItem = [() => divide(42, 0), expectToThrow];

/*------------------------- 
 | atest design 
 *-------------------------*/
export let divisionFixture = { "a": 42, "b": 1 };
export let divisionScenario;

const divisionCallback = (fixture_) => divide(fixture_.a, fixture_.b);
let expectedDivisionResult = 21;

setup = emptyCallback;
prepare = identityCallback;
exercise = (resources) => buildAssertion(
  divisionCallback(resources), expectedDivisionResult, expectToBe
);
teardown = emptyCallback;

divisionScenario = buildScenario(setup, prepare, exercise, teardown);

divisionTestCases = [
  [ 
    "should divide numbers using assert", () => assert(divisionItem)
  ],
  [ 
    "should divide numbers using batchAssert", () => batchAssert(divisionItems)
  ],
  [
    "should throw error for 0-division using assert",
    () => assert(invalidDivisionItem),
  ],
  [
    "must divide numbers using atest", 
    () => atest(divisionFixture, divisionScenario)
  ],
  [
    "must divide numbers using batchAtest", 
    () => batchAtest(
      [ divisionFixture, divisionFixture ], 
      [ divisionScenario, divisionScenario ]
    )
  ]
];