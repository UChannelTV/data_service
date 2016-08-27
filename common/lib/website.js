<script>
  jQuery(document).ready(function(){
    var path = window.location.pathname;
    var query = window.location.search.substring(1).replace("v=", "");
    var host = "Data-Service-Read-615810735.us-west-1.elb.amazonaws.com"
    jQuery.ajax({
      type: "GET",
      url: "http://" + host + "/api/v1.0/videos/" + query + "/formatted",
      dataType : 'json', 
      success: function(data, status, xhr) {
        if (data.youtube_id) {
          var embed = '<iframe src="//www.youtube.com/embed/' + data.youtube_id + '?wmode=opaque&autoplay=1" frameborder="0" allowfullscreen></iframe>'
          jQuery("div.wsite-youtube-container").html(embed)
          jQuery("h2.wsite-content-title").html(data.title)
          var pr = '<table><tr>';
          if (data.qr_code) {
            pr += '<td width="70%" valign="top">' + data.description + '</td><td width="30%" align="right"><img src="' + data.qr_code + '"></img></td>';
          } else {
            pr += '<td width="70%" valign="top">' + data.description + '</td>';
          }
          pr += '</table>'
          jQuery("div.paragraph").html(pr)
        } else {
          jQuery("h2.wsite-content-title").html("We are sorry, but we cannot find the video")
        }
      }
    })
  })
</script>



<script>
  var host = "Data-Service-Read-615810735.us-west-1.elb.amazonaws.com";
  var id = 16;
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
              table += '<td align="center", valign="top"><span style="color:black;font-size:18px">' + videos[n].title +
                '  |  ' + tStr + '</span></td>'
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
  function saveContent() {
    try {
      localStorage.setItem("category_" + id, JSON.stringify({"first_id": first_id, "date": new Date().getTime() / 1000, "content": jQuery("#uchannel_video_list").html()}));
    } catch (e) {}
  }
  function getContent() {
    try {
      var contentStr = localStorage.getItem("category_" + id);
      if (contentStr) {
        localStorage.removeItem("category_" + id);
        var content = JSON.parse(contentStr);
        var expD = content.date + refresh_time;
        if ((new Date().getTime() / 1000) > expD) return false;

        first_id = content.first_id;
        jQuery("#uchannel_video_list").html(content.content);
        return;
      }
    } catch(e) {}
    addVideo();
  }
  jQuery(document).ready(function(){
    getContent();

    jQuery("#more_uchannel_videos_button").unbind('click').click(function(){
      addVideo();
    });

    jQuery(window).on("unload", function() {
      alert("OK");
      saveContent();
    });
   // jQuery(document).on("click", "a", function(){
   //   saveContent();
   // });
  });
</script>


<table id="uchannel_video_list" cellspacing="25"><tr></tr></table><br/>
<div id="more_uchannel_videos" style="text-align:center">
  <button id="more_uchannel_videos_button" type="button" style="padding: 5px"><h3>更多視頻</h3></button>
</div>



<script>
  var host = "Data-Service-Read-615810735.us-west-1.elb.amazonaws.com";
  var id = 9;
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
              table += '<td align="center", valign="top"><span style="color:black;font-size:18px">' + videos[n].title +
                '  |  ' + tStr + '</span></td>'
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

