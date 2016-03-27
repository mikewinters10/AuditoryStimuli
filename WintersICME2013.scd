// A SuperCollider Patch for Sonification of Emotion
//
// R. Michael Winters
// Copy, right? 2015 RMW
//
// Double click between parenthesis to select all
// Shift-Enter to evaluate, Cmd-period to stop
// Cmd-d for help

// Boot the SuperCollider server
s.boot;

// Define our SynthDef and send it to the server
(
SynthDef(\Feels, {

	// Arguments can be adjusted externally (scale -1 to 1)
	// Currently they are set by the mouse. Uncomment the following
	// code to change that.
	// arg arousal = 0,valence = 0;

	// Variables specify internal signal flow
	var leftTrig, rightTrig, // Triggers for left and right channels
	int1, valenceSelect, // Controls of the major or minor third.
	int2 = 3/2, int3 = 2,    // Frequency multipliers for fifth & octave
	intGain1, intGain2, intGain3, // Gain of third, fifth, octave
	gainNormalize,// Overall loudness
	rough, rGain, // Negative valence variables
	decay, tempo, // Arousal variables
	synth, loudness, // Synth and overal gain control

	// Set arousal and valence by the mouse position.
	arousal = MouseY.kr(1.0,-1.0),
	valence = MouseX.kr(-1.0,1.0),

	f1=400,   a1=0.3, d1 = 1, // Frequency, amplitude, decay of 1st resonator
	f2=800,   a2=0.1, d2 = 1, // Frequency, amplitude, decay of 2nd resonator
	f3=1200,  a3=0.1, d3 = 1, // Frequency, amplitude, decay of 3rd resonator
	f4=1600,  a4=0.2, d4 = 1; // Frequency, amplitude, decay of 4th resonator

	// Select major or minor third
	int1 = Select.kr(valence+1,[DC.kr(6/5), DC.kr(5/4)]);
	//int1 = DC.kr(5/4);

	// Interval Gain Controls
	intGain1 = abs(valence).linlin(0, 0.75, 0, 1); // The third
	intGain2 = abs(valence).linlin(0, 0.5, 0.1, 1);  // The fifth
	intGain3 = abs(valence).linlin(0.25, 1, 0.1, 1); // The octave
	gainNormalize = 1/(1+intGain1+intGain2+intGain3);// Try to keep same volume
	loudness = arousal.linlin(-1,1,0.1,1);           // Overall loudness

	decay = arousal.linlin(-1,1,2,0.5); // Arousal to Decay Mapping
	tempo = arousal.linexp(-1,1,0.5,5);// Arousal to Tempo mapping

	// These are the triggers for exciting DynKlank
	leftTrig = Impulse.ar(tempo);
	rightTrig = Impulse.ar(tempo, 0.5);

	// Roughness of the sound
	rough = Point(valence, arousal).rho.linexp(0,1,1,50);
	rGain = (Point(valence, arousal).theta-(3*pi/4)).abs.linlin(0,pi/4,1,0);

	// Our synth is four DynKlank objects offset by frequency.
	// Roughness is implementing by separation of adjacent frequencies
	synth =(
		 DynKlank.ar(`[
			[f1, f2, f3, f4, f1+rough, f2+rough, f3+rough, f4+rough],
			[a1, a2, a3, a4, rGain*a1, rGain*a2, rGain*a3, rGain*a4],
			{decay}!8], [leftTrig, rightTrig]) +
		 DynKlank.ar(`[
			int1*[f1, f2, f3, f4, f1+rough, f2+rough, f3+rough, f4+rough],
			intGain1*[a1, a2, a3, a4, rGain*a1, rGain*a2, rGain*a3, rGain*a4],
			{decay}!8], [leftTrig, rightTrig]) +
		 DynKlank.ar(`[
			int2*[f1, f2, f3, f4, f1+rough, f2+rough, f3+rough, f4+rough],
			intGain2*[a1, a2, a3, a4, rGain*a1, rGain*a2, rGain*a3, rGain*a4],
			{decay}!8], [leftTrig, rightTrig]) +
		DynKlank.ar(`[
			int3*[f1, f2, f3, f4, f1+rough, f2+rough, f3+rough, f4+rough],
			intGain3*[a1, a2, a3, a4, rGain*a1, rGain*a2, rGain*a3, rGain*a4],
			{decay}!8], [leftTrig, rightTrig])
			)*gainNormalize;

	OffsetOut.ar(0,loudness*synth);
}).play
)

//Synth(\Feels)
// Run these to hear outputs:
x = Synth(\Feels);

// Arousal and valence are any real numbers between -1 and 1
x.set(\valence, 1);
x.set(\arousal, -1)