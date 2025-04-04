---
layout: default
title: awesome-safety-tools
---

# awesome-safety-tools

A curated collection of open source tools for online safety.

Inspired by prior work like Awesome Redteaming and Awesome Phishing.

Help and contribute by adding a pull request to add more resources and tools!

## Featured Tools

<div class="tools-container">
  {% assign featured_tools = site.data.tools | slice: 0, 6 %}
  {% for tool in featured_tools %}
    <div class="tool-card">
      <h3><a href="{{ tool.link }}" target="_blank" rel="noopener">{{ tool.name }}</a></h3>
      <span class="category">{{ tool.category }}</span>
      <p>{{ tool.description }}</p>
    </div>
  {% endfor %}
</div>

[Browse All Tools](/tools/) | [View By Category](/categories/)