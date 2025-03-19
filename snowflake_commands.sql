CREATE DATABASE S3_CONNECTION;
CREATE SCHEMA S3_CONNECTION_SCHEMA;

create storage integration S3_integration
    type = external_stage
    storage_provider = s3
    storage_aws_role_arn = 'xxx'
    enabled = true
    storage_allowed_locations = ( 's3://spotify-etl-project-naveenmano/' )
    comment = 'Connection to S3 bucket';


DESC INTEGRATION S3_integration;

CREATE OR REPLACE FILE FORMAT csv_file_format
    type = csv
    field_delimiter = ','
    field_optionally_enclosed_by = '"',
    record_delimiter = '\n',
    escape = '\\'
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

CREATE OR REPLACE stage S3_stage
    URL = 's3://spotify-etl-project-naveenmano/'
    STORAGE_INTEGRATION = s3_integration
    FILE_FORMAT = csv_file_format;
    
LIST @S3_stage;

CREATE OR REPLACE TABLE album_data (
    album_id VARCHAR PRIMARY KEY,
    album_name VARCHAR,
    album_release_date DATE,
    album_total_tracks INTEGER,
    album_url VARCHAR);
    

CREATE OR REPLACE PIPE album_data_pipe
    auto_ingest = TRUE
    AS 
    COPY INTO album_data
    FROM @S3_stage/transformed_data/album_data/; 

DESC pipe album_data_pipe;


COPY INTO album_data
    FROM @S3_stage/transformed_data/album_data/;

CREATE OR REPLACE TABLE song_data (
    song_id VARCHAR PRIMARY KEY,
    song_name VARCHAR,
    duration_ms INTEGER,
    url VARCHAR,
    popularity INTEGER,
    song_added DATE,
    album_id VARCHAR,
    artist_id VARCHAR);

COPY INTO song_data
    FROM @S3_stage/transformed_data/song_data/;

CREATE OR REPLACE PIPE song_data_pipe
    auto_ingest = TRUE
    AS 
    COPY INTO song_data
    FROM @S3_stage/transformed_data/song_data/; 

DESC pipe song_data_pipe;


CREATE OR REPLACE TABLE artist_data (
    artist_id VARCHAR PRIMARY KEY,
    artist_name VARCHAR,
    external_url VARCHAR);

COPY INTO artist_data
    FROM @S3_stage/transformed_data/artist_data/;

CREATE OR REPLACE PIPE artist_data_pipe
    auto_ingest = TRUE
    AS 
    COPY INTO artist_data
    FROM @S3_stage/transformed_data/artist_data/; 
    
DESC pipe artist_data_pipe;



SELECT * FROM album_data;

SELECT * FROM artist_data;

SELECT * FROM song_data;

