import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;
import java.util.*;

OscP5 oscP5;
NetAddress remoteLocation;
PGraphics canvas;
SyphonServer server;
List<Integer> polypeptideChain;
List<PShape> blockos;

int Y_AXIS = 1;
int X_AXIS = 2;

float boxWidth = width*0.77;
float boxHeight = 50.0f;
float boxMargin = 10.0;
float textSiz = 16.0f;
float driftFactor = 0.01f;
float noiseAmp = 20.0f;
float cameraYOffset = 0.0f;
int newShapeTint = 255;

float color_nonpolar[] = {255, 157, 54, 255};
float color_polar[] = {142, 99, 210, 255};
float color_basic[] = {67, 255, 199, 255};
float color_acidic[] = {204, 0, 190, 255};

Map<String, float[]> colors = new HashMap<String, float[]>();
Map<String, PImage> textures = new HashMap<String, PImage>();
JSONObject types, iToAA, aaToName;

public void settings() {
  size(400,800, P3D);
  boxWidth = width*0.77;
  PJOGL.profile=1;
}

public void setup() {
  canvas = createGraphics(400, 800, P3D);
  canvas.textureMode(NORMAL);
  frameRate(25);
  
  colors.put("nonpolar", color_nonpolar);
  colors.put("polar", color_polar);
  colors.put("acidic", color_acidic);
  colors.put("basic", color_basic);
  colors = Collections.unmodifiableMap(colors);
  
  types = loadJSONObject("types.json");
  iToAA = loadJSONObject("i_to_aa.json");
  aaToName = loadJSONObject("names.json");
  
  polypeptideChain = new ArrayList<Integer>();
  blockos = new ArrayList<PShape>();
  
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
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
  Ani.init(this);
}

private PImage createTexture(String name, String type, int w, int h) {
  float pepColor[] = colors.get(type);
  PGraphics pTex = createGraphics(w, h, P3D);
  pTex.beginDraw();
  pTex.background(pepColor[0], pepColor[1], pepColor[2], pepColor[3]);
  pTex.fill(0);
  pTex.stroke(255);
  pTex.rectMode(CENTER);
  pTex.textAlign(CENTER);
  pTex.textSize(textSiz);
  pTex.scale(-1, 1, 1);
  pTex.text(name, -pTex.width/2, pTex.height/2 + (textSiz/2), -w, textSiz*2);
  pTex.endDraw();
  return pTex;
}

public void draw() {
  canvas.beginDraw();
  canvas.background(10);
  canvas.lights();
  setGradient(canvas, 0, 0, width, height, color(100), color(10), Y_AXIS);
  for (int i=0; i<polypeptideChain.size(); i++) {
    Integer ppidx = polypeptideChain.get(i);
    canvas.pushMatrix();
    float py = -i * (boxHeight+boxMargin) + 100 + cameraYOffset;
    String s = ppidx.toString();
    String type = types.getString(s);
    String name = aaToName.getString(iToAA.getString(s));
    PImage tex;
    if (!textures.containsKey(s)) {
      tex = createTexture(name, type, (int) boxWidth, (int) boxHeight);
      textures.put(s, tex);
    } else {
      tex = textures.get(s);
    }
    blockos.get(i).setTexture(tex);
    blockos.get(i).setStroke(255);
    canvas.translate(width/2, py);
    canvas.shape(blockos.get(i));
    canvas.popMatrix();
  }
  float randomY = map(noise(frameCount * driftFactor), 0., 1., -1., 1.)*noiseAmp;
  canvas.camera(width/2, height/2 + randomY, (height/2) / tan(PI/6), width/2, height/2 + randomY, 0, 0, 1, 0);
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

void setGradient(PGraphics ctx, int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = ctx.lerpColor(c1, c2, inter);
      ctx.stroke(c);
      ctx.line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = ctx.lerpColor(c1, c2, inter);
      ctx.stroke(c);
      ctx.line(i, y, i, y+h);
    }
  }
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
  polypeptideChain.add(new Integer(peptideIdxID));
  blockos.add(createShape(BOX, boxWidth, boxHeight, 50));
  newShapeTint = 0;
  Ani.to(this, 0.3, "cameraYOffset", (polypeptideChain.size()-1) * (boxHeight+boxMargin) * 1., Ani.CUBIC_IN_OUT);
  Ani.to(this, 0.3, "newShapeTint", 255, Ani.CUBIC_IN_OUT);
}

public void clearPeptides() {
  polypeptideChain.clear();
  blockos.clear();
}