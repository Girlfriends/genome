import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;
import java.util.*;
import gfbeats.*;

OscP5 oscP5;
NetAddress remoteLocation;
PGraphics canvas;
SyphonServer server;

float boxHeight = 71.3f;
float boxMargin = 5.0;
float patternSpacing = 10.0f;

ArrayList<BeatCollection> pulseRows = new ArrayList<BeatCollection>(0);
ArrayList<BeatCollection> accentRows = new ArrayList<BeatCollection>(0);
int BEAT_ROWS_MAX = 10;

int pulseCursorPosition = 0;
int accentCursorPosition = 0;

public void settings() {
  size(341,768, P3D);
  PJOGL.profile=1;
}

public void setup() {
  canvas = createGraphics(341, 768, P3D);
  frameRate(25);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12002);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  remoteLocation = new NetAddress("127.0.0.1",12002);
  
  oscP5.plug(this, "newRow", "/newRow");
  oscP5.plug(this, "setFunctionName", "/setFunctionName");
  oscP5.plug(this, "setLength", "/setLength");
  oscP5.plug(this, "setEvent", "/setEvent");
  oscP5.plug(this, "setCursor", "/setCursor");
  oscP5.plug(this, "clearAllBeats", "/clearAll");
  
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "processing-syphon");
}

// ------------------------  Draw  -------------------------------//

private void drawHelper(PGraphics canvas, ArrayList<BeatCollection> beatRows, int playheadPosition, float xoffset, float colWidth) {
  for (int i = 0; i < beatRows.size(); i++) {
    ArrayList<Beat> beats = beatRows.get(i).beats;
    float boxWidth = ((colWidth -boxMargin)/ beats.size()) - boxMargin;
    for (int j = 0; j < beats.size(); j++) {
      float boxPositionX = boxMargin + (boxWidth+boxMargin)*j + xoffset;
      float boxPositionY = boxMargin + (boxHeight+boxMargin)*i;
      
      if (beats.get(j).type == BeatType.ON) {
        canvas.fill(0, 0, 0);
      }
      else {
        canvas.fill(255, 255, 255);
      }
      canvas.rect(boxPositionX, height-(boxPositionY + boxHeight), boxWidth, boxHeight);
    }
    if (i == 0) {
      canvas.noStroke();
      canvas.fill(255, 0, 0, 127);
      canvas.rect(boxMargin + (boxWidth+boxMargin)*playheadPosition + xoffset, height-(boxMargin + boxHeight), boxWidth, boxHeight);
    }
  }
}

public void draw() {
  canvas.beginDraw();
  canvas.noStroke();
  canvas.background(127);
  canvas.lights();
  drawHelper(canvas, pulseRows, pulseCursorPosition, 0, (width - patternSpacing)/2.0f);
  drawHelper(canvas, accentRows, accentCursorPosition, (width + patternSpacing)/2.0f, (width - patternSpacing)/2.0f);
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

// ------------------------  OSC  --------------------------------//

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.isPlugged()==false) {
    /* print the address pattern and the typetag of the received OscMessage */
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
}

private void newRowHelper(ArrayList<BeatCollection> dest) {
  BeatCollection beatCollection = new BeatCollection();
  dest.add(0, beatCollection);
  if (dest.size() > BEAT_ROWS_MAX) {
    dest.remove(BEAT_ROWS_MAX); 
  }
}

public void newRow() {
  newRowHelper(pulseRows);
  newRowHelper(accentRows);
}

public void setFunctionName(String functionName) {  
  println("Function name: " + functionName);
}

public void setLength(int destIdx, int len) {
  ArrayList<BeatCollection> dest = destIdx == 0 ? pulseRows : accentRows;
  dest.get(0).initializeBeatLength(len);
}

public void setEvent(int destIdx, int index, int type) {
  ArrayList<BeatCollection> dest = destIdx == 0 ? pulseRows : accentRows;
  dest.get(0).beats.get(index).setType(BeatType.values()[type]);
}

public void setCursor(int destIdx, int index) {
  if (destIdx == 0)
    pulseCursorPosition = index;
  else
    accentCursorPosition = index;
}

public void clearAllBeats() {
   pulseRows.clear();
   accentRows.clear();
   pulseCursorPosition = 0;
   accentCursorPosition = 0;
}