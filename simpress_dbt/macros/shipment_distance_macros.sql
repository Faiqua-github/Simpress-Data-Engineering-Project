
{% macro classify_distance(distance_col) %}

    CASE
            WHEN {{ distance_col }} < 500 THEN 'Short Distance'
            WHEN {{ distance_col }} >= 500 AND {{ distance_col }} < 1500 THEN 'Medium Distance'
            WHEN {{ distance_col }} >= 1500 THEN 'Long Distance'
            ELSE 'Unknown Distance'
        END
{% endmacro %}







