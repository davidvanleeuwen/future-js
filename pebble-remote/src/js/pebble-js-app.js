(function() {
  var httpLocation, post;

  httpLocation = '192.168.123.16';

  Pebble.addEventListener("ready", function(e) {
    return console.log('JS READY');
  });

  post = function(path, cb) {
    var request;
    request = new XMLHttpRequest();
    request.open('POST', "http://" + httpLocation + ":5000/" + path, true);
    console.log('POSTING');
    request.onload = function(e) {
      return typeof cb === "function" ? cb(request, request.responseText) : void 0;
    };
    return request.send(null);
  };

  Pebble.addEventListener("appmessage", function(e) {
    var msg;
    msg = e.payload.dummy;
    switch (msg) {
      case 'connect':
        return post('connect', function(req, resp) {
          return console.log('CONNECTED');
        });
      case 'next':
        return post('next', function(req, resp) {
          return console.log('NEXT SLIDE');
        });
      case 'previous':
        return post('previous', function(req, resp) {
          return console.log('PREVIOUS SLIDE');
        });
    }
  });

}).call(this);
