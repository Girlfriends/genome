package gfbeats;

import java.util.ArrayList;

public class BeatCollection {
  public ArrayList<Beat> beats;

  public BeatCollection() {
    this.beats = new ArrayList<Beat>();
  }

  public void initializeBeatLength(int length) {
    this.beats.clear();
    for (int i = 0; i < length; i++) {
      this.beats.add(new Beat());
    }
  }
}
