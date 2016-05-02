var beats = [];
var cursorPos = 0;
outlets = 2;

set_length(8);

////////////////////////// Helpers

function bfit(i) {
	return (i + beats.length) % beats.length;
}
bfit.local = 1;

////////////////////////// Public

function length() {
	outlet(0, "length", beats.length);
}

function set_length(len) {
	beats = new Array(len);
	for (var i=0; i<beats.length; ++i) {
		beats[i] = false;
	}
	cursorPos = cursorPos % beats.length;
}

function index(i) {
	outlet(0, "index", beats[i]);
}

function cursor() {
	outlet(0, "cursor", cursorPos);
}

function set_cursor(i) {
	cursorPos = bfit(i);
}

function set_index(i, state) {
	beats[i] = state;
}

function clear() {
	for (var i=0; i<beats.length; ++i) {
		beats[i] = false;
	}
	cursorPos = 0;
}

function dump() {
	outlet(1, beats);
	outlet(1, "cursor", cursorPos);
}

function shift(shft) {
	var tmp_array = new Array(beats.length);
	for (var i=0; i<tmp_array.length; i++) {
		var idx = bfit(i + shft);
		tmp_array[idx] = beats[i];
	}
	beats = tmp_array;
}

////////////////////////// Whole pattern functions

function cursorShift(i) {
	set_cursor(cursorPos + i);
}

function setAtCursor(yn) {
	set_index(cursorPos, yn);
}

function toggleEvery(step) {
	for (var i=0; i<beats.length; i += step) {
		var idx = bfit(cursorPos + i);
		beats[idx] = !beats[idx];
	}
}

function swapBeats(i, j) {
	var tmp = beats[i];
	beats[i] = beats[j];
	beats[j] = tmp;
}

function rotateAtPos(pos, siz, rot) {
	siz = Math.min(siz, beats.length);
	var tmp_array = new Array(siz);
	for (var i=0; i<siz; ++i) {
		var idx = bfit(pos + i);
		tmp_array[(i + rot + siz)%siz] = beats[idx];
	}
	for (i=0; i<siz; ++i) {
		var jdx = bfit(pos + i);
		beats[jdx] = tmp_array[i];
	}
}

function swapHalves() {
	var tmp_len = Math.ceil(beats.length / 2.0);
	var tmp_array = new Array(tmp_len);

	// Copy the first half of the beats array to a temporary array
	for (var i=0; i<tmp_len; ++i) {
		var idx = bfit(i + cursorPos);
		tmp_array[i] = beats[idx];
	}

	// Set the first half of the beats array to be equal to the second
	for (i=0; i<(beats.length - tmp_len); i++) {
		var fdx = bfit(i + cursorPos);
		var sdx = bfit(fdx + (beats.length - tmp_len));
		beats[fdx] = beats[sdx];
	}

	// Copy the temporary array over the second half of the beats array
	for (i=0; i<tmp_len; ++i) {
		var jdx = bfit(i + cursorPos + beats.length - tmp_len);
		beats[jdx] = tmp_array[i];
	}
}
