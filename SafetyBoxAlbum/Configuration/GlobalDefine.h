//
//  GlobalDefine.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#define ST_DOCUMENT_DIRECTORY NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define ST_APP_NAME    ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define ST_APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define ST_APP_BUILD   ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

