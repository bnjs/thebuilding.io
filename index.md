---
layout: top
title: The Building
---

<div id="posts">

{% for post in site.posts %}
  {% if post.status == 'feature' %}
  <div class="post post-feature">
    {% include posts/title.html index="true" %}
    {{ post.content }}
    {% include posts/actions.html index="true" %}
  </div>
  {% endif %}
{% endfor %}

<hr>

{% assign index = '1' %}
{% for post in site.posts limit:7 %}
  {% capture indexsize %}{{ index | size }}{% endcapture %}
  {% if post.status != 'feature' and indexsize != '7'  %}
    <div class="post post-subfeature">
      {% include posts/title.html index="true" %}
      {{ post.content }}
      {% include posts/actions.html index="true" %}
    </div>
    {% if indexsize == '2' or indexsize == '4' %}
      <div class="clearfix"></div>
      <hr>
    {% endif %}
    {% assign index = index | append: '1' %}
  {% endif %}
{% endfor %}

<div class="clearfix"></div>
<hr>

{% for post in site.posts offset:3 %}
  {% if post.status != 'feature' %}
    <div class="post post-list">
      {% include posts/title.html index="true" %}
      {{ post.content }}
      {% include posts/actions.html index="true" %}
    </div>
    <hr>
  {% endif %}
{% endfor %}

</div>
