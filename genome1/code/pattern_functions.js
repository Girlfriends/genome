outlets = 1;
var pulseCursor = 0;
var pulses = new Array(32);
var pulseLength = 5;
var pulseOffset = 0;

for (var v=0; v<32; ++v) {
  pulses[v] = 0;
}

////////////////////////// Public

function dump() {
  outlet(0, "columns", pulseLength);
  for (var i=0; i<pulseLength; ++i) {
    outlet(0, "setcell", i+1, 1, pulses[i]);
  }
  outlet(0, "set", pulseCursor + 1);
  outlet(0, "offset", pulseOffset);
}

function setCount(cnt) {
  pulseLength = cnt;
  outlet(0, "columns", cnt);
  for (var i=0; i<cnt; ++i) {
    outlet(0, "setcell", i+1, 1, pulses[i]);
  }
}

function incrementCount(inc) {
  pulseLength = Math.max(2, Math.min(pulseLength + inc, 32));
  this.setCount(pulseLength);
}

function setOffset(o) {
  pulseOffset = o % pulseLength;
  outlet(0, "offset", pulseOffset);
}

function moveOffset(o) {
  pulseOffset = (pulseOffset + o + pulseLength) % pulseLength;
  this.setOffset(pulseOffset);
}

function toggleAtCursor() {
  pulses[pulseCursor] = !pulses[pulseCursor];
  outlet(0, "setcell", pulseCursor+1, 1, pulses[pulseCursor]);
}

function moveCursor(n) {
  pulseCursor = (pulseCursor + n + pulseLength) % pulseLength;
  outlet(0, "set", pulseCursor + 1);
}

function clear() {
  pulseCursor = 0;
  for (var v=0; v<32; ++v) {
    pulses[v] = 0;
  }
  pulseOffset = 0;
}
