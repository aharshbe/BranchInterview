//
//  MonsterViewerViewController.m
//  BranchMonsterFactory
//
//  Created by Alex Austin on 9/6/14.
//  Copyright (c) 2014 Branch, Inc All rights reserved.
//

#import "NetworkProgressBar.h"
#import "MonsterViewerViewController.h"
#import "MonsterPartsFactory.h"
#import "MonsterPreferences.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MonsterViewerViewController () <MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) NetworkProgressBar *progressBar;

@property (strong, nonatomic) NSDictionary *monsterMetadata;

@property (strong, nonatomic) NSString *monsterName;
@property (strong, nonatomic) NSString *monsterDescription;

@property (weak, nonatomic) IBOutlet UIView *botLayerOneColor;
@property (weak, nonatomic) IBOutlet UIImageView *botLayerTwoBody;
@property (weak, nonatomic) IBOutlet UIImageView *botLayerThreeFace;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtDescription;

@property (weak, nonatomic) IBOutlet UIButton *cmdMessage;
@property (weak, nonatomic) IBOutlet UIButton *cmdMail;
@property (weak, nonatomic) IBOutlet UIButton *cmdTwitter;
@property (weak, nonatomic) IBOutlet UIButton *cmdFacebook;

@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@property (weak, nonatomic) IBOutlet UIButton *cmdChange;

@end

@implementation MonsterViewerViewController

static CGFloat MONSTER_HEIGHT = 0.4f;
static CGFloat MONSTER_HEIGHT_FIVE = 0.55f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.botLayerOneColor setBackgroundColor:[MonsterPartsFactory colorForIndex:[MonsterPreferences getColorIndex]]];
    [self.botLayerTwoBody setImage:[MonsterPartsFactory imageForBody:[MonsterPreferences getBodyIndex]]];
    [self.botLayerThreeFace setImage:[MonsterPartsFactory imageForFace:[MonsterPreferences getFaceIndex]]];
    
    self.monsterName = [MonsterPreferences getMonsterName];
    self.monsterDescription = [MonsterPreferences getMonsterDescription];
    
    [self.txtName setText:self.monsterName];
    [self.txtDescription setText:self.monsterDescription];
    
    [self.urlTextView setTextColor:[UIColor blackColor]];
    
    self.monsterMetadata = [[NSDictionary alloc]
                            initWithObjects:@[
                                              [NSNumber numberWithInteger:[MonsterPreferences getColorIndex]],
                                              [NSNumber numberWithInteger:[MonsterPreferences getBodyIndex]],
                                              [NSNumber numberWithInteger:[MonsterPreferences getFaceIndex]],
                                              self.monsterName]
                            forKeys:@[
                                      @"color_index",
                                      @"body_index",
                                      @"face_index",
                                      @"monster_name"]];
    
    [self.cmdChange.layer setCornerRadius:3.0];
    
    self.progressBar = [[NetworkProgressBar alloc] initWithFrame:self.view.frame andMessage:@"preparing your Branchster.."];
    [self.progressBar show];
    [self.view addSubview:self.progressBar];
    
    // #8 TODO: track that the user viewed the monster view page
    
    // #9 TODO: load a URL just for display on the viewer page
    self.urlTextView.text = @"";
    [self.progressBar hide];
}

