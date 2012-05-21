// Some worker functions
$.fetchUsenet = function(offset){
    if (!offset) var offset = 0;
    var i;
    var x;
    $.getJSON("http://"+document.location.hostname+":"+document.location.port+"/backend/usenetDB.json?offset="+offset, function(data){
        $('#usenetOutput').empty();
        $('#usenetOutput').append('<table class="table table-striped"><tbody id="outable"></tbody></table>');
        for (i=0; data[i] != null; i++) {
            var item = data[i];
            $('#outable').append('<tr><td id="td'+i+'"><a href="'+item['link']+'">'+item['series']+'</a> #'+item['issue']+' ('+item['year']+')</td></tr>');
            if (item['tags'] != null) {
                $('#td'+i).append('<div class="muted pull-right" id="sm'+i+'"></div>');
                for (x in item['tags']) {
                    $('#sm'+i).append(" "+item['tags'][x]+" ");
                };
            };
        };
    });
};

$.fetchRSS = function(){
    var i;
    var columns = 2;
    var spanWidth = 4;
    $.getJSON("http://"+document.location.hostname+":"+document.location.port+"/backend/rss.json", function(data){
        $('#RSSoutput').empty();
        for (i=0; data[i] != null && i < 20; i++) {
            if ((i%columns) == 0) { $('#RSSoutput').append("<div class=\"row-fluid\">"); };
            $('#RSSoutput').append("<div class=\"well span"+spanWidth+"\"><b><a href=\""+data[i][1]+"\">"
                +data[i][0]+"</a></b><hr/>"+data[i][3]+"</div>");
            if ((i%columns) == columns) { $('RSSoutput').append("</div>"); };
        };
    });
};
var offset = 0;
// bind load
$(fetchHistory(5));
// bind clicks
$('.rss').click($.fetchRSS());
$('.scene').click($.fetchUsenet());
$('#usenetPrev').click(function() {
    if (--offset <= 0) {
        offset = 0;
        $('#usenetPrevli').addClass('disabled');
    };
    $.fetchUsenet(offset);
    $('#pgNum').html('Page '+(offset+1));
});
$('#usenetNext').click(function() {
    $('#usenetPrevli').removeClass('disabled');
    $.fetchUsenet(++offset)
    $('#pgNum').html('Page '+(offset+1));
});
$('#rssUpdate').click($.fetchRSS());
$('#usenetUpdate').click(function() {
    $(this).button('loading').button('toggle');
    $.post('backend/usenetDB', '', function(data) {
        if (data['status'] == 200) {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-success').button('reset');
            $('#usenet').prepend('<div class="alert alert-success fade in out"><a class="close" data-dismiss="alert">ok</a>'+data['changes']+' New Comics Added</div>');
            $.fetchUsenet();
        } else if (data['status'] == 304) {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-success').button('304');
        } else {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-danger').button('o_O');
        };
        setTimeout(function() {
            $('#usenetUpdate').addClass('btn-primary').removeClass('btn-success').button('reset').button('toggle');
        }, 5000);
    });
});

