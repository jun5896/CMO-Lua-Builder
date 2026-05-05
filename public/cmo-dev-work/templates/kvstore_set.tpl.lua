-- kvstore_set.tpl.lua
-- ScenEdit_SetKeyValue. 번들 샘플 빈도 2위.
-- 컨텍스트: entries = { { key = ..., value = ... }, ... }  또는 단일 key/value
{% if entries then %}
{% for _, kv in ipairs(entries) do %}
ScenEdit_SetKeyValue({{q(kv.key)}}, {{q(tostring(kv.value))}})
{% end %}
{% else %}
ScenEdit_SetKeyValue({{q(key)}}, {{q(tostring(value))}})
{% end %}
