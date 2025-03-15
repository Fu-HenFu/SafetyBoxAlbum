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
#define ValuableState 1

#define DeleteToGarbageNotification @"DeleteToGarbageNotification"
#define DeleteToGarbageNotificationCountKey @"DeleteToGarbageNotificationCountKey"

#define ChangeLastestPhotoNotification @"ChangeLastestPhotoNotification"
#define ChangeLastestPhotoNotificationKey @"ChangeLastestPhotoNotificationKey"

typedef enum : NSUInteger {
    PICTURE_TYPE = 1,
    AUDIO_TYPE,
} PICTURE_AUDIO_TYPE;

typedef enum : NSUInteger {
    USELESS_STATE_TYPE = 0,
    USEFUL_STATE_TYPE,
} STATE_TYPE;

typedef enum : NSUInteger {
    IS_FAKE = 0,
    NOT_FAKE,
} FAKE_TYPE;



