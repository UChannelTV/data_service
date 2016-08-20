<script>
  jQuery(document).ready(function(){
    var path = window.location.pathname;
    var query = window.location.search.substring(1).replace("v=", "");
    var host = "54.153.1.235";
    jQuery.ajax({
      type: "GET",
      url: "http://" + host + "/api/v1.0/videos/" + query + "/formatted",
      dataType : 'json', 
      success: function(data, status, xhr) {
        if (data.youtube_id) {
          var embed = '<iframe src="//www.youtube.com/embed/' + data.youtube_id + '?wmode=opaque&autoplay=1" frameborder="0" allowfullscreen></iframe>';
          jQuery("div.wsite-youtube-container").html(embed);
          jQuery("h2.wsite-content-title").html(data.title);
          jQuery("div.paragraph").html(data.description);
          if (data.qr_code) {
            jQuery("td.wsite-multicol-col").eq(1).html('<img src="http://' + host + '/assets/' + data.qr_code + '"></img>');
          }
        } else {
          jQuery("h2.wsite-content-title").html("We are sorry, but we cannot find the video");
        }
      }
    })
  })
</script>

<script>
  jQuery(document).ready(function(){
    var host = "54.153.1.235";
    var id = 17;
    var first_id = 0;
    jQuery.ajax({
      type: "GET",
      url: "http://" + host + "/api/v1.0/videos/category?id=" + id + "&limit=12",
      dataType : 'json', 
      success: function(data, status, xhr) {
        var videos = data.videos
        if (videos) {
          var table = '<table cellspacing="25">';
          var n = 0
          while (n < videos.length) {
            table += '<tr>';
            for (i = 0; i < 3; i++) {
              table += '<td align="center"><a href="/video.html?v=' + videos[n + i].id + '"><img border="0" src="' + videos[n + i].thumbnail + '" width="320" height="180">';
              if ((n + i) >= videos.length) break;
            }
            table += '</tr>'

            for (i = 0; i < 3; i++) {
              var min = Math.floor(videos[n].duration / 60) + "";
              var sec = videos[n].duration % 60 + "";
              var pad = "00"
              var tStr = pad.substring(0, pad.length - min.length) + min + ":" + pad.substring(0, pad.length - sec.length) + sec;
              table += '<td align="center", valign="top"><span style="color:black;font-size:18px">' + videos[n].title +
                '&nbsp;&nbsp;|&nbsp;&nbsp;' + tStr + '</span></td>'
              if (++n >= videos.length) break;
            }
            table += '</tr><tr/>';
          }
          table += '</table>';
          jQuery("div.paragraph").after(table)
        }
      }
    })
  })
</script>




