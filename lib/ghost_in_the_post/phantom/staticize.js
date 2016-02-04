"use strict";
var system  = require('system'),
    page    = require('webpage').create(),
    address = system.args[1], //tmp file of the html to be processed
    no_script = system.args[2] == "true",
    include = system.args[3], //tmp file for the injected js file
    timeout = parseInt(system.args[4]) || 1000, //return page contents after a timeout
    wait_event = system.args[5],  //return page contents after an event
    error_tag = "[GHOSTINTHEPOST-STATICIZE-ERROR]";

//write out to console to export contents
//and get out of here
function finish(){
  console.log(page.content); 
  phantom.exit(); 
}
 
page.onResourceError = function(resourceError) {
  console.log(error_tag);
  console.log('Unable to load resource (#' + resourceError.id + 'URL:' + resourceError.url + ')');
  console.log('Error code: ' + resourceError.errorCode + '. Description: ' + resourceError.errorString);
  phantom.exit(); 
};
 
page.onError = function(msg, trace) {
  console.log(error_tag);
  var msgStack = ['ERROR: ' + msg];
  if (trace && trace.length) {
    msgStack.push('TRACE:');
    trace.forEach(function(t) {
      msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function +'")' : ''));
    });
  }
  console.error(msgStack.join('\n'));
  phantom.exit(); 
};
 
page.onLoadFinished = function(status){
  //catch wait_event
  page.onCallback = finish
  page.evaluate(function(finish, wait_event) {
    document.addEventListener(wait_event, window.callPhantom, false)
  }, finish, wait_event)
  //clear script tags
  if(no_script) {
    page.evaluate(function(){
      var script_tags = document.getElementsByTagName("script");
      for(var i = 0; i < script_tags.length; i++) {
        script_tags[i].parentNode.removeChild(script_tags[i]);
      }
    })
  }
  //load included scripts to be loaded on the dom
  if(!!include){
    page.injectJs(include);
  }
  if(timeout > 0){
    setTimeout(finish, timeout);//timout to bailout after a period
  }
};

page.open("file://"+address)
