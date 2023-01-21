/**
 * @abstract returns 
 *
 * @param {Array} array_1
 * @return {Array}
 */
const _throw = (m) => { 
    throw m; 
}

/**
 * @abstract returns array with elements equal to array tuple
 *
 * @param {Array} array_1
 * @param {Array} array_2
 * @return {Array}
 */
export const zip = (arr_1, arr_2) => {
    if (arr_1.length !== arr_2.length) {
        throw Error('Arrays must have the same length.');
    } else {
        return arr_1.map((e, i) => [e, arr_2[i]])
    }
};