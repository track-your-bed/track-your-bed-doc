CREATE EXTENSION "uuid-ossp";

CREATE TABLE public.hospital (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR (255) NOT NULL,
    max_capacity SMALLINT NOT NULL,
    lat VARCHAR (255),
    long VARCHAR (255)
);

CREATE TABLE public.station_type (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      name VARCHAR (255) NOT NULL
);

ALTER TABLE ONLY public.station_type
    ADD CONSTRAINT station_type_unique_name UNIQUE(name);

CREATE TABLE public.station (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR (255) NOT NULL,
    hospital_id UUID REFERENCES hospital(id) NOT NULL,
    station_type_name VARCHAR (255) REFERENCES station_type(name) NOT NULL
);

CREATE INDEX station_idx_hospital_id ON station USING btree(hospital_id);
CREATE INDEX station_idx_station_type_name ON station USING btree(station_type_name);

CREATE TABLE public.bed_type (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR (255)
);

ALTER TABLE ONLY public.bed_type
    ADD CONSTRAINT bed_type_unique_name UNIQUE(name);

CREATE INDEX bed_type_idx_name ON bed_type USING btree(name);


CREATE TABLE public.bed_type_count (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    max_capacity SMALLINT NOT NULL,
    current_occupied SMALLINT NOT NULL,
    occupied_last_changed BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM now()) *  1000,
    station_id UUID REFERENCES station(id) NOT NULL,
    bed_type_name UUID REFERENCES bed_type(name) NOT NULL
);

CREATE INDEX bed_type_count_idx_station_id ON bed_type_count USING btree(station_id);
CREATE INDEX bed_type_count_idx_bed_type_name ON bed_type_count USING btree(bed_type_name);

ALTER TABLE ONLY public.bed_type_count
    ADD CONSTRAINT bed_type_count_unique_station_id_bed_type_name UNIQUE(station_id, bed_type_name);

CREATE FUNCTION occupied_changed() RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.current_occupied != OLD.current_occupied THEN
        NEW.occupied_last_changed := EXTRACT(EPOCH FROM NOW()) * 1000;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_bed_type_count_occupeid_changed
    BEFORE UPDATE ON bed_type_count
    FOR EACH ROW
EXECUTE PROCEDURE occupied_changed();