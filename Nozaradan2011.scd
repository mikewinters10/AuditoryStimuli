// Recreating the Auditory Stimulus in (Nozaradan et. al, 2011)
//
//

//
s.reboot



{SinOsc.ar(11,mul:0.4,add:0.6) * (SinOsc.ar(333.3)*EnvGen.kr(Env.new(times:[0.022,0.394],curve:'sine'),Impulse.kr(2.4)))}.play