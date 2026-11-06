{% macro classify_shipment_status(a, e) %}
    CASE
        WHEN {{ a }} < {{ e }} THEN 'Delivered Early'
        WHEN {{ a }} = {{ e }} THEN 'Delivered On Time'
        WHEN {{ a }} > {{ e }} THEN 'Delivered Late'
        WHEN {{ a }} IS NULL THEN 'Pending Delivery'
    END
{% endmacro %}