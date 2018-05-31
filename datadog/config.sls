{% from "datadog/map.jinja" import datadog with context %}

datadog-example:
  cmd.run:
    - name: cp /etc/dd-agent/datadog.conf.example {{ datadog.config }}
    # copy just if datadog.conf does not exists yet and the .example exists
    - onlyif: test ! -f {{ datadog.config }} -a -f /etc/dd-agent/datadog.conf.example
    - require:
      - pkg: datadog-pkg

{% if datadog.api_key is defined %}
datadog-api_key-conf:
  file.replace:
    - name: {{ datadog.config }}
    - pattern: "api_key:(.*)"
    - repl: "api_key: {{ datadog.api_key }}"
    - count: 1
    - watch:
      - pkg: datadog-pkg
    # - require:
    #   - cmd: datadog-example
{% endif %}

{% if datadog.hostname is defined %}
datadog-api_key-conf:
  file.replace:
    - name: {{ datadog.config }}
    - pattern: "^(#\s)?hostname:(.*)"
    - repl: "hostname: {{ datadog.hostname }}"
    - count: 1
    - watch:
      - pkg: datadog-pkg
    # - require:
    #   - cmd: datadog-example
{% endif %}

{% if datadog.tags %}
datadog-api_key-conf:
  file.replace:
    - name: {{ datadog.config }}
    - pattern: "^(\#\s)?tags:(.*)"
    - repl: "tags: {{ datadog.tags|join(', ') }}"
    - count: 1
    - watch:
      - pkg: datadog-pkg
    # - require:
    #   - cmd: datadog-example
{% endif %}

{% for check_name in datadog.checks %}
datadog_{{ check_name }}_yaml_installed:
  file.managed:
    - name: {{ datadog.checks_config }}/{{ check_name }}.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}
{% endfor %}