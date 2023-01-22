/* 
 *  Module import
 */

/* Case 1 */
import { add, multiply, subtract, divide } from "../operations"

/* Case 2 */
// import { add, multiply, subtract, divide } from "#module/operations"

/* 
 *  Test design
 */

/* Case 1 */
let sceneFunctions;

const scenarios = {
    "add": [
        [ 
            "should sum numbers",
            () => expect(add(1, 2)).toBe(3)
        ]
    ],
    "multiply": [
        [ 
            "should multiply numbers",
            () => expect(multiply(1, 2)).toBe(2)
        ]
    ],
    "subtract": [
        [
            "should subtract numbers",
            () => expect(subtract(2, 1)).toBe(1)
        ]
    ],
    "division": [
        [
            "should divide numbers",
            () => expect(divide(42, 2)).toBe(21)
        ],
        [
            "should throw error for 0-division",
            () => {
                zeroDivision = () => divide(42, 0)    
                expect(zeroDivision).toThrow();
            }
        ]
    ]
};

for (const [ scenarioName, scenes ] of Object.entries(scenarios)) {
    sceneFunctions = () => {
        for (const [description, sceneFunction] of scenes) {
            () => it(description, sceneFunction);
        } 
    }
    
    describe(scenarioName, sceneFunctions)
}

/* Case 2 */
describe(
    "add", 
    () => it(
        "should sum numbers", 
        () => expect(add(1, 2)).toBe(3)
    )
)

describe(
    "multiply", 
    () => it(
        "should multiply numbers", 
        () => expect(multiply(1, 2)).toBe(2)
    )
)

describe(
    "subtract", 
    () => it(
        "should subtract numbers", 
        () => expect(subtract(2, 1)).toBe(1)
    )
)

describe(
    "divide", 
    () => {
        it("should divide numbers", () => expect(divide(42, 2)).toBe(21))
        it("should throw error for 0-division", 
            () => {
                zeroDivision = () => divide(42, 0)    
                expect(zeroDivision).toThrow();
            }
        )
    }
)
