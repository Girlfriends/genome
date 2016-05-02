import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;
import java.util.*;
  
OscP5 oscP5;
NetAddress remoteLocation;
PGraphics canvas;
SyphonServer server;
LinkedList<Integer> polypeptideChain;

float boxHeight = 50.0f;
float boxMargin = 5.0;

float color_nonpolar[] = {1.0, 0.906, 0.373, 1.0};
float color_polar[] = {0.702, 0.871, 0.753, 1.0};
float color_basic[] = {0.733, 0.749, 0.878, 1.0};
float color_acidic[] = {0.973, 0.718, 0.827, 1.0};

Map<String, float[]> colors = new HashMap<String, float[]>();
JSONObject types;

ArrayList<BeatCollection> beatRows;
int BEAT_ROWS_MAX = 10;

public int playheadPosition = 0;

public void settings() {
  size(400,400, P3D);
  PJOGL.profile=1;
}

public void setup() {
  canvas = createGraphics(400, 400, P3D);
  frameRate(25);
  
  colors.put("nonpolar", color_nonpolar);
  colors.put("polar", color_polar);
  colors.put("acidic", color_acidic);
  colors.put("basic", color_basic);
  colors = Collections.unmodifiableMap(colors);
  
  types = loadJSONObject("types.json");
  
  polypeptideChain = new LinkedList<Integer>();
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  remoteLocation = new NetAddress("127.0.0.1",12000);
  oscP5.plug(this, "addPeptide", "/addPeptide");
  oscP5.plug(this, "clearPeptides", "/clearPeptides");
  
  oscP5.plug(this, "newBeat", "/newBeat");
  oscP5.plug(this, "setPatternLength", "/setPatternLength");
  oscP5.plug(this, "setPulse", "/setPulse");
  oscP5.plug(this, "setPlayHead", "/setPlayHead");
  oscP5.plug(this, "clear", "/clear");
  
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
}

public void draw() {
  canvas.beginDraw();
  canvas.background(127);
  canvas.lights();
  for (int i=0; i<polypeptideChain.size(); i++) {
    Integer ppidx = polypeptideChain.get(i);
    canvas.pushMatrix();
    float py = i * (boxHeight+boxMargin) + height/2.0;
    if (py - boxHeight < height) {
      String s = ppidx.toString();
      String type = types.getString(s);
      float pepColor[] = colors.get(type);
      println("type: " + type + " mapped to color " + pepColor[0]);
      canvas.translate(width/2, py);
      canvas.fill(pepColor[0]*255, pepColor[1]*255, pepColor[2]*255, pepColor[3]*255);
      canvas.box(width/3, boxHeight, 50);
    }
    canvas.popMatrix();
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

public void addPeptide(int peptideIdxID) {
  polypeptideChain.push(new Integer(peptideIdxID));
  println("The polypeptide chain is now "+polypeptideChain.size()+" long");
}

public void clearPeptides() {
  polypeptideChain.clear();
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