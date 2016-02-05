(function(){
  var testel = document.getElementById('test');
  testel.innerHTML='complete';

  var datael = document.getElementById('json');
  //var data = JSON.parse(decodeURIComponent(datael.dataset.json))
  var data;
  data=JSON.parse(decodeURIComponent(datael.dataset.json));
  if(!!data){
    testel.innerHTML+=data.test
  }
})()
