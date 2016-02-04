"use strict";
var system  = require('system'),
    page    = require('webpage').create(),
    html = system.args[1], //tmp file of the html to be processed
    timeout = parseInt(system.args[4]) || 1000, //return page contents after a timeout
    wait_event = system.args[5],  //return page contents after an event
    error_tag = "[GHOSTINTHEPOST-STATICIZE-ERROR]";

//write out to console to export contents
//and get out of here
function finish(){
  console.log(page.content); 
  phantom.exit(); 
}
 
//commented out because stuff like stylesheets and images will fail in situations where they shouldnt
//page.onResourceError = function(resourceError) {
  //console.log(error_tag);
  //console.log('Unable to load resource (#' + resourceError.id + 'URL:' + resourceError.url + ')');
  //console.log('Error code: ' + resourceError.errorCode + '. Description: ' + resourceError.errorString);
  //phantom.exit(); 
//};
 
page.onError = function(msg, trace) {
  console.log(error_tag);
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
 
page.onLoadFinished = function(status){
  //catch wait_event
  page.onCallback = finish
  page.evaluate(function(finish, wait_event) {
    document.addEventListener(wait_event, window.callPhantom, false)
  }, finish, wait_event)
  if(timeout > 0){
    setTimeout(finish, timeout);//timout to bailout after a period
  }
};

//load html content
page.setContent(html, 'ghost_in_the_post');
