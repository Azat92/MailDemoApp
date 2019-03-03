//
//  YapDatabase+Swift.h
//  MailDemoApp
//
//  Created by Azat Almeev on 03/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseAutoView.h>
#import <YapDatabase/YapDatabaseViewTypes.h>
#import <YapDatabase/YapDatabaseRelationship.h>
#import <YapDatabase/YapDatabaseRelationshipEdge.h>

NS_ASSUME_NONNULL_BEGIN

@interface YapDatabase (Swift)

+ (NSString *)dbModifiedNotification;

@end

NS_ASSUME_NONNULL_END
