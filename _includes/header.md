{% if page.title %}
# {{ site.name }} # {{ page.title }}
{% else %}
# {{ site.name }}
{% endif %}
{:.no_toc}

{% assign breadcrumbs_separator = " / " %}

{% if page.no_breadcrumbs != true %}
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
{% endif %}

### Contents
{:.no_toc}

> - ToC {:toc}
