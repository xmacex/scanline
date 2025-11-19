Engine_Scanline : CroneEngine {
	var scanline;
	var rate    = 1;
	var amp     = 0.1;
	var rel     = 1.0;
	var lagTime = 1.0;
	var synth;

	*new { |context, doneCallback |
		^super.new(context, doneCallback);
	}

	alloc {
		SynthDef(\Scanline, {
			arg out=0, scanline=scanline, rate=rate, amp=amp, gate=gate, rel=rel, lagTime=lagTime;
			var sig, env;

			scanline.postln;

			// env = EnvGen.kr(
			// 	Env.asr(releaseTime: rel, level: amp),
			// 	gate: gate, doneAction: Done.freeSelf);
			env = Env.asr(
				releaseTime: rel, sustainLevel: amp*0.5
			).kr(gate: gate,
				doneAction: Done.freeSelf);
			sig = PlayBuf.ar(1, scanline, Lag.kr(rate, lagTime: lagTime), loop: 1);
			sig = sig*env;
			Out.ar(out, LeakDC.ar(sig)!2);
		}).add;

		Server.default.sync;

		scanline = Buffer.alloc(context.server, 128);
		scanline.cheby([0.3, 0.1, -0.3]);

	    this.addCommand('play', "f", { |msg|
            rate=msg[1];
		    synth.set(\gate, 0);
            synth = Synth.new(\Scanline, [
        		\scanline, scanline,
				\rate, rate,
				\amp, amp,
				\rel, rel,
				\gate, 1
			]);
		});

		this.addCommand('scanline', "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", { |msg|
			scanline.setn(0, msg);
		});

		this.addCommand("rate", "f", { |msg|
		 rate = msg[1];
		 synth.set(\rate, msg[1]);
		});

		this.addCommand("amp", "f", { |msg|
		 amp = msg[1];
		 synth.set(\amp, msg[1]);
		});

		this.addCommand("rel", "f", { |msg|
		 rel = msg[1];
		 synth.set(\rel, msg[1]);
		});
		
		this.addCommand("lag", "f", { |msg|
		lagTime = msg[1];
		synth.set(\lagTime, msg[1]);
		});

		this.addCommand("cheby", "fff", { |msg|
			scanline.cheby(msg);
		});
	}

	free {
		synth.free;
		scanline.free;
	}
}