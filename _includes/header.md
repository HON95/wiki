# {{ site.name }} / {{ page.title }}
{:.no_toc}

{% assign breadcrumbs_separator = " / " %}

{% if page.breadcrumbs %}
>
{%- for crumb in page.breadcrumbs -%}
    {%- if crumb.url -%}
        [{{ crumb.title }}]({{ crumb.url }})
    {%- else -%}
        {{ crumb.title }}
    {%- endif -%}
    {{ breadcrumbs_separator }}
{%- endfor -%}
{{ page.title }}
{% endif %}

{% if page.toc_enable %}
### Contents
{:.no_toc}
- ToC
{:toc}
{% endif %}
