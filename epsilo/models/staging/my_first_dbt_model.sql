{{ config(
    unique_key="id"
) }}

with source_data as (
    select 1 as user_key, "121" as id, "James" as user
    union all
    select 2 as user_key, "120" as id, "Lena" as user
)

select *
from source_data
