
boolean serialConnected = false;  // whether connected to serial port host

// Sound
	int curVol    = 7;
	
	// pins:
	const int resetPin  = 0;  // The pin number of the reset pin. 0, 
	const int clockPin  = 3;  // The pin number of the clock pin. 3, 
	const int dataPin   = 4;  // The pin number of the data pin.  4, 
	const int busyPin   = 1;  // The pin number of the busy pin.  1, 
	
	#include <Wtv020sd16p.h>
	Wtv020sd16p wtv020sd16p(resetPin, clockPin, dataPin, busyPin);
	int oldVol    = curVol;
	int songNum 	= 1;
	int numPlayed = 0;  							// how many songs have played
	boolean soundOn           = false;
	boolean songStarted       = true;
	boolean firstSoundPlayed  = false;
	int secondsOfSound = 0;         	// total seconds of sound played

// Bean
	bool toUpdateDebug = false;       // whether to update teh debug scratch bank
	const int incomingBank = 2;

void setup() {
	// Sound:
  wtv020sd16p.reset();
  wtv020sd16p.setVol(curVol);
  wtv020sd16p.asyncPlayVoice(0);					// play sound without blocking

  // Bean:
  Bean.enableWakeOnConnect( true );

}

void loop() {
	// check if BLE connected, shutdown Arduino if not
  bool isConnected = Bean.getConnectionState();
  if(!isConnected) {
    // shut it down america!
    Bean.setLed(0,0,0);
    //digitalWrite(pulsePowerPin, LOW);	// TODO: check if wtv020 draws much power, if use DIO pin to control power
    Bean.sleep( 10000 );  //0xFFFFFFFF
  }
  else {
    //Bean.setLed(0,1,0);
    //}

  	// check for incoming BLE messages
    ScratchData incomingScratchData = Bean.readScratchData(incomingBank);
    if(incomingScratchData.data[0] != ' ') {
      Bean.setLed(40,2,1);                           // blink blue when command received
      if(incomingScratchData.data[0] == 'r') {        // ascii 'r' = 0x72
      	// trigger reward sound
        songNum = int(incomingScratchData.data[1]);   // get incoming byte
        wtv020sd16p.asyncPlayVoice(songNum);					// play sound without blocking
      }
      else if(incomingScratchData.data[0] == 'c') {   // ascii 'c' = 0x63
      	// trigger cue sound
      	songNum = int(incomingScratchData.data[1]);   // get incoming byte
      	wtv020sd16p.asyncPlayVoice(songNum);					// play sound without blocking

      	// FUTURE: also trigger accelerometer recording for about 5 seconds
    	}
      else if(incomingScratchData.data[0] == 'd') {   // ascii 'd' = 0x64
        toUpdateDebug ^= true;
      }
      else if(incomingScratchData.data[0] == 'v') {   // ascii 'v' = 0x76
        curVol = int(incomingScratchData.data[1]);   // get incoming byte
        wtv020sd16p.setVol(curVol);
      }

      // reset scratch characteristic
      uint8_t buffer[1] = { ' ' };  // create blank buffer
      Bean.setScratchData(incomingBank, buffer, 1);
    }
    else {
    	Bean.setLed(0,0,0);															// blink off
    }
  }

	// delay is required for Bean to not be f'd
  delay(1);
}