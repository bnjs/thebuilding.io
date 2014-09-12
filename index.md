---
layout: default
title: The Building
---

<div id="posts">

{% for post in site.posts %}
  <div class="post" style="margin-bottom:0px">
    {% include posts/title.html index="true" %}
    {{ post.content }}
    {% include posts/actions.html index="true" %}
  </div>
  ---
{% endfor %}

</div>
