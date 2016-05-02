/*

drag a great big gene stack

*/

autowatch = 1;

sketch.default2d();
var val = 0;
var color_nonpolar = [1.0, 0.906, 0.373, 1.0];
var color_polar = [0.702, 0.871, 0.753, 1.0];
var color_basic = [0.733, 0.749, 0.878, 1.0];
var color_acidic = [0.973, 0.718, 0.827, 1.0];
var vbrgb = [1.0, 1.0, 1.0, 1.0];
var aminoAcidArray = [];
var interestRange = [0, 0];
var colors = {
	nonpolar: color_nonpolar,
	polar: color_polar,
	basic: color_basic,
	acidic: color_acidic
};
var types = {
	0: "nonpolar",
	1: "polar",
	2: "acidic",
	3: "acidic",
	4: "nonpolar",
	5: "nonpolar",
	6: "basic",
	7: "nonpolar",
	8: "basic",
	9: "nonpolar",
	10: "nonpolar",
	11: "polar",
	12: "nonpolar",
	13: "polar",
	14: "basic",
	15: "polar",
	16: "polar",
	17: "nonpolar",
	18: "nonpolar",
	19: "polar",
};

draw();

function draw()
{
	var width = box.rect[2] - box.rect[0];
	var height = box.rect[3] - box.rect[1];
	var aspect = width/height;

	with (sketch) {
		//scale everything to box size
		glmatrixmode("modelview");
		glpushmatrix();
		glscale(aspect,1,1);
		glenable("line_smooth");

		glclearcolor(vbrgb[0],vbrgb[1],vbrgb[2],vbrgb[3]);
		glclear();

		// for (var i=0; i<aminoAcidArray.length; ++i) {
		// 	var aa = aminoAcidArray[i];
		// 	var type = types[aa];
		// 	var color = colors[type];
		// 	var thickness = 1.0 / aminoAcidArray.length;
		// 	var py = (2.0 * i / (aminoAcidArray.length)) - 1.0;
		//
		// 	shapeslice(1, 1);
		// 	moveto(0.0, py);
		// 	plane(1.0, thickness);
		// 	glcolor(color[0], color[1], color[2], color[3]);
		// 	glpolygonmode("front_and_back","fill");
		// }

		if (interestRange[1] > interestRange[0]) {
			post("interestRange\n");
			var mn = (interestRange[1] + interestRange[0]) / 2.0;
			var centerY = (2.0 * mn / (aminoAcidArray.length)) - 1.0;
			var scaleRange = (interestRange[1] - interestRange[0]) / aminoAcidArray.length;
			shapeslice(1, 1);
			moveto(0.0, centerY);
			plane(1.0, scaleRange);
			post ("CenterY: " + centerY + ", scaleRange: " + scaleRange + "\n");
			glcolor(0.0, 0.0, 0.0, 0.0);
			glpolygonmode("front_and_back", "fill");
			gllinewidth(2);
			glcolor(0.0, 0.0, 0.0, 1.0);
			glpolygonmode("front_and_back", "stroke");
		}

		glpopmatrix();
	}


	// with (sketch) {
	// 	shapeslice(180,1);
	// 	// erase background
	// 	glclearcolor(vbrgb[0],vbrgb[1],vbrgb[2],vbrgb[3]);
	// 	glclear();
	// 	moveto(0,0);
	// 	// fill bgcircle
	// 	glcolor(vrgb2);
	// 	circle(0.8);
	// 	// draw arc outline
	// 	glcolor(0,0,0,1);
	// 	circle(0.8,-90-val*360,-90);
	// 	// fill arc
	// 	glcolor(vfrgb);
	// 	circle(0.7,-90-val*360,-90);
	// 	// draw rest of outline
	// 	if (width<=32)
	// 		gllinewidth(1);
	// 	else
	// 		gllinewidth(2);
	// 	glcolor(0,0,0,1);
	// 	moveto(0,0);
	// 	lineto(0,-0.8);
	// 	moveto(0,0);
	// 	theta = (0.75-val)*2*Math.PI;
	// 	lineto(0.8*Math.cos(theta),0.8*Math.sin(theta));
	// }
}

function setProtein(aaa)
{
	aminoAcidArray = arguments;
	draw();
	refresh();
}

function setInterestRange(start, end)
{
	interestRange[0] = start;
	interestRange[1] = end;
	draw();
	refresh();
}

function onresize(w,h)
{
	draw();
	refresh();
}
onresize.local = 1; //private
