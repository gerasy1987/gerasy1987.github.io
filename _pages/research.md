---
layout: page
permalink: /research/
title: research
description: published papers, working papers, and work in progress
years: [2021,2015]
nav: true
nav_order: 2
---
<!-- _pages/research.md -->
<div class="publications">

<h1>Dissertation</h1>
<hr>
{% bibliography -f papers -q @phdthesis %}

<h1>Published papers</h1>

{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @article[year={{y}}]* %}
{% endfor %}

<h1>Working papers</h1>
<hr>
{% bibliography -f papers -q @unpublished[pdf]* %}

<h1>Work in Progress</h1>
<hr>
{% bibliography -f papers -q @misc* %}


</div>