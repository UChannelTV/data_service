<script>
  var host = "Data-Service-Read-615810735.us-west-1.elb.amazonaws.com";
  var id = 3;
  var first_id = 0;
  var refresh_time = 1200;
  function addVideo() {
    jQuery.ajax({
      type: "GET",
      url: "http://" + host + "/api/v1.0/videos/category?id=" + id + "&limit=12&start_video=" + first_id,
      dataType : 'json', 
      success: function(data, status, xhr) {
        var videos = data.videos
        if (videos) {
          var table = '';
          var n = 0
          while (n < videos.length) {
            table += '<tr>';
            for (i = 0; i < 3; i++) {
              if (n + i < videos.length) {
                table += '<td align="center"><a href="/video.html?v=' + videos[n + i].id + '"><img border="0" src="' + videos[n + i].thumbnail + '" width="320" height="180">';
                if ((n + i) >= videos.length) break;
              }
            }
            table += '</tr>'

            for (i = 0; i < 3; i++) {
              var min = Math.floor(videos[n].duration / 60) + "";
              var sec = videos[n].duration % 60 + "";
              var pad = "00"
              var tStr = pad.substring(0, pad.length - min.length) + min + ":" + pad.substring(0, pad.length - sec.length) + sec;
              table += '<td align="center", valign="top"><div style="color:black; font-size:18pxi; display:inline-block; margin:15px">' + videos[n].title +
                '  |  ' + tStr + '</div></td>'
              if (++n >= videos.length) break;
            }
            table += '</tr><tr/>';
          }
          if (data.next) {
            first_id = data.next;
          } else {
            first_id = -1;
            jQuery("#more_uchannel_videos").html('')
          }
          jQuery("#uchannel_video_list tr:last").after(table);
        }
      }
    })
  }
  jQuery(document).ready(function(){
    addVideo();

    jQuery("#more_uchannel_videos_button").unbind('click').click(function(){
      addVideo();
    });
  });
</script>
