/*
 * PostCommentViewControllerTests.m
 * SocializeSDK
 *
 * Created on 9/7/11.
 * 
 * Copyright (c) 2011 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import "PostCommentViewControllerTests.h"
#import "PostCommentViewControllerForTest.h"
#import "CommentMapView.h"
#import "SocializeLocationManager.h"
#import "UIKeyboardListener.h"
#import "UILabel+FormatedText.h"
#import "Socialize.h"
#import <OCMock/OCMock.h>
#import "CommentsTableViewCell.h"
#import "SocializeGeocoderAdapter.h"

#define TEST_URL @"test_entity_url"
#define TEST_LOCATION @"some_test_loaction_description"

@interface PostCommentViewControllerTests()
@property (nonatomic,retain) SocializePostCommentViewController *postCommentViewController;
@end

@implementation PostCommentViewControllerTests
@synthesize postCommentViewController = _postCommentViewController;
@synthesize mockSocialize = _mockSocialize;
@synthesize mockLocationManager = _mockLocationManager;
- (void)setUp { 
    //MOCK LOCATION MANAGER
    self.mockLocationManager = [OCMockObject niceMockForClass: [SocializeLocationManager class]];        
    
    self.postCommentViewController = [[SocializePostCommentViewController alloc] initWithNibName:nil bundle:nil entityUrlString:TEST_URL keyboardListener:nil locationManager:self.mockLocationManager geocoderInfo:self.mockLocationManager];

    //MOCK SOCIALIZE OBJ
    self.mockSocialize = [OCMockObject niceMockForClass:[Socialize class]];
    self.postCommentViewController.socialize = self.mockSocialize;

    
}
// Run after each test method
- (void)tearDown { 
    [self.mockSocialize verify];
    [self.mockLocationManager verify];
    
    self.mockSocialize = nil;
    self.postCommentViewController = nil;

}


// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread
{
    return YES;
}

-(void)testInit
{
    id mockLocationManager = [OCMockObject niceMockForClass:[SocializeLocationManager class]];
    BOOL trueValue = YES;
    [[[mockLocationManager stub]andReturnValue:OCMOCK_VALUE(trueValue)]shouldShareLocation];
    [[mockLocationManager expect]setShouldShareLocation:YES];
    [[[mockLocationManager stub]andReturnValue:OCMOCK_VALUE(trueValue)]applicationIsAuthorizedToUseLocationServices];
    [[[mockLocationManager stub]andReturn:TEST_LOCATION]currentLocationDescription];
    
    
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:mockLocationManager];
    
    [[(id)controller.commentTextView expect]becomeFirstResponder];
    [[(id)controller.mapOfUserLocation expect]configurate];
    [[(id)controller.activateLocationButton expect]setImage:OCMOCK_ANY forState:UIControlStateNormal];
    [[(id)controller.activateLocationButton expect]setImage:OCMOCK_ANY forState:UIControlStateHighlighted];
    
    id mockSocialize = [OCMockObject mockForClass: [Socialize class]];
    BOOL retValue = YES;
    [[[mockSocialize stub]andReturnValue:OCMOCK_VALUE(retValue)] isAuthenticated];
    
    controller.socialize =  mockSocialize;
    
    [controller viewDidLoad];
    [controller viewWillAppear:YES];

    GHAssertNotNil(controller.view, nil);
    GHAssertEqualStrings(controller.title, @"New Comment", nil);
    GHAssertNotNil(controller.navigationItem.leftBarButtonItem, nil);
    GHAssertNotNil(controller.navigationItem.rightBarButtonItem, nil);
    
    [controller verify];
    [mockSocialize verify];
    
    [controller viewDidUnload];
    [controller release];
}

-(void)testCreateMethod
{
    UINavigationController* controller = [PostCommentViewControllerForTest createNavigationControllerWithPostViewControllerOnRootWithEntityUrl:TEST_URL andImageForNavBar:nil];
    GHAssertNotNil(controller, nil);
}

-(void)testactivateLocationButtonPressedWithVisibleKB
{
    id mockLocationManager = [OCMockObject mockForClass: [SocializeLocationManager class]];
    BOOL trueValue = YES;
    [[[mockLocationManager stub]andReturnValue:OCMOCK_VALUE(trueValue)]shouldShareLocation];
    
    id mockKbListener = [OCMockObject mockForClass: [UIKeyboardListener class]];
    [[[mockKbListener stub]andReturnValue:OCMOCK_VALUE(trueValue)]isVisible];
    
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:mockKbListener locationManager:mockLocationManager];
    
    [[(id)controller.commentTextView expect]resignFirstResponder];
    
    [controller activateLocationButtonPressed:nil]; 
   
    [controller verify];   
    [controller release];
}

-(void)testactivateLocationButtonPressedWithInvisibleKB
{
    id mockLocationManager = [OCMockObject mockForClass: [SocializeLocationManager class]];
    BOOL trueValue = YES;
    [[[mockLocationManager stub]andReturnValue:OCMOCK_VALUE(trueValue)]shouldShareLocation];
    
    id mockKbListener = [OCMockObject mockForClass: [UIKeyboardListener class]];
    BOOL falseValue = NO;
    [[[mockKbListener stub]andReturnValue:OCMOCK_VALUE(falseValue)]isVisible];
    
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:mockKbListener locationManager:mockLocationManager];
    
    [[(id)controller.commentTextView expect]becomeFirstResponder];
    
    [controller activateLocationButtonPressed:nil]; 
    
    [controller verify];   
    [controller release];
}

-(void)testdoNotShareLocationButtonPressed
{   
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:nil];

    [[(id)controller.commentTextView expect]becomeFirstResponder];
    [[(id)controller.locationText expect] text:@"Location will not be shared."  withFontName: @"Helvetica-Oblique"  withFontSize: 12.0 withColor:OCMOCK_ANY];
    
    [controller doNotShareLocationButtonPressed:nil]; 
    
    [controller verify];   
    [controller release];
}

-(void)testSendBtnPressedWithGeo
{
    id mockLocationManager = [OCMockObject mockForClass: [SocializeLocationManager class]];
    BOOL trueValue = YES;
    [[[mockLocationManager stub]andReturnValue:OCMOCK_VALUE(trueValue)]shouldShareLocation];
    
    id mockSocialize = [OCMockObject mockForClass:[Socialize class]];
    [[mockSocialize expect] createCommentForEntityWithKey:TEST_URL comment:OCMOCK_ANY longitude:OCMOCK_ANY latitude:OCMOCK_ANY];
    BOOL retValue = YES;
    [[[mockSocialize stub]andReturnValue:OCMOCK_VALUE(retValue)]isAuthenticatedWithFacebook];
    
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:mockLocationManager];
    controller.socialize = mockSocialize;
    
    [controller performSelector: @selector(sendButtonPressed:)withObject:nil];
    
    [controller verify];
    [mockSocialize verify];
    [controller release];    
}

-(void)testAuthorizationSkipped {
    id partialCommentMock = [OCMockObject partialMockForObject:self.postCommentViewController];
    [[partialCommentMock expect] createComment];
    
    [self.postCommentViewController performSelector:@selector(authorizationSkipped)withObject:nil]; 

    [partialCommentMock verify];
}
-(void)testButtonTestPressedWithFBAuth {
    //MOCK CREATE COMMENT METHOD
    id partialCommentMock = [OCMockObject partialMockForObject:self.postCommentViewController];
    [[partialCommentMock expect] createComment];
    
    //MOCK isAuthenticatedWithFacebook
    [[[self.mockSocialize expect] andReturnValue:[NSNumber numberWithBool:YES]] isAuthenticatedWithFacebook];

    //perform test
    [self.postCommentViewController performSelector:@selector(sendButtonPressed:)withObject:nil]; 

    //VERIFY MOCKS
    [partialCommentMock verify];
}
-(void)testButtonTestPressed
{
    id partialCommentMock = [OCMockObject partialMockForObject:self.postCommentViewController];
    
    //MOCK -(UINavigationController *)authViewController
    id mockNavController = [OCMockObject mockForClass:[UINavigationController class]];
    [[[partialCommentMock expect] andReturn:mockNavController] authViewController];
    
    //MOCK PRESENTMODAL METHOD
    [[partialCommentMock expect] presentModalViewController:mockNavController animated:YES];

    //MOCK isAuthenticatedWithFacebook
    [[[self.mockSocialize expect] andReturnValue:[NSNumber numberWithBool:NO]] isAuthenticatedWithFacebook];
    [Socialize storeFacebookAppId:@"1234"];
    
    //perform test
    [self.postCommentViewController performSelector:@selector(sendButtonPressed:)withObject:nil]; 
    
    //VERIFY    
    [partialCommentMock verify];
}

-(void)testSupportOrientation
{
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:nil];
    GHAssertTrue([controller shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait], nil);
    
    [controller release];
}

-(void)testEnableSendBtn
{
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:nil];

    id mockBtn = [OCMockObject niceMockForClass: [UIBarButtonItem class]];
    [[mockBtn expect] setEnabled:YES];
    controller.navigationItem.rightBarButtonItem = mockBtn;
  
    [[[(id)controller.commentTextView stub]andReturn: @"Sample text"] text];    

    [controller textViewDidChange: nil];
    
    [controller verify];
    [mockBtn verify];
    
    controller.navigationItem.rightBarButtonItem = nil;
     
    [controller release]; 
}

-(void)testDisableSendBtn
{
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:nil];
    
    id mockBtn = [OCMockObject niceMockForClass: [UIBarButtonItem class]];
    [[mockBtn expect] setEnabled:NO];
    controller.navigationItem.rightBarButtonItem = mockBtn;
    
    [[[(id)controller.commentTextView stub]andReturn: @""] text];    
    
    [controller textViewDidChange: nil];
    
    [controller verify];
    [mockBtn verify];
    
    controller.navigationItem.rightBarButtonItem = nil;
    
    [controller release]; 
}

- (void)testCommentCellLayout {
    CommentsTableViewCell *cell = [[CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setComment:@"Some Comment"];
    UILabel *testSummary = [[[UILabel alloc] initWithFrame:CGRectMake(58, 32, 254, 21)] autorelease];
    cell.summaryLabel = testSummary;
    [cell layoutSubviews];
    GHAssertTrue(CGRectEqualToRect(cell.frame, CGRectMake(0, 0, 320, 65)), @"Bad frame");
    
    [cell release];
}

-(void)testSupportLandscapeRotation
{
    PostCommentViewControllerForTest* controller = [[PostCommentViewControllerForTest alloc]initWithEntityUrlString:TEST_URL keyboardListener:nil locationManager:nil];
    GHAssertTrue([controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], nil);
}

-(void)testLandscapeLayout
{   
    SocializePostCommentViewController * controller = [[SocializePostCommentViewController alloc] initWithNibName:@"SocializePostCommentViewControllerLandscape" 
                                                                                                                 bundle:nil 
                                                                                                        entityUrlString:TEST_URL
                                                                                                       keyboardListener:nil 
                                                                                                        locationManager:nil
                                                                                                           geocoderInfo:[SocializeGeocoderAdapter class]
                                                             ];
    
    [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    
    int keyboardHeigth = 162;
    int viewWidth = 460;
    int viewHeight = 320;
    int aciviticontainerHeight = 39;
    CGRect expectedCommentFrame = CGRectMake(0,0, viewWidth, viewHeight - aciviticontainerHeight - keyboardHeigth);
    CGRect expectedActivityLocationFrame = CGRectMake(0, expectedCommentFrame.origin.y + expectedCommentFrame.size.height, viewWidth, aciviticontainerHeight);
    CGRect expectedMapContainerFrame = CGRectMake(0,viewHeight - keyboardHeigth, viewWidth, keyboardHeigth);
    
    GHAssertTrue(CGRectEqualToRect(expectedCommentFrame, controller.commentTextView.frame), nil);
    GHAssertTrue(CGRectEqualToRect(expectedActivityLocationFrame, controller.locationViewContainer.frame), nil);    
    GHAssertTrue(CGRectEqualToRect(expectedMapContainerFrame, controller.mapContainer.frame), nil);    
}

-(void)testPortraitLayout
{   
    SocializePostCommentViewController * controller = [[SocializePostCommentViewController alloc] initWithNibName:@"SocializePostCommentViewController" 
                                                                                                           bundle:nil 
                                                                                                  entityUrlString:TEST_URL
                                                                                                 keyboardListener:nil 
                                                                                                  locationManager:nil
                                                                                                     geocoderInfo:[SocializeGeocoderAdapter class]
                                                       ];
    
    [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    int keyboardHeigth = 216;
    int viewWidth = 320;
    int viewHeight = 460;
    int aciviticontainerHeight = 39;
    CGRect expectedCommentFrame = CGRectMake(0,0, viewWidth, viewHeight - aciviticontainerHeight - keyboardHeigth);
    CGRect expectedActivityLocationFrame = CGRectMake(0, expectedCommentFrame.origin.y + expectedCommentFrame.size.height, viewWidth, aciviticontainerHeight);
    CGRect expectedMapContainerFrame = CGRectMake(0,viewHeight - keyboardHeigth, viewWidth, keyboardHeigth);
    
    GHAssertTrue(CGRectEqualToRect(expectedCommentFrame, controller.commentTextView.frame), nil);
    GHAssertTrue(CGRectEqualToRect(expectedActivityLocationFrame, controller.locationViewContainer.frame), nil);    
    GHAssertTrue(CGRectEqualToRect(expectedMapContainerFrame, controller.mapContainer.frame), nil);    
}

@end
