# {{ title }} | {{ page.title }}
{:.no_toc}

{# Breadcrumbs #}
<ol class="breadcrumb">
  {% for crumb in page.breadcrumbs %}
    <li class="breadcrumb-item"><a href="{{ crumb.url }}">{{ crumb.title }}</a></li>
  {% endfor %}
  <li class="breadcrumb-item active">{{ page.title }}</li>
</ol>

## Contents
{:.no_toc}
- ToC
{:toc}
