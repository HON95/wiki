# {{ site.name }} # {{ page.title }}
{:.no_toc}

{% assign breadcrumbs_separator = " / " %}

> [Home](/)
{%- if page.breadcrumbs -%}
{%- for crumb in page.breadcrumbs -%}
    {{ breadcrumbs_separator }}
    {%- if crumb.url -%}
        [{{ crumb.title }}]({{ crumb.url }})
    {%- else -%}
        {{ crumb.title }}
    {%- endif -%}
{% endfor %}
{% endif %}

{% if not page.no_toc %}
### Contents
{:.no_toc}

> - ToC {:toc}
{% endif %}
