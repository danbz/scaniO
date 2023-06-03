#include "ofApp.h"
/*
 Project Title: video slitscan camera for iOS
 Description:
 ©Daniel Buzzo 2022, 2023
 dan@buzzo.com
 http://buzzo.com
 https://github.com/danbz
 */

/*to do list
 add tap to focus?
 add controls for front back camera
 add exposure control?
 speed up code
 
 
 */
//--------------------------------------------------------------
void ofApp::setup(){	
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);//Set iOS to Orientation Landscape Right
    ofSetFrameRate(60);
    currdeviceID = 0;
    // grabber.setup(480, 360, OF_PIXELS_BGRA);
    grabber.setDeviceID(currdeviceID); // front facing camera
    //grabber.setup(1280, 720, OF_PIXELS_BGRA);
    grabber.setup(1280, 720);
    grabber.setDesiredFrameRate(60);
    
    //// slit scan
    // float aspectRatio = camHeight / camWidth;
    
    sWidth = ofGetWidth();
    sHeight = ofGetHeight();
    
    xSteps = ySteps = 0;
    speed = 1;
    scanStyle = 3; // start as push horizontal clock style
    scanName = "horizontal ribbon";
    b_radial = b_smooth = false;
    b_drawCam = false;
    
    camWidth =  grabber.getWidth();
    camHeight = grabber.getHeight();
    
    videoPixels.allocate(camWidth,camHeight, OF_PIXELS_RGB); // set up our pixel object to be the same size as our camera object
    videoTexture.allocate(videoPixels);
    // ofSetVerticalSync(true);
    ofSetBackgroundColor(0, 0, 0); // set the background colour to  black
    ofDisableSmoothing();
    ofxiOSDisableIdleTimer();
    b_screenGrab = false;
    camName = "main cam";
    pixels = grabber.getPixels();
    
    // gui
    screenShot.addListener(this,&ofApp::screenGrab);
    swapCam.addListener(this,&ofApp::swapCamera);
    
    // change default sizes for ofxGui so it's usable in small/high density screens
    ofxGuiSetFont("Questrial-Regular.ttf",20,true,true);
    ofxGuiSetTextPadding(4);
    ofxGuiSetDefaultWidth(400);
    ofxGuiSetDefaultHeight(36);
    gui.setup(scanName + " " + camName);
    gui.add(screenShot.setup("save image", 50, 50));
    gui.add(swapCam.setup("swap Camera", 50, 50));
    gui.add(frameRate.set( "speed", 60, 1, 120 ));
    //  gui.add(mainCam.set("b_main", true));
    // gui.add(screenSize.set("screenSize", ofToString(ofGetWidth()) + "x" + ofToString(ofGetHeight())));
    gui.setPosition(40, 20);
}

