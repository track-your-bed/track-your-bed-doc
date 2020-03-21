# Data model description
in the simple model, we want to track free beds on a by-station basis. For this, each station belongs to a hospital 
(many-to-one relationship) and each station has multiple bed counts (one-to-many relationship). Furthermore, each bed 
count has exactly one bed type related, but one bed type can be related to multiple bed counts. Below, we will discuss
each of the aforementioned data types in detail. Each data type entity is identified by a randomly generated type 4 
UUID, which is also the primary key in the corresponding table.

The ERD is shown in [datamodel.puml][datamodel].

# Hospital data type
table name: `hospital`

Fields:

- `id`: the unique `UUID`.
- `name`: the name of the hospital, as `VARCHAR (255) NOT NULL`.
- `max_capacity`: the maximum bed capacity (accumulated) of a hospital, represented as `SMALLINT NOT NULL` and should 
    always be `> 0`.
- `lat`: the `String`-representation of the geolocation latitude, represented as `VARCHAR (255)`. Should be nullable to 
    allow for missing data.
- `long`: the `String`-representation of the geolocation longitude, represented as `VARCHAR (255)`. Should be nullable
        to allow for missing data.

# Station type data type
table name: `station_type`

Fields:

- `id`: the unique `UUID`.
- `name`: the name station type, as `VARCHAR (255) NOT NULL`.

Implementation remark:

This should be implemented as `enum` in the business logic. A `station_type` with name `UNKNOWN` should be implemented.

# Station data type
table name: `station`

Fields:

- `id`: the unique `UUID`.
- `name`: the name of the station, as `VARCHAR (255) NOT NULL`.
- `hospital_id`: the foreign key to the corresponding `hospital`. This database column should be indexed. Not nullable.
- `station_type_name`: the foreign key to the corresponding `station_type`. This database column should be indexed. Not 
    nullable.

# bed type data type
table name: `bed_type`

Fields:

- `id`: the unique `UUID`
- `name`: the name of the bed type, as `VARCHAR (255) NOT NULL`. This database column should be indexed.

Implementation remark:

This should be implemented as `enum` in the business logic.

# Bed type count data type
table name: `bed_type_count`

Fields:

- `id`: the unique `UUID`.
- `max_capacity`: the maximum bed count (accumulated) of this type in the corresponding station, represented as 
    `SMALLINT NOT NULL` and should always be `> 0`.
- `current_occupied`: the number of currently occupied beds (accumulated) of this type in the corresponding station, 
    represented as `SMALLINT NOT NULL` and should always be `>= 0` and `<= max_count`.
- `occupied_last_changed`: the UNIX-timestamp when the `current_occupied` attribute was last changed as 
    `BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW() * 1000)`.
- `station_id`: the foreign key to the corresponding `station`. This database column should be indexed. Not nullable.
- `bed_type_name`: the foreign key to the corresponding `bed_type`. This database column should be indexed. Not nullable.

Implementation detail:

The `occupied_last_changed` must always be updated when `current_occupied` is changed.

[datamodel]: datamodel.puml