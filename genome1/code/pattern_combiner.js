var pulses = [];
var accents = [];
var pulseOffset = 0;
var accentOffset = 0;
var phraseLength = 16;
outlets = 2;

////////////////////////// Public

function setPulses() {
  pulses = arguments;
}

function clearPulses() {
  for (var i=0; i<pulses.length; ++i) {
	pulses[i] = 0;
  }
}

function setPulseCount(ct) {
  if (ct != pulses.length) {
    pulses = new Array(ct);
    for (var i=0; i<pulses.length; i++)
      pulses[i] = 0;
  }
}

function setPulseAtIndex(idx, yn) {
  idx = idx % pulses.length;
  pulses[idx] = yn;
}

function togglePulseAtIndex(idx) {
  idx = idx % pulses.length;
  pulses[idx] = !pulses[idx];
}

function setAccents() {
  accents = arguments;
}

function clearAccents() {
	for (var i=0; i<accents.length; ++i) {
		accents[i] = 0;
	}
}

function setAccentCount(ct) {
  if (ct != accents.length) {
    accents = new Array(ct);
    for (var i=0; i<accents.length; i++)
      accents[i] = 0;
  }
}

function setAccentAtIndex(idx, yn) {
  idx = idx % accents.length;
  accents[idx] = yn;
}

function toggleAccentAtIndex(idx) {
  idx = idx % accents.length;
  accents[idx] = !accents[idx];
}

function setPulseOffset(offset) {
  pulseOffset = (offset + pulses.length) % pulses.length;
}

function incrementPulseOffset(inc) {
  pulseOffset = (pulseOffset + inc + pulses.length) % pulses.length;
}

function setAccentOffset(offset) {
  accentOffset = (offset + accents.length) % accents.length;
}

function incrementAccentOffset(inc) {
  accentOffset = (accentOffset + inc + accents.length) % accents.length;
}

function setPhraseLength(len) {
  phraseLength = len;
}

onset_count.local = 1;
function onset_count() {
  var cnt = 0;
  for (var i=0; i<phraseLength; ++i) {
    cnt = cnt + index_internal(i);
  }
}
index_internal.local = 1;
function index_internal(idx) {
  idx = idx % phraseLength;
  idx = (idx + pulseOffset + pulses.length) % pulses.length;
  return pulses[idx];
}
accent_internal.local = 1;
function accent_internal(idx) {
  idx = idx % phraseLength;
  var isOnset = index_internal(idx);
  if (!isOnset)
    return 0;
  var onsetCount = onset_count();
  if (onsetCount <= 0)
    return 0;
  var onsetIdx = -1;
  for (var i=0; i<=idx; ++i) {
    onsetIdx = onsetIdx + index_internal(i);
  }
  if (onsetIdx < 0)
    return 0;
  onsetIdx = (onsetIdx + accentOffset + accents.length) % accents.length;
  return accents[onsetIdx];
}
function index(idx) {
  if (pulses.length > 0)
    outlet(0, "index", index_internal(idx), accent_internal(idx));
}

function dump() {
  var beats = new Array(phraseLength);
  for (var i=0; i<phraseLength; ++i) {
    beats[i] = index_internal(i);
  }
  outlet(1, "onsets", beats);
  var accents = new Array(phraseLength);
  for (i=0; i<phraseLength; ++i) {
    accents[i]  = accent_internal(i);
  }
  outlet(1, "accents", accents);
}
