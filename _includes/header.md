# {{ site.name }} / {{ page.title }}
{:.no_toc}

{% assign breadcrumbs_separator = " / " %}

{% if page.breadcrumbs %}
> [Home](/)
{%- for crumb in page.breadcrumbs -%}
    {{ breadcrumbs_separator }}
    {%- if crumb.url -%}
        [{{ crumb.title }}]({{ crumb.url }})
    {%- else -%}
        {{ crumb.title }}
    {%- endif -%}
{%- endfor -%}
{% endif %}

{% if page.toc_enable %}
### Contents
{:.no_toc}
- ToC
{:toc}
{% endif %}
