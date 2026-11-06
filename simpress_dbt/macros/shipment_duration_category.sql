{% macro shipment_duration_category(duration) %}

    CASE
        WHEN {{ duration }} = 1 THEN 'Fast Delivery'
        WHEN {{ duration }} = 2 THEN 'Standard Delivery'
        WHEN {{ duration }} = 3 THEN 'Slow Delivery'
        ELSE 'Unknown Delivery Duration'
    END

{% endmacro %}