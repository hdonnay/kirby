$('.scene').bind('click', function() {
    var i;
    var x;
    $.getJSON("http://"+document.location.hostname+"/backend/usenet", function(data){
        $('#usenetOutput').empty();
        for (i=0; data[i] != null; i++) {
            $('#usenetOutput').append("<li id=\"li"+i+"\"><a href=\""+data[i]['link']+"\">" +data[i]['titleString']+"</a></li>");
            if (data[i]['tags'] != null) {
                $('#li'+i).append("<ul id=\"ul"+i+"\"></ul>");
                for (x in data[i]['tags']) {
                    $('#ul'+i).append("<li>"+data[i]['tags'][x]+"</li>");
                };
            };
        };
    });
});
$('.rss').bind('click', function() {
    var i;
    var columns = 2;
    var spanWidth = 4;
    $.getJSON("http://"+document.location.hostname+"/backend/rss", function(data){
        $('#RSSoutput').empty();
        for (i=0; data[i] != null; i++) {
            if ((i%columns) == 0) { $('#RSSoutput').append("<div class=\"row-fluid\">"); };
            $('#RSSoutput').append("<div class=\"well span"+spanWidth+"\"><b><a href=\""+data[i][1]+"\">"
                +data[i][0]+"</a></b><hr/>"+data[i][3]+"</div>");
            if ((i%columns) == columns) { $('RSSoutput').append("</div>"); };
        };
    });
});
