'use strict';

var redis  = require('redis');
var config = require('./config.json');

redis = redis.createClient(config.redisPort, config.redisHost);

redis.keys(config.redisPrefix + '*', gotKeys);

function gotKeys(err, keys) {
    if (err) {
        throw err;
    }

    keys.forEach(function(key) {
        redis.del(key);
    });

    redis.quit();
}
