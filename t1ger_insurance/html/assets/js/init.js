$(document).ready(function(){
  window.addEventListener('message', function( event ) {
    if (event.data.action == 'open') {
      var type      = event.data.type;
      var userData  = event.data.array['user'][0];
      var vehPlate  = event.data.array['plate'];
      var vehIns    = event.data.array['insurance'];

      if ( type == null) {    
        $('#first-name').text(userData.firstname);
        $('#last-name').text(userData.lastname);
        $('#veh-plate').text(vehPlate);
        $('#veh-ins').text(vehIns);
        $('#ins-paper').css('background', 'url(assets/images/inspaper.png)');
      }

      $('#ins-paper').show();
    } else if (event.data.action == 'close') {
      $('#first-name').text('');
      $('#last-name').text('');
      $('#veh-plate').text('');
      $('#veh-ins').text('');
      $('#ins-paper').hide();
    }
  });
});
