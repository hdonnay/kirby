// Some worker functions
$.fetchUsenet = function(min, max){
    var i;
    var x;
    $.getJSON("http://"+document.location.hostname+"/backend/usenetDB.json", function(data){
        $('#usenetOutput').empty();
        for (i=0; data[i] != null; i++) {
            var item = data[i];
            $('#usenetOutput').append("<li id=\"li"+i+"\"><a href=\""+item['link']+"\">"+item['series']+"</a> #"+item['issue']+" ("+item['year']+")</li>");
            if (item['tags'] != null) {
                $('#li'+i).append("<ul id=\"ul"+i+"\"></ul>");
                for (x in item['tags']) {
                    $('#ul'+i).append("<li>"+item['tags'][x]+"</li>");
                };
            };
        };
    });
};

$.fetchRSS = function(){
    var i;
    var columns = 2;
    var spanWidth = 4;
    $.getJSON("http://"+document.location.hostname+"/backend/rss.json", function(data){
        $('#RSSoutput').empty();
        for (i=0; data[i] != null; i++) {
            if ((i%columns) == 0) { $('#RSSoutput').append("<div class=\"row-fluid\">"); };
            $('#RSSoutput').append("<div class=\"well span"+spanWidth+"\"><b><a href=\""+data[i][1]+"\">"
                +data[i][0]+"</a></b><hr/>"+data[i][3]+"</div>");
            if ((i%columns) == columns) { $('RSSoutput').append("</div>"); };
        };
    });
};
// bind load
$(fetchHistory(5));
// bind clicks
$('.rss').click($.fetchRSS());
$('.scene').click($.fetchUsenet());
$('#rssUpdate').click($.fetchRSS());
$('#usenetUpdate').click(function() {
    $(this).button('loading').button('toggle');
    $.post('backend/usenetDB', '', function(data) {
        if (data['status'] == 200) {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-success').button('reset');
            $('#usenet').prepend('<div class="alert alert-success fade in out"><a class="close" data-dismiss="alert">ok</a>'+data['changes']+' New Comics Added</div>');
        } else if (data['status'] == 304) {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-success').button('304');
        } else {
            $('#usenetUpdate').removeClass('disabled btn-primary').addClass('btn-danger').button('o_O');
        };
        setTimeout(function() {
            $('#usenetUpdate').addClass('btn-primary').removeClass('btn-success').button('reset').button('toggle');
        }, 2000);
        $.fetchUsenet();
    });
});

