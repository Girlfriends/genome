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


ArrayList<BeatCollection> beatRows = new ArrayList<BeatCollection>(0);
int BEAT_ROWS_MAX = 10;

public int playheadPosition = 0;

public void settings() {
  size(341,768, P3D);
  PJOGL.profile=1;
}

public void setup() {
  canvas = createGraphics(341, 768, P3D);
  frameRate(25);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12001);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  remoteLocation = new NetAddress("127.0.0.1",12001);
  
  oscP5.plug(this, "newBeat", "/newBeat");
  oscP5.plug(this, "setPatternLength", "/setPatternLength");
  oscP5.plug(this, "setPulse", "/setPulse");
  oscP5.plug(this, "setPlayhead", "/setPlayhead");
  oscP5.plug(this, "clear", "/clearAllBeats");
  
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "processing-syphon");
}

public void draw() {
  canvas.beginDraw();
  canvas.noStroke();
  canvas.background(127);
  canvas.lights();
  for (int i = 0; i < beatRows.size(); i++) {
    ArrayList<Beat> beats = beatRows.get(i).beats;
    float boxWidth = ((width -boxMargin)/ beats.size()) - boxMargin;
    for (int j = 0; j < beats.size(); j++) {
      float boxPositionX = boxMargin + (boxWidth+boxMargin)*j;
      float boxPositionY = boxMargin + (boxHeight+boxMargin)*i;
      
      if (beats.get(j).type == BeatType.ON) {
        canvas.fill(210, 180, 0);
      } else if (beats.get(j).type == BeatType.ACCENTED) {
        canvas.fill(216, 30, 10);
      } else {
        canvas.fill(255, 255, 255);
      }
      canvas.rect(boxPositionX, height-(boxPositionY + boxHeight), boxWidth, boxHeight);
    }
    if (i == 0) {
      canvas.noStroke();
      canvas.fill(255, 0, 0, 127);
      canvas.rect(boxMargin + (boxWidth+boxMargin)*playheadPosition, height-(boxMargin + boxHeight), boxWidth, boxHeight);
    }
  }
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.isPlugged()==false) {
    /* print the address pattern and the typetag of the received OscMessage */
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
  }
}

public void newBeat() {
  BeatCollection beatCollection = new BeatCollection();
  beatRows.add(0, beatCollection);
  if (beatRows.size() > BEAT_ROWS_MAX) {
    beatRows.remove(BEAT_ROWS_MAX); 
  }
}

public void setPatternLength(int patternLength) {  
  beatRows.get(0).initializeBeatLength(patternLength);
}

public void setPulse(int index, int type) {
  beatRows.get(0).beats.get(index).setType(BeatType.values()[type]);
}

public void setPlayhead(int index) {
  playheadPosition = index; 
}

public void clearAllBeats() {
   beatRows.clear();
   playheadPosition = 0;
}