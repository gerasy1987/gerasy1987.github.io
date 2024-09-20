---
layout: page
permalink: /research/
title: research
description: published papers, working papers, and work in progress
years: [2021,2015,2014]
nav: true
nav_order: 2
---
<!-- _pages/research.md -->
<div class="publications">

<h1>Published papers</h1>

{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @article[year={{y}}]* %}
{% endfor %}

<h1>Book chapters</h1>

{% bibliography -f papers -q @inproceedings %}

<h1>Working papers</h1>

{% bibliography -f papers -q @unpublished[status=jmp]* %}

{% bibliography -f papers -q @unpublished[status!=jmp]* %}

<h1>Work in Progress</h1>

{% bibliography -f papers -q @misc %}


</div>