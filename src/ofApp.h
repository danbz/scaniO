/*
 Project Title: video slitscan camera for iOS ScaniO
 Description:
 ©Daniel Buzzo 2022
 dan@buzzo.com
 http://buzzo.com
 https://github.com/danbz
 */


#pragma once

#include "ofxiOS.h"

class ofApp : public ofxiOSApp{
	
	public:
		void setup();
		void update();
		void draw();
		void exit();
	
		void touchDown(ofTouchEventArgs & touch);
		void touchMoved(ofTouchEventArgs & touch);
		void touchUp(ofTouchEventArgs & touch);
		void touchDoubleTap(ofTouchEventArgs & touch);
		void touchCancelled(ofTouchEventArgs & touch);

		void lostFocus();
		void gotFocus();
		void gotMemoryWarning();
		void deviceOrientationChanged(int newOrientation);

    void saveToPhotos();
    
    //ofVideoGrabber grabber;
    ofxiOSVideoGrabber grabber;
    
    // /slit scan materials
    ofPixels videoPixels, pixels;
    ofTexture videoTexture;
    
    int xSteps, ySteps, scanStyle, speed, currdeviceID, newDeviceID;
    int sWidth, sHeight;
    bool b_radial, b_drawCam, b_smooth, b_screenGrab;
    float currTime, camWidth, camHeight;
    string scanName, time, camName;
    
};


