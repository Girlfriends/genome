public class BeatCollection {
  public ArrayList<Beat> beats;
  
  public BeatCollection() {
    
  }
  
  public void initializeBeatLength(int length) {
    beats = new ArrayList<Beat>(length);   
  }
}