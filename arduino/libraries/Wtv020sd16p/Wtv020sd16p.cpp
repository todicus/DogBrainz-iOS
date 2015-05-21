/*
  Wtv020sd16p.cpp - Library to control a WTV020-SD-16P module to play voices from an Arduino board.
  Created by Diego J. Arevalo, August 6th, 2012.
  Released into the public domain.
 
  Mod TA for volume control
*/

#include "Arduino.h"
#include "Wtv020sd16p.h"

const unsigned int PLAY_PAUSE = 0xFFFE;
const unsigned int STOP = 0xFFFF;
const unsigned int VOLUME_MIN = 0xFFF0;
const unsigned int VOLUME_1 = 0xFFF1;
const unsigned int VOLUME_2 = 0xFFF2;
const unsigned int VOLUME_3 = 0xFFF3;
const unsigned int VOLUME_4 = 0xFFF4;
const unsigned int VOLUME_5 = 0xFFF5;
const unsigned int VOLUME_6 = 0xFFF6;
const unsigned int VOLUME_MAX = 0xFFF7;

Wtv020sd16p::Wtv020sd16p(int resetPin, int clockPin, int dataPin, int busyPin)
{
  _resetPin = resetPin;
  _clockPin = clockPin;
  _dataPin  = dataPin;
  _busyPin  = busyPin;
  _busyPinState = HIGH;
  pinMode(_resetPin, OUTPUT);
  pinMode(_clockPin, OUTPUT);
  pinMode(_dataPin, OUTPUT);
  pinMode(_busyPin, INPUT);
}

void Wtv020sd16p::reset(){
  digitalWrite(_clockPin, LOW);
  digitalWrite(_resetPin, HIGH);
  //Reset pulse.
  digitalWrite(_resetPin, LOW);
  delay(5);
  digitalWrite(_resetPin, HIGH);
  //Reset idle to start bit. 
  digitalWrite(_clockPin, HIGH);
  delay(750);
}

void Wtv020sd16p::playVoice(int voiceNumber){  
  sendCommand(voiceNumber);
  
  // wait for busy pin to go low
  _busyPinState = digitalRead(_busyPin);
  while(_busyPinState == HIGH){
    _busyPinState = digitalRead(_busyPin);
  }
}

void Wtv020sd16p::asyncPlayVoice(int voiceNumber){
  sendCommand(voiceNumber);
}

void Wtv020sd16p::stopVoice(){
  sendCommand(STOP);
}

void Wtv020sd16p::pauseVoice(){
  sendCommand(PLAY_PAUSE);
}

void Wtv020sd16p::mute(){
  sendCommand(VOLUME_MIN);
}

void Wtv020sd16p::unmute(){
  sendCommand(VOLUME_MAX);
}

void Wtv020sd16p::setVol(int level){
  if(level == 0)
    sendCommand(VOLUME_MIN);
  else if(level == 1)
    sendCommand(VOLUME_1);
  else if(level == 2)
    sendCommand(VOLUME_2);
  else if(level == 3)
    sendCommand(VOLUME_3);
  else if(level == 4)
    sendCommand(VOLUME_4);
  else if(level == 5)
    sendCommand(VOLUME_5);
  else if(level == 6)
    sendCommand(VOLUME_6);
  else if(level == 7)
  	sendCommand(VOLUME_MAX);
}

void Wtv020sd16p::sendCommand(unsigned int command) {
  //Start bit Low level pulse.
  digitalWrite(_clockPin, LOW);
  delay(2);
  for (unsigned int mask = 0x8000; mask > 0; mask >>= 1) {
    //Clock low level pulse.
    digitalWrite(_clockPin, LOW);
    delayMicroseconds(50);
    //Write data setup.
    if (command & mask) {
      digitalWrite(_dataPin, HIGH);
    }
    else {
      digitalWrite(_dataPin, LOW);
    }
    //Write data hold.
    delayMicroseconds(50);
    //Clock high level pulse.
    digitalWrite(_clockPin, HIGH);
    delayMicroseconds(100);
    if (mask>0x0001){
      //Stop bit high level pulse.
      delay(2);      
    }
  }
  //Busy active high from last data bit latch.
  delay(50); // DW: changed from 20 due to looping issues. ref https://www.sparkfun.com/products/11125 member 395251
}
