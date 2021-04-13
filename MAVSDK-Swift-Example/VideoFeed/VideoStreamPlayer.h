//
//  VideoStreamPlayer.h
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 2/23/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libswscale/swscale.h>

@interface VideoStreamPlayer : NSObject {
    AVFormatContext *formatCtx;
    AVCodecContext *codecCtx;
    AVFrame *frame;
    AVFrame *outFrame;
    int videoStreamIndex;
    struct SwsContext *img_convert_ctx;
    UIImage *currentImage;
    int sourceWidth, sourceHeight;
    int outputWidth, outputHeight;
}

/* Last decoded video frame as UIImage */
@property (nonatomic, readonly) UIImage *currentImage;

/* Size of video frame */
@property (nonatomic, readonly) int sourceWidth, sourceHeight;

/* Output image size. Set to the source size by default. */
@property (nonatomic) int outputWidth, outputHeight;

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
-(id)initWithVideoPath:(NSString *)moviePath usesTcp:(BOOL)usesTcp;

/* Read the next frame from the video stream. Returns false if no frame read (video over). */
-(BOOL)stepFrame;

@end
