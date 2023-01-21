
import { assert, batchAssert, atest } from "../assertions"

const items = [
    [ 42,         (result) => expect(result).toBeDefined()            ],
    [ "42", "42", (result, expected) => expect(result).toBe(expected) ],
];

let fixture, experiment, setup, exercise, verify, teardown;

// Valid samples 
const validLength1Item = items[0];
const validLength2Item = items[1];

// Error-prone samples
const invalidArgumentLengthItem = [ '42' ];
const invalidCallbackItem = [ '42', '42' ];

describe(
    "assert", 
    () => {
        it(
            "should assert on result-callback pattern", 
            () => {
                expect.assertions(1);
                assert(validLength1Item);
            }
        );

        it(
            "should assert on result-expected-callback pattern", 
            () => {
                expect.assertions(1);
                assert(validLength2Item);
            }
        );

        it(
            "should throw error on item with length different than 2 or 3", 
            () => {    
                const invalidArgumentFunction = () => assert(invalidArgumentLengthItem);
                expect(invalidArgumentFunction).toThrow(Error);
            }
        );

        it(
            "should throw error on invalid callback function", 
            () => {
                const invalidCallbackFunction = () => assert(invalidCallbackItem);
                expect(invalidCallbackFunction).toThrow(Error);
            }
        );
    }
);

describe(
    "batchAssert", 
    () => {
        it(
            "should assert asserts in batch", 
            () => {
                expect.assertions(items.length);
                batchAssert(items)
            }
        )
    }
)

describe(
    "atest", 
    () => {
        it(
            "should assert atest", 
            () => {
                fixture = '42';
                const longFunction = (fixture) => fixture;  

                setup = () => {};
                exercise = (fixture) => {
                    return {
                        "results": longFunction(fixture), 
                        "expectations": '42',
                        "assertionMaps": (result, expected) => expect(result).toBe(expected)
                    }
                };
                verify = (experiment) => {
                    experiment.assertionMaps(experiment.results, experiment.expectations)
                }
                teardown = () => {};

                atest('42', setup, exercise, verify, teardown);
            }
        )
    }
)
