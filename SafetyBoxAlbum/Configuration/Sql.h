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
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createPictureSQL = @"CREATE TABLE 't_picture_video' ("
                                            @"'id'    INTEGER NOT NULL UNIQUE,"
                                            @"'name'    TEXT,"
                                            @"'path'    TEXT NOT NULL,"
                                            @"'type'    INTEGER DEFAULT 1,"
                                            @"'state'    INTEGER DEFAULT 1,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const createVersionSQL = @"CREATE TABLE 't_schema_migrations' ("
                                            @"'id' INTEGER NOT NULL UNIQUE,"
                                            @"'version' INTEGER NOT NULL UNIQUE,"
                                            @"'schema_migrations' TEXT,"
                                            @"PRIMARY KEY('id' AUTOINCREMENT)"
                                            @")";

static NSString *const InsertAlbumSQL = @"INSERT INTO t_album ('name') VALUES (?); ";

static NSString *const QueryLastestAlbumSQL = @"";
 

