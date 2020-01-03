{% if page.title %}
# {{ site.name }} # {{ page.title }}
{% else %}
# {{ site.name }}
{% endif %}
{:.no_toc}

{% assign breadcrumbs_separator = " / " %}

{% if not page.no_breadcrumbs %}
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

{% if not page.no_toc %}
### Contents
{:.no_toc}
> - ToC
> {:toc}
{% endif %}