//--------------------------------------------------------------
void ofApp::update(){
    ofColor color;
    // float micLevel;
    int yHeight;
    ofSetFrameRate(frameRate);
    grabber.update();
    // update the video grabber object
    if (grabber.isFrameNew()){
        pixels = grabber.getPixels();
        pixels.mirror(true, true);
    }
    
    switch (scanStyle) {
        case 4: // scan horizontal
            for (int y=0; y<camHeight; y++ ) { // loop through all the pixels on a line
                color = pixels.getColor( xSteps, y); // get the pixels on line ySteps
                videoPixels.setColor(xSteps, y, color);
            }
            videoTexture.loadData(videoPixels);
            
            if ( xSteps >= camWidth ) {
                xSteps = 0; // if we are on the bottom line of the image then start at the top again
            }
            xSteps += speed; // step on to the next line. increase this number to make things faster
            break;
            
        case 1: // scan vertical
            for (int x=0; x<camWidth; x++ ) { // loop through all the pixels on a line
                color = pixels.getColor(x, ySteps); // get the pixels on line ySteps
                videoPixels.setColor(x, ySteps, color);
            }
            videoTexture.loadData(videoPixels);
            
            if ( ySteps >= camHeight ) {
                ySteps = 0; // if we are on the bottom line of the image then start at the top again
            }
            ySteps += speed; // step on to the next line. increase this number to make things faster
            break;
            
        case 3: // scan horizontal from centre
            //if (xSteps < camWidth){
            for (int y=0; y<camHeight; y++ ) { // loop through all the pixels on a line to draw new line at 0 in target image
                color = pixels.getColor( camWidth/2, y); // get the pixels on line ySteps
                videoPixels.setColor(1, y, color);
            }
            
            for (int x = camWidth; x>=0; x-= 1){
                for (int y=0; y<camHeight; y++ ) { // loop through all the pixels on a line
                    videoPixels.setColor(x, y, videoPixels.getColor( x-1, y )); // copy each pixel in the target to 1 pixel the right
                }
            }
            // }
            videoTexture.loadData(videoPixels);
            // xSteps++;
            break;
            
        case 2: // scan vertical from centre
            for (int x=0; x<camWidth; x++ ) { // loop through all the pixels on a line to draw new column at 0 in target image
                color = pixels.getColor(x, camHeight/2); // get the pixels on line ySteps
                videoPixels.setColor(x, 1, color);
            }
            
            for (int y = camHeight; y>=0; y-= 1){
                for (int x=0; x<camWidth; x++ ) { // loop through all the pixels on a column
                    videoPixels.setColor(x, y, videoPixels.getColor( x, y-1 )); // copy each pixel in the target to 1 pixel below
                }
            }
            videoTexture.loadData(videoPixels);
            break;
            
        case 5: // scan horizontal from centre with mic
            
            yHeight = camHeight ;
            ofPushStyle();
            ofSetColor(0, 0, 0, 5); // set transparent black to draw rect and fade pixel buffer;
            ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
            ofPopStyle();
            for (int y=0; y<yHeight; y++ ) { // loop through all the pixels on a line to draw new line at 0 in target image
                color = pixels.getColor( camWidth/2, y); // get the pixels on line ySteps
                videoPixels.setColor(1, y, color);
            }
            
            for (int x = camWidth; x>=0; x-= 1){
                for (int y=0; y<camHeight; y++ ) { // loop through all the pixels on a line
                    videoPixels.setColor(x, y, videoPixels.getColor( x-1, y )); // copy each pixel in the target to 1 pixel the right
                }
            }
            videoTexture.loadData(videoPixels);
            // xSteps++;
            break;
            
        default:
            break;
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofSetColor(255);
    videoTexture.draw( 0, 0, sWidth, sHeight); // draw the  slitscan video texture we have constructed
    
    //    if (b_drawCam){ // draw camera debug to screen
    //        grabber.draw(sWidth-camWidth/4 -10, sHeight-camHeight/4 -10, camWidth/4, camHeight/4); // draw our plain image
    //        ofDrawBitmapString(" scanning " + scanName + " , 1-scan horizontal 2-scan vertical 3-ribbon horizontal 4-ribbon vertical 5-slitscan clock, r-radial, c-camview, a-antialiased, FPS:" + ofToString(ofGetFrameRate()), 10, sHeight -10);
    //    }
    
    if (b_screenGrab) {
        //  screenGrab();
        // grab screen before GUI is drawn
        ofxiOSScreenGrab(0);
        b_screenGrab = false;
        ofSetColor(0);
        ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
    }
    
    //    ofPushStyle();
    //    ofSetColor(255, 0, 0 );
    //    ofDrawCircle(ofGetWidth()/2 -25 , ofGetHeight() - 45, 25); // draw screenshot button on screen
    //    ofPopStyle();
    ofDrawBitmapString("FPS: " + ofToString(ofGetFrameRate()) , 20, ofGetHeight()-20);    
    gui.draw();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    //  ofSetFrameRate( ofMap(touch.x ,0,  ofGetWidth(), 1, 120) );
    // newDeviceID =  abs (ofMap(touch.y ,0,  ofGetHeight(), 0, 1));
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //    if (touch.y >ofGetHeight()/2 && currdeviceID ==0){
    //        grabber.close();
    //        grabber.setup(camWidth, camHeight);
    //        currdeviceID = 1;
    //        grabber.setDeviceID(currdeviceID); // front facing camera
    //        ofSetColor(0);
    //        ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
    //        camName = "main camera";
    //    } else if (touch.y <ofGetHeight()/2 && currdeviceID ==1){
    //        grabber.close();
    //        grabber.setup(camWidth, camHeight);
    //        currdeviceID = 0;
    //        grabber.setDeviceID(currdeviceID); // front facing camera
    //        ofSetColor(0);
    //        ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
    //        camName = "front camera";
    //    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    //    if (scanStyle < 5 ){
    //        scanStyle ++;
    //    } else {
    //        scanStyle = 1;
    //    }
    //    switch (scanStyle) {
    //
    //        case '1':
    //            scanStyle = 1;
    //            scanName = "horizontal";
    //            break;
    //        case '2':
    //            scanStyle = 2;
    //            scanName = "vertical";
    //            break;
    //        case '3':
    //            scanStyle = 3;
    //            scanName = "horizontal ribbon";
    //            break;
    //        case '4':
    //            scanStyle = 4;
    //            scanName = "vertical ribbon";
    //            break;
    //        case '5':
    //            scanStyle = 5;
    //            scanName = "let's be a slitscan clock";
    //            currTime = ofGetSystemTimeMillis();
    //            break;
    //        case '6':
    //            b_drawCam =!b_drawCam;
    //            break;
    //        case '7':
    //            b_radial =!b_radial;
    //            break;
    //
    //        default:
    //            break;
    //    }
    // b_screenGrab = true;
    // saveToPhotos();
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    scanStyle = newOrientation;
    
    switch (scanStyle) {
        case 1:
            scanName = "vertical wipe";
            gui.setName(scanName + " " + camName);
            break;
            
        case 2:
            scanName = "vertical ribbon";
            gui.setName(scanName + " " + camName);
            break;
            
        case 3:
            scanName = "horizontal ribbon";
            gui.setName(scanName + " " + camName);
            break;
            
        case 4:
            scanName = "horizontal wipe";
            gui.setName(scanName + " " + camName);
            break;
            
        default:
            break;
    }
    cout << "orientation is now: " << ofToString( newOrientation ) << endl;
}
//--------------------------------------------------------------
void ofApp::saveToPhotos(){
    // ofFbo screen;
    ofImage photo;
    // screen.allocate(ofGetWidth(),ofGetHeight(),GL_RGBA);
    //    screen.begin();
    //    ofClear(0,0,0,255);
    //    ofSetColor(255,255,255,255);
    //  videoTexture
    //    screen.end();
    ofPixels pix;
    videoTexture.readToPixels(pix);
    photo.setFromPixels(pix);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, photo.getPixels().getData(), (photo.getWidth()*photo.getHeight() * 4), NULL);
    CGImageRef imageRef = CGImageCreate(photo.getWidth(), photo.getHeight(), 8, 32, 4*photo.getWidth(), CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, provider, NULL, NO, kCGRenderingIntentDefault);
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
    UIImage *output = [UIImage imageWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(output,nil,nil,nil);
}

//--------------------------------------------------------------
void ofApp::exit(){
    screenShot.removeListener(this,&ofApp::screenGrab);
    swapCam.removeListener(this,&ofApp::swapCamera);
}

//--------------------------------------------------------------
void ofApp::screenGrab(){
    ofxiOSScreenGrab(0);
    b_screenGrab = false;
    ofSetColor(0);
    ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
}

//--------------------------------------------------------------
void ofApp::swapCamera(){
    if (currdeviceID == 0){
        grabber.close();
        grabber.setup(camWidth, camHeight);
        currdeviceID = 1;
        grabber.setDeviceID(currdeviceID); // front facing camera
        ofSetColor(0);
        ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
        camName = "main cam";
    } else if ( currdeviceID ==1){
        grabber.close();
        grabber.setup(camWidth, camHeight);
        currdeviceID = 0;
        grabber.setDeviceID(currdeviceID); // front facing camera
        ofSetColor(0);
        ofDrawRectangle(0,0,ofGetWidth(), ofGetHeight());
        camName = "front cam";
    }
    gui.setName(scanName + " " + camName);
}
