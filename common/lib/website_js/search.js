<script>
  var host = "Data-Service-Read-615810735.us-west-1.elb.amazonaws.com";
  jQuery(document).ready(function(){
    var query = window.location.search.substring(1).replace("q=", "");
    jQuery("#wsite-search-query").attr("value", decodeURIComponent(query));
    if (query.length > 0) {  
      jQuery.ajax({
        type: "GET",
        url: "http://" + host + "/api/v1.0/videos/search?query=" + query,
        dataType : 'json', 
        success: function(videos, status, xhr) {
          if (videos) {
            var table = '';
            var n = 0
            while (n < videos.length) {
              table += '<tr>';
              for (i = 0; i < 3; i++) {
                if (n + i < videos.length) {
                  table += '<td align="center"><a href="/video.html?v=' + videos[n + i].id + '"><img border="0" src="' + videos[n + i].thumbnail + '" width="320" height="180">';
                } else {
                  table += '<td/>';
                }
              }
              table += '</tr>'

              for (i = 0; i < 3; i++) {
                if (n < videos.length) {
                  var min = Math.floor(videos[n].duration / 60) + "";
                  var sec = videos[n].duration % 60 + "";
                  var pad = "00"
                  var tStr = pad.substring(0, pad.length - min.length) + min + ":" + pad.substring(0, pad.length - sec.length) + sec;
                  table += '<td align="center", valign="top"><div style="width:320px; color:black; font-size:18px; display:inline-block; margin-right:15px">' + videos[n].category + " - " +
                      videos[n].title + ' | ' + tStr + '</div></td>'
                } else {
                  table += '<td/>';
                }
                n++;
              }
              table += '</tr><tr/>';
            }

            jQuery("#uchannel_video_list tr:last").after(table);
          }
        }
      });
    }
  });
</script>
