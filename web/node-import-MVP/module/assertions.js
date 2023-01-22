import { zip } from 'lodash'

export const assert = (item) => {
    let result, expected;
    const item_length = item.length;
    
    if(item_length === 2 || item_length === 3) {
        const callback = item[item_length-1];
        
        if(typeof callback === 'function') {
            switch(item_length){
                case 2:
                    result = item[0];
        
                    callback(result);
        
                    break;
                    
                case 3:
                    result = item[0];
                    expected = item[1];
        
                    callback(result, expected);
        
                    break;
            }

        } else {
            const callbackValidity = 'Last element on item must be a callback function!';
            
            throw Error(callbackValidity);
        }

    } else {
        const description = 'Test element may have structure: ';
        const schemas = '[result, assertion_callback] or [result, expected, assertion_callback]';

        throw Error(description + schemas);
    }   
}

export const batchAssert = (items) => items.forEach(item => assert(item));

export const atest = (fixtures, scenario) => {
    scenario.setup();

    const experiment = scenario.exercise(
        scenario.prepare(fixtures)
    );
    
    scenario.verify(experiment);
    scenario.teardown();
}

export const batchAtest = (fixtures, scenarios) => {
    let scenario, fixture;
    
    zip(fixtures, scenarios).forEach( 
        ( scenario_tuple ) => {
            fixture = scenario_tuple[0];
            scenario = scenario_tuple[1];
            
            atest(fixture, scenario)
        } 
    );
};

export const buildScenario = (setup, prepare, exercise, verify, teardown) => {
    return {
        "setup": setup, 
        "prepare": prepare,
        "exercise": exercise,
        "verify": verify,
        "teardown": teardown

    }
}

export const buildAssertion = (results, expectations, assertionMaps) => {
    return {
        "results": results, 
        "expectations": expectations,
        "assertionMaps": assertionMaps
    }
}
