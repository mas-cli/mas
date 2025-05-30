//
// Generated by https://github.com/blacktop/ipsw (Version: 3.1.603, BuildCommit: Homebrew)
//
// - LC_BUILD_VERSION:  Platform: macOS, MinOS: 15.5, SDK: 15.5, Tool: ld (1167.3)
// - LC_SOURCE_VERSION: 715.5.1.0.0
//

NS_ASSUME_NONNULL_BEGIN

@interface SSDownloadStatus : NSObject <NSSecureCoding>

+ (BOOL)supportsSecureCoding;

@property(readonly, nonatomic) SSDownloadPhase *activePhase;
@property(nonatomic, getter=isCancelled) BOOL cancelled;
@property(retain, nonatomic) NSError *error;
@property(nonatomic, getter=isFailed) BOOL failed;
@property(readonly, nonatomic, getter=isPausable) BOOL pausable;
@property(nonatomic, getter=isPaused) BOOL paused;
@property(readonly, nonatomic) float percentComplete;
@property(readonly, nonatomic) float phasePercentComplete;
@property(readonly, nonatomic) long long phaseTimeRemaining;
@property BOOL waiting;

- (instancetype)copyWithZone:(nullable struct _NSZone *)zone;
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (void)setOperationProgress:(SSOperationProgress *)progress;

@end

NS_ASSUME_NONNULL_END
