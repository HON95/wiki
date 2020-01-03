{% if page.title %}
# {{ site.name }} # {{ page.title }}
{:.no_toc}
{% else %}
# {{ site.name }}
{:.no_toc}
{% endif %}

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

{% if page.no_toc != true %}
### Contents
{:.no_toc}

> - ToC
> {:toc}
{% endif %}
