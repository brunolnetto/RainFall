'use strict';

// [START app]
const express = require('express');
const path = require('path');
const db = require('./db.js');
const { v4: uuidv4 } = require('uuid');
const query_builder = require('./utils.js').query_builder;

const app = express();
const credentials = db.credentials;

// [START enable_parser]
// This middleware is available in Express v4.16.0 onwards
app.use(express.json({extended: true}));
// [END enable_parser]

app.get('/', (req, res) => {
  res.send('Hello from App Engine!');
});

// [START add_display_form]
app.get('/submit', (req, res) => {
    var dir_name = path.join(__dirname, '/views/form.html');
    res.sendFile(dir_name);
});
// [END add_display_form]

async function test_db(msg) {
    console.log(msg);
    
    var query_raw = 'SELECT * FROM user_messages;';
    var params_list = [];
    var query_msg = 'Sucessful select.';
    
    result = await query_builder(query_raw, params_list, query_msg);    
    console.log(result);

    /*
      var insert_str = 'insert into user_messages (name, message) values ($1, $2)';
      var params_list = [msg.name_str, msg.message];
      await query_builder(insert_str, params_list, 'Sucessful insertion');

      var request_str = 'select * from user_messages';
      await query_builder(request_str, [], 'Sucessful request!');
    */
}

// [START add_post_handler]
app.post('/submit', async (req, res) => {
    var msg = {
                name_str: String(req.body.name),
                message: String(req.body.message),
              };    
    try { await test_db(msg); }
    catch(e) { console.log(e.stack); }
});
// [END add_post_handler]

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Listening on port: ${PORT}`);
});

// [END app]

