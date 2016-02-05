var system  = require('system'),
    page    = require('webpage').create(),
    address = system.args[1], //tmp file of the html to be processed
    timeout = parseInt(system.args[2]) || 1000, //return page contents after a timeout
    wait_event = system.args[3],  //return page contents after an event
    error_tag = "[GHOSTINTHEPOST-STATICIZE-ERROR]";

//write out to console to export contents
//and get out of here
function finish(){
  console.log(page.content); 
  phantom.exit(); 
}
 
page.onError = function(msg, trace) {
  console.error(error_tag);
  var msgStack = ['ERROR: ' + msg];
  if (trace && trace.length) {
    msgStack.push('TRACE:');
    trace.forEach(function(t) {
      msgStack.push(t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function +'")' : ''));
    });
  }
  console.error(msgStack.join('\n'));
  phantom.exit(); 
};

page.onCallback = finish
page.onInitialized = function() {
  page.evaluate(function(wait_event) {
    document.addEventListener(wait_event, window.callPhantom, false)
  }, wait_event)
};
 
page.onLoadFinished = function(status){
  if(timeout > 0){
    setTimeout(finish, timeout);//timout to bailout after a period
  }
};

//load html content
page.open("file://"+address)
