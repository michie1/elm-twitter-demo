const express = require('express');
const app = express();

const request = require('request-promise');
const bearer = require('./config').bearer;

console.log(bearer);

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  next();
});

app.get('/:q', (req, res) => {
  const options = {
    method: 'GET',
    uri: 'https://api.twitter.com/1.1/search/tweets.json?q=' + req.params.q,
    headers: {
      'Authorization': 'Bearer ' + bearer
    }
  };
  request(options).then((response) => {
    res.send(response);
  });
});

app.listen(3000);
