# -*- coding: utf-8 -*-

{% from "datadog/map.jinja" import datadog with context %}

datadog-agent-service:
  service:
    - name: {{ datadog.service.name }}
    - running
    - enable: True
    - watch:
      - pkg: datadog-agent
      - file: {{ datadog.config }}
{% if datadog.checks is defined %}
      - file: {{ datadog.checks_config }}/*
{% endif %}
