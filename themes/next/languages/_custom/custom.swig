{# 搞怪网页标题 #} {% if theme.title_trick.enable %}
<script>
  var OriginTitile = document.title;
  var titleTime;
  document.addEventListener("visibilitychange", function() {
    if (document.hidden) {
      document.title = "{{ theme.title_trick.leave }}" + OriginTitile;
      clearTimeout(titleTime);
    } else {
      document.title = "{{ theme.title_trick.enter }}" + OriginTitile;
      titleTime = setTimeout(function() {
        document.title = OriginTitile;
      }, 2000);
    }
  });
</script>
{% endif %}
