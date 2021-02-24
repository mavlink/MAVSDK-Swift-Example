//
//  VideoStreamPlayer.m
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 2/23/21.
//

#import "VideoStreamPlayer.h"

@interface VideoStreamPlayer ()
@end

@interface VideoStreamPlayer (private)
-(void)convertFrameToRGB;
-(UIImage *)imageFromAVFrame:(AVFrame*)frame width:(int)width height:(int)height;
-(void)saveFrame:(AVFrame*)frame width:(int)width height:(int)height index:(int)iFrame;
-(void)setupScaler;
@end

@implementation VideoStreamPlayer


@synthesize outputWidth, outputHeight;

- (void)setOutputWidth:(int)newValue
{
    if (outputWidth != newValue) {
        outputWidth = newValue;
        [self setupScaler];
    }
}

- (void)setOutputHeight:(int)newValue
{
    if (outputHeight != newValue) {
        outputHeight = newValue;
        [self setupScaler];
    }
}

- (UIImage *)currentImage
{
    if (outFrame == nil || !outFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVFrame: outFrame width: outFrame->width height: outFrame->height];
}

-(id)initWithVideoPath:(NSString *)videoPath usesTcp:(BOOL)usesTcp
{
    if (!(self=[super init])) return nil;
 
    AVCodec *codec;
    outFrame = av_frame_alloc();
//    av_log_set_level(AV_LOG_TRACE); // Uncomment for the most verbose logs
    avformat_network_init();
    
    // Set the RTSP Options
    AVDictionary *opts = 0;
    if (usesTcp) {
        av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    } else {
        av_dict_set(&opts, "rtsp_transport", "udp", 0);
    }
    
    if (avformat_open_input(&formatCtx, [videoPath UTF8String], 0, &opts) !=0 ) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
        goto initError;
    }
    
    // Retrieve stream information
    if (avformat_find_stream_info(formatCtx,NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
        goto initError;
    }
    
    // Find video stream index
    videoStreamIndex = av_find_best_stream(
              formatCtx,        // The media stream
              AVMEDIA_TYPE_VIDEO,   // The type of stream we are looking for - audio for example
              -1,                   // Desired stream number, -1 for any
              -1,                   // Number of related stream, -1 for none
              &codec,          // Gets the codec associated with the stream, can be NULL
              0                     // Flags - not used currently
              );
    if (videoStreamIndex == AVERROR_STREAM_NOT_FOUND || !codec) {
        NSLog(@"Did not find video stream");
        goto initError;
    }

    // Get the codec context
    codecCtx = avcodec_alloc_context3(codec);
    if (!codecCtx){
        // Out of memory
        avformat_close_input(&formatCtx);
    }

    // Set the parameters of the codec context from the stream
    int result = avcodec_parameters_to_context(
                                               codecCtx,
                                               formatCtx->streams[videoStreamIndex]->codecpar
                                               );
    if(result < 0){
        // Failed to set parameters
        avformat_close_input(&formatCtx);
        avcodec_free_context(&codecCtx);
        goto initError;
    }

    // Ready to open stream based on previous parameters
    // Third parameter (NULL) is optional dictionary settings
    if (avcodec_open2(codecCtx, codec, NULL) < 0){
        // Cannot open the video codec
        av_log(NULL, AV_LOG_ERROR, "Cannot open video decoder\n");
        codecCtx = NULL;
        goto initError;
    }

    outputWidth = codecCtx->width;
    outputHeight = codecCtx->height;
    [self setupScaler];
    return self;
    
initError:
    return nil;
}

- (void)setupScaler
{
    sws_freeContext(img_convert_ctx);
    
    // Respect aspect ratio of the original frame
    float k = (float)codecCtx->height / (float)codecCtx->width;
    if (outputHeight/outputWidth < k) {
        outFrame->width = (float)outputHeight / k;
        outFrame->height = outputHeight;
    } else {
        outFrame->width = outputWidth;
        outFrame->height = (float)outputWidth * k;
    }
    
    // Allocate RGB picture
    av_image_alloc(outFrame->data,
                   outFrame->linesize,
                   outFrame->width,
                   outFrame->height,
                   AV_PIX_FMT_RGB24,
                   1);

    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(codecCtx->width,
                                     codecCtx->height,
                                     codecCtx->pix_fmt,
                                     outFrame->width,
                                     outFrame->height,
                                     AV_PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

- (BOOL)stepFrame
{
    AVPacket packet;
    int frameFinished=0;
    av_init_packet(&packet); // set fields of packet to default.
    packet.data = NULL;
    packet.size = 0;


    while (!frameFinished && formatCtx != NULL && av_read_frame(formatCtx, &packet) >=0) {
        if (packet.stream_index==videoStreamIndex) {
            // Send the data packet to the decoder
            int sendPacketResult = avcodec_send_packet(codecCtx, &packet);
            if (sendPacketResult == AVERROR(EAGAIN)){
                NSLog(@"Decoder can't take packets right now. Make sure you are draining it.");
                // Decoder can't take packets right now. Make sure you are draining it.
            } else if (sendPacketResult < 0){
                // Failed to send the packet to the decoder
                NSLog(@"Failed to send the packet to the decoder");
            }

            // Get decoded frame from decoder
            av_frame_free(&frame);
            frame = av_frame_alloc();
            int decodeFrame = avcodec_receive_frame(codecCtx, frame);


            if (decodeFrame == AVERROR(EAGAIN)){
                // The decoder doesn't have enough data to produce a frame
                // Not an error unless we reached the end of the stream
                // Just pass more packets until it has enough to produce a frame
                NSLog(@"The decoder doesn't have enough data to produce a frame");
                av_frame_unref(frame);
                av_freep(frame);
            } else if (decodeFrame < 0){
                // Failed to get a frame from the decoder
                NSLog(@"Failed to get a frame from the decoder");
                av_frame_unref(frame);
                av_freep(frame);
            } else {
                frameFinished = 1;
            }
        }
    }
    av_packet_unref(&packet);

    return frameFinished!=0;
}

- (UIImage *)imageFromAVFrame:(AVFrame*)oFrame width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                 oFrame->data[0],
                                                 oFrame->linesize[0]*height,
                                                 kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       oFrame->linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}


- (void)convertFrameToRGB
{
    sws_scale(img_convert_ctx,
              (const uint8_t**)frame->data,
              frame->linesize,
              0,
              codecCtx->height,
              outFrame->data,
              outFrame->linesize);
}

- (void)dealloc
{
    NSLog(@"DEALLOC");
    
    // Free scaler
    sws_freeContext(img_convert_ctx);

    // Free the YUV frame
    av_frame_free(&frame);
    
    // Close the codec
    if (codecCtx) avcodec_close(codecCtx);
    
    // Close the video file
    if (formatCtx) {
        NSLog(@"Close the video file");
        avformat_close_input(&formatCtx);
    } else {
        NSLog(@"Close the video file failed");
    }
}

@end
