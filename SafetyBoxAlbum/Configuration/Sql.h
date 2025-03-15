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
                                        @"'fake_type'   INTEGER DEFAULT 1, -- 1.正常状态;2.假状态\n"
                                        @"'photo_count' INTEGER DEFAULT 0,"
                                        @"'lastest_image_path'    TEXT,"
                                        @"'update_time'    INTEGER DEFAULT 0,"
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
                                            @"'update_time'    INTEGER DEFAULT 0,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createPictureSQL = @"CREATE TABLE 't_picture_video' ("
                                            @"'id'    INTEGER NOT NULL UNIQUE,"
                                            @"'name'    TEXT,"
                                            @"'path'    TEXT NOT NULL,"
                                            @"'thumb_path'  TEXT NOT NULL,"
                                            @"'type'    INTEGER DEFAULT 1,"
                                            @"'fake_type'   INTEGER DEFAULT 1, -- 1.正常状态;2.假状态\n"
                                            @"'state'    INTEGER DEFAULT 1,"
                                            @"'album_name'    TEXT NOT NULL,"
                                            @"'update_time'    INTEGER DEFAULT 0,"
                                            @"'album_id'    INTEGER NOT NULL DEFAULT 1,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createVersionSQL = @"CREATE TABLE 't_schema_migrations' ("
                                            @"'id' INTEGER NOT NULL UNIQUE,"
                                            @"'version' INTEGER NOT NULL UNIQUE,"
                                            @"'schema_migrations' TEXT,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";
//  t_album
static NSString *const InsertAlbumSQL = @"INSERT INTO t_album (name, state, type) VALUES ('%@', %ld, %ld);";

static NSString *const UpdateAlbumPhotoCountSQL = @"UPDATE t_album SET photo_count = %ld WHERE id = %ld";
static NSString *const QueryLastestAlbumSQL = @"SELECT id, name, state, photo_count, lastest_image_path FROM t_album WHERE state = 1 ORDER BY id DESC LIMIT 1";
static NSString *const QueryAlbumSQL = @"SELECT * FROM t_album WHERE state = 1 ORDER BY type ASC;";
static NSString *const QueryAlbumPhotoCount = @"SELECT photo_count FROM t_album WHERE id = %d";
static NSString *const UpdateAlbumLastestImagePath = @"UPDATE t_album SET lastest_image_path = '%@' WHERE id = %d";



//  t_picture_video
static NSString *const InsertPictureSQL = @"INSERT INTO t_picture_video (name, path, thumb_path, type, state, album_name, album_id, update_time) VALUES ('%@', '%@', '%@', %d, %d, '%@', %d, %ld);";
static NSString *const QueryPictureWithAlbumIdSQL = @"SELECT * FROM t_picture_video WHERE state = %ld AND album_id = %ld ORDER BY update_time ASC, id ASC;";
static NSString *const UpdatePictureBelongAlbumSQL = @"UPDATE t_picture_video SET album_id = %d , album_name = '%@', update_time = %ld WHERE id = %d";
static NSString *const UpdatePictureStateSQL = @"UPDATE t_picture_video SET state = %ld, update_time = %ld WHERE id = %ld";
static NSString *const QueryGarbagePictureSQL = @"SELECT * FROM t_picture_video WHERE state = %ld AND fake_type = %ld ORDER BY update_time ASC, id ASC;";


// alter table
static NSString *const AlterTablePictureVideoSQL = @"ALTER TABLE t_picture_video ADD COLUMN fake_type INTEGE  DEFAULT 1;";
static NSString *const AlterTableAlbumSQL = @"ALTER TABLE t_album ADD COLUMN fake_type INTEGE  DEFAULT 1;";
		