- (IBAction)cmdChangeClick:(id)sender {
    if ([[self.navigationController viewControllers] count] > 1)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController setViewControllers:@[[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MonsterCreatorViewController"]] animated:YES];
}


- (NSDictionary *)prepareFBDict:(NSString *)url {
    return [[NSDictionary alloc] initWithObjects:@[
                                                   [NSString stringWithFormat:@"My Branchster: %@", self.monsterName],
                                                   self.monsterDescription,
                                                   self.monsterDescription,
                                                   url,
                                                   [NSString stringWithFormat:@"https://s3-us-west-1.amazonaws.com/branchmonsterfactory/%hd%hd%hd.png", (short)[MonsterPreferences getColorIndex], (short)[MonsterPreferences getBodyIndex], (short)[MonsterPreferences getFaceIndex]]]
                                         forKeys:@[
                                                   @"name",
                                                   @"caption",
                                                   @"description",
                                                   @"link",
                                                   @"picture"]];
}

// This function serves to dynamically generate the dictionary parameters to embed in the Branch link
// These are the parameters that will be available in the callback of init user session if
// a user clicked the link and was deep linked
- (NSDictionary *)prepareBranchDict {
    return [[NSDictionary alloc] initWithObjects:@[
                                                  [NSNumber numberWithInteger:[MonsterPreferences getColorIndex]],
                                                  [NSNumber numberWithInteger:[MonsterPreferences getBodyIndex]],
                                                  [NSNumber numberWithInteger:[MonsterPreferences getFaceIndex]],
                                                  self.monsterName,
                                                  @"true",
                                                  [NSString stringWithFormat:@"My Branchster: %@", self.monsterName],
                                                  self.monsterDescription,
                                                  [NSString stringWithFormat:@"https://s3-us-west-1.amazonaws.com/branchmonsterfactory/%hd%hd%hd.png", (short)[MonsterPreferences getColorIndex], (short)[MonsterPreferences getBodyIndex], (short)[MonsterPreferences getFaceIndex]]]
                                        forKeys:@[
                                                  @"color_index",
                                                  @"body_index",
                                                  @"face_index",
                                                  @"monster_name",
                                                  @"monster",
                                                  @"$og_title",
                                                  @"$og_description",
                                                  @"$og_image_url"]];
}

- (void)viewDidLayoutSubviews {
    [self adjustMonsterPicturesForScreenSize];
}

- (void)adjustMonsterPicturesForScreenSize {
    [self.botLayerOneColor setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.botLayerTwoBody setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.botLayerThreeFace setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.txtDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cmdChange setTranslatesAutoresizingMaskIntoConstraints:NO];

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat widthRatio = self.botLayerOneColor.frame.size.width/self.botLayerOneColor.frame.size.height;
    CGFloat newHeight = screenSize.size.height;
    if (IS_IPHONE_5)
        newHeight = newHeight * MONSTER_HEIGHT_FIVE;
    else
        newHeight = newHeight * MONSTER_HEIGHT;
    CGFloat newWidth = widthRatio * newHeight;
    CGRect newFrame = CGRectMake((screenSize.size.width-newWidth)/2, self.botLayerOneColor.frame.origin.y, newWidth, newHeight);
    
    self.botLayerOneColor.frame = newFrame;
    self.botLayerTwoBody.frame = newFrame;
    self.botLayerThreeFace.frame = newFrame;
    
    CGRect textFrame = self.txtDescription.frame;
    textFrame.origin.y  = newFrame.origin.y + newFrame.size.height + 8;
    self.txtDescription.frame = textFrame;
    
    CGRect cmdFrame = self.cmdChange.frame;
    if (IS_IPHONE_5)
        cmdFrame.origin.x = newFrame.origin.x + newFrame.size.width - cmdFrame.size.width/2;
    else
        cmdFrame.origin.x = newFrame.origin.x + newFrame.size.width;
    self.cmdChange.frame = cmdFrame;
    [self.view layoutSubviews];
}

- (IBAction)cmdMessageClick:(id)sender {
    // track that the user clicked the share via sms button and pass in the monster meta data
    
    if([MFMessageComposeViewController canSendText]){
        [self.progressBar changeMessageTo:@"preparing message.."];
        [self.progressBar show];
        
        MFMessageComposeViewController *smsViewController = [[MFMessageComposeViewController alloc] init];
        smsViewController.messageComposeDelegate = self;
        
        // Create Branch link as soon as the user clicks
        // Pass in the special Branch dictionary of keys/values you want to receive in the AppDelegate on initSession
        // Specify the channel to be 'sms' for tracking on the Branch dashboard
        [self.progressBar hide];
        
        NSString *url = @"http://example.com"; // TODO: Remove when Branch is added
        smsViewController.body = [NSString stringWithFormat:@"Check out my Branchster named %@ at %@", self.monsterName, url];
        [self presentViewController:smsViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert_Dialog = [[UIAlertView alloc] initWithTitle:@"No Message Support" message:@"This device does not support messaging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert_Dialog show];
        alert_Dialog = nil;
    }

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    if (MessageComposeResultSent == result) {
        
        // track successful share event via sms
//        [[Branch getInstance] userCompletedAction:@"share_sms_success"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
