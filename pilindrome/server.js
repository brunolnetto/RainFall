'use strict';

// [START app]
const express = require('express');
const axios = require('axios');

/**
 * @returns {String} returns reverse string
 */
function flip(str) {
    return str.split("").reverse().join("")
}

/**
 * @returns {boolean} returns 0 to not-equal and 1 to equal strings
 */
function isPalyndrome(str) {
    return 1 + str.localeCompare(flip(str));
}

async function getPiDigits(startDigit, numDigits) {

  const host = 'https://api.pi.delivery/v1';
  let route = `/pi?start=${startDigit}&numberOfDigits=${numDigits}&radix=10`;
  
  return await axios.get(host + route).then(
    (resp) => {
      return resp.data.content;
    }
  ); 
}

const app = express();

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;

// [START enable_parser]
// This middleware is available in Express v4.16.0 onwards
app.use(express.json({extended: true}));
// [END enable_parser]

app.get('/', (req, res) => {
    const found = false;
    let word_len = 9;
    let pointer = 0;
    const print_partition = 10000;

    while(!found) {
      getPiDigits(pointer, word_len).then(
        (pi_snippet) => {
          if(!!isPalyndrome(pi_snippet)) {
            found = true;
          }
        }
      )

      if(pointer%print_partition === 0) {
        console.log(pointer);
      }

      pointer += 1;
    }
  }
);

app.listen(PORT, () => {
  console.log(`Listening on port: ${PORT}`);
});

// [END app]

