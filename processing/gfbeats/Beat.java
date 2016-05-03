package gfbeats;

public class Beat {
  public BeatType type;

  public Beat() {
    this.type = BeatType.OFF;
  }

  public void setType(BeatType type) {
    this.type = type;
  }
}
