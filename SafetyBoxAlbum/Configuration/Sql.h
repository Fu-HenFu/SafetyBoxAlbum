//
//  Sql.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//


//
//  Sql.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/31.
//

		
static NSString *const createAlbumSQL = @"CREATE TABLE 't_album' ("
                                        @"'id'    INTEGER NOT NULL UNIQUE,"
                                        @"'name'    TEXT,"
                                        @"'state'    INTEGER DEFAULT 1,"
                                        @"'type'    INTEGER DEFAULT 1, -- 1.普通相册;2.回收站\n"
                                        @"'photo_count' INTEGER DEFAULT 0,"
                                        @"PRIMARY KEY('id' AUTOINCREMENT)"
                                        @");";

static NSString *const createContactSQL = @"CREATE TABLE 't_contact' ("
                                            @"'id'   INTEGER NOT NULL UNIQUE,"
                                            @"'name'    TEXT,"
                                            @"'phone'    TEXT,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @");";
static NSString *const createEmployerSQL = @"CREATE TABLE 't_employer' ("
                                            @"'id'    INTEGER NOT NULL UNIQUE,"
                                            @"'nickname'    TEXT NOT NULL,"
                                            @"'avatar'    TEXT,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createFakeAlbumSQL = @"CREATE TABLE 't_fake_album' ("
                                            @"'id'    INTEGER NOT NULL UNIQUE,"
                                            @"'name'    TEXT,"
                                            @"'state'    INTEGER DEFAULT 1,"
                                            @"'album_name'    TEXT NOT NULL,"
                                            @"'album_id'    INTEGER NOT NULL DEFAULT 1,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createPictureSQL = @"CREATE TABLE 't_picture_video' ("
                                            @"'id'    INTEGER NOT NULL UNIQUE,"
                                            @"'name'    TEXT,"
                                            @"'path'    TEXT NOT NULL,"
                                            @"'thumb_path'  TEXT NOT NULL,"
                                            @"'type'    INTEGER DEFAULT 1,"
                                            @"'state'    INTEGER DEFAULT 1,"
                                            @"'album_name'    TEXT NOT NULL,"
                                            @"'album_id'    INTEGER NOT NULL DEFAULT 1,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createVersionSQL = @"CREATE TABLE 't_schema_migrations' ("
                                            @"'id' INTEGER NOT NULL UNIQUE,"
                                            @"'version' INTEGER NOT NULL UNIQUE,"
                                            @"'schema_migrations' TEXT,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const InsertAlbumSQL = @"INSERT INTO t_album (name, state, type) VALUES ('%@', %ld, %ld);";

static NSString *const UpdateAlbumPhotoCountSQL = @"UPDATE t_album SET photo_count = %ld WHERE id = %ld";
static NSString *const QueryLastestAlbumSQL = @"SELECT id, name, state, photo_count FROM t_album WHERE state = 1 ORDER BY id DESC LIMIT 1";
static NSString *const QueryAlbumSQL = @"SELECT * FROM t_album WHERE state = 1 ORDER BY type ASC;";
static NSString *const InsertPictureSQL = @"INSERT INTO t_picture_video (name, path, thumb_path, type, state, album_name, album_id) VALUES ('%@', '%@', '%@', %d, %d, '%@', %d);";
static NSString *const QueryPictureWithAlbumIdSQL = @"SELECT * FROM t_picture_video WHERE state = 1 AND album_id = %ld;";

