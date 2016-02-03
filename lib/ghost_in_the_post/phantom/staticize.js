"use strict";
var system  = require('system'),
    page    = require('webpage').create(),
    html    = system.args[1], //the email to be processed
    no_script = system.args[2] == "true",
    include = system.args[3]; //the injected js file

page.onLoadFinished = function(status) {
  //load included scripts to be loaded on the dom
  if(!!include){
    page.injectJs(include);
  }
  if(no_script) {
    page.evaluate(function(){
      var script_tags = document.getElementsByTagName("script");
      for(var i = 0; i < script_tags.length; i++) {
        script_tags[i].parentNode.removeChild(script_tags[i]);
      }
    })
  }
  //write out to console to export contents
  console.log(page.content); 
  phantom.exit(); //get out of here
};
//load html content
page.setContent(html, 'http://www.whatever.com');

