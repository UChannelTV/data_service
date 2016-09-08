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
        var embed = null;
        if (data.youtube_id) {
          embed = '<iframe src="//www.youtube.com/embed/' + data.youtube_id + '?wmode=opaque&autoplay=1" frameborder="0" allowfullscreen></iframe>'
        } else if (data.vimeo_id) {
          embed = '<iframe src="//player.vimeo.com/video/' + data.vimeo_id + '?autoplay=1" width="WIDTH" height="HEIGHT" frameborder="0" webkitallowfullscreen ' +
                  'mozallowfullscreen allowfullscreen></iframae>'
        }
        if (embed) {
          jQuery("div.wsite-youtube-container").html(embed);
          var pr = '<h2>' + data.title + '</h2><div style="float:left; width:70%">' + data.description.split('\n').join('<br/>') + '</div>';
          if (data.qr_code) {
            pr += '<div style="float:right; width:25%"><img src="' + data.qr_code + '"></img></div>';
          }
          pr += '<br/>';
          jQuery("#uchannel_video_content").html(pr);
          document.title = data.category + " " + data.title;
          jQuery('meta[property="og:title"]').attr("content", data.title);
          var desc = data.description.split("\n").join(" ");
          jQuery('meta[property="og:description"]').attr("content", desc);
          jQuery('meta[name=description]').attr("content", desc);
          if (data.tags)
            jQuery('meta[name=keywords]').attr("content", data.tags.join(","));
        }
      }
    })
  })
</script>

