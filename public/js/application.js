!function ($) {
    $(function(){
        $(".alert").alert();
        $('.tabs a:last').tab('show')
    });
}(window.jQuery)
function fetchHistory(num, target) {
    /*
     Emits a Bootstrap'd table from recieved JSON
     Takes a number of records to request
     Takes a jQuery Object to insert the table into
     */
    if (!num) var num = 25;
    if (!target) var target = $('#historyTable');
    var table = "fetchHistoryTable";
    var i;
    $.getJSON("http://"+document.location.hostname+":"+document.location.port+"/backend/history.json?num="+num, function(data){
        target.empty();
        target.append('<table id="'+table+'" class="table table-striped"></table>');
        //$('#'+table).append('<caption class="pull-left"><h2>History</h2></caption>');
        $('#'+table).append('<thead><tr><th colspan="3">Name</th><th></th><th></th><th></th><th>Action</th><th>Time</th></tr></thead>');
        $('#'+table).append('<tbody id="'+table+'Body"></tbody>');
        for (i=0; data[i] != null; i++) {
            var item = data[i];
            $('#'+table+'Body').append('<tr><td colspan="3">'+item['name']+' #'+item['issue']+'</td><td></td><td></td><td></td><td>'+item['action']+'</td><td>'+item['time']+'</td></tr>');
        };
    });
}
