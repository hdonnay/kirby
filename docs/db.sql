PRAGMA writable_schema = 1;
DELETE FROM sqlite_master WHERE TYPE = 'table';
PRAGMA user_version = 9;
PRAGMA writable_schema = 0;
VACUUM;
PRAGMA INTEGRITY_CHECK;
CREATE TABLE comics ( id INTEGER PRIMARY KEY, cover BLOB, series TEXT, volume INT, issue INT, title TEXT, description TEXT );
CREATE TABLE nzb ( id INTEGER PRIMARY KEY, time INTEGER, releaseDate TEXT, origYear TEXT, tags TEXT, series TEXT, issue INT, url TEXT, hash TEXT );
CREATE TABLE history ( id INTEGER PRIMARY KEY, time INTEGER, name TEXT, issue INT, action TEXT );
CREATE TABLE meta ( id INTEGER PRIMARY KEY, time INTEGER, asset TEXT, hash TEXT );
