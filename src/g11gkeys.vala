namespace G11GKeys {
	public class Main : Object {
		private static string macro_set { get; set; default = "m1"; }

		public static int main(string[] args) {
			try {
				OptionEntry[] options = {
					// list terminator
					{ null }
				};

				var opt_context = new OptionContext();
				opt_context.set_help_enabled(true);
				opt_context.add_main_entries(options, null);
				opt_context.set_description("Handler for the 18 extra G-Keys on the Logitech G11 keyboard. Calls macro-manager in the background which itself reads the configuration from '$XDG_CONFIG_HOME/macro-manager/config.json'");
				opt_context.parse(ref args);
			} catch (OptionError e) {
				printerr("error: %s\n", e.message);
				printerr("Run '%s --help' to see a full list of available command line options.\n", args[0]);

				return 1;
			}

			int ret;
			if ((ret = G15.init()) != G15.Error.NO_ERROR) {
				printerr("error init: %s\n", ret.to_string());
				return 1;
			}

			// not sure why I need this but without it it's null
			macro_set = "m1";

			// Set to known state
			G15.set_leds(G15.LED.M1);
			G15.set_keyboard_brightness(G15.Brightness.BRIGHT);

			var loop = new MainLoop();

			Unix.signal_add(Posix.Signal.TERM, () => {
				loop.quit();
				return Source.CONTINUE;
			}, Priority.DEFAULT);

			uint pressed_keys = 0;
			uint last_pressed_keys = 0;

			AsyncReadyCallback callback = null;
			callback = (obj, res) => {
				try {
					pressed_keys = get_pressed_keys_async.end(res);
				} catch (GLib.Error e) {
					printerr("error: %s\n", e.message);
					loop.quit();
				}

				handle_pressed_keys(ref pressed_keys, last_pressed_keys);
				last_pressed_keys = pressed_keys;

				// https://www.youtube.com/watch?v=wbtJ60y1l4g
				get_pressed_keys_async.begin(callback);
			};

			get_pressed_keys_async.begin(callback);

			loop.run();

			return exit();
		}

		private static async uint get_pressed_keys_async() throws GLib.Error {
			int ret;
			uint pressed_keys;
			while ((ret = G15.get_pressed_keys(out pressed_keys, 1000)) == G15.Error.ERROR_TRY_AGAIN) {
				continue;
			}

			if (ret == Posix.ENODEV) {
				while ((ret = G15.re_init()) != G15.Error.NO_ERROR) {
					printerr("lost keyboard, retrying…");
					Thread.usleep(1000);
				}
			} else if (ret != G15.Error.NO_ERROR && ret != G15.Error.ERROR_READING_USB_DEVICE) {
				throw new GLib.Error(1, 1, "Something went wrong: " + ret.to_string());
			}

			return pressed_keys;
		}

		private static int exit() {
			int ret;
			if ((ret = G15.exit()) != G15.Error.NO_ERROR) {
				printerr("error exit: %s\n", ret.to_string());
				return Posix.EXIT_FAILURE;
			}
			return Posix.EXIT_SUCCESS;
		}

		private static void handle_pressed_keys(ref uint pressed_keys, uint last_pressed_keys) {
			if (pressed_keys == 0) return;

			// Only allow addition of M-Keys to allow for multi-presses
			if ((pressed_keys & G15.Key.M1) == G15.Key.M1
			    || (pressed_keys & G15.Key.M2) == G15.Key.M2
			    || (pressed_keys & G15.Key.M3) == G15.Key.M3
			    || (pressed_keys & G15.Key.MR) == G15.Key.MR) {
				if ((last_pressed_keys & G15.Key.M1) == G15.Key.M1) {
					pressed_keys |= G15.Key.M1;
				}
				if ((last_pressed_keys & G15.Key.M2) == G15.Key.M2) {
					pressed_keys |= G15.Key.M2;
				}
				if ((last_pressed_keys & G15.Key.M3) == G15.Key.M3) {
					pressed_keys |= G15.Key.M3;
				}
				if ((last_pressed_keys & G15.Key.MR) == G15.Key.MR) {
					pressed_keys |= G15.Key.MR;
				}
			}

			if ((pressed_keys & G15.Key.M1) == G15.Key.M1) {
				var ret = G15.set_leds(G15.LED.M1);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1";
			}
			if ((pressed_keys & G15.Key.M2) == G15.Key.M2) {
				var ret = G15.set_leds(G15.LED.M2);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m2";
			}
			if ((pressed_keys & G15.Key.M3) == G15.Key.M3) {
				var ret = G15.set_leds(G15.LED.M3);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m3";
			}
			if ((pressed_keys & G15.Key.MR) == G15.Key.MR) {
				var ret = G15.set_leds(G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "mr";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M2)) == (G15.Key.M1 | G15.Key.M2)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M2);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m2";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M3)) == (G15.Key.M1 | G15.Key.M3)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M3);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m3";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.MR)) == (G15.Key.M1 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1mr";
			}
			if ((pressed_keys & (G15.Key.M2 | G15.Key.M3)) == (G15.Key.M2 | G15.Key.M3)) {
				var ret = G15.set_leds(G15.LED.M2 | G15.LED.M3);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m2m3";
			}
			if ((pressed_keys & (G15.Key.M2 | G15.Key.MR)) == (G15.Key.M2 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M2 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m2mr";
			}
			if ((pressed_keys & (G15.Key.M3 | G15.Key.MR)) == (G15.Key.M3 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M3 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m3mr";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M2 | G15.Key.M3)) == (G15.Key.M1 | G15.Key.M2 | G15.Key.M3)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M2 | G15.LED.M3);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m2m3";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M2 | G15.Key.MR)) == (G15.Key.M1 | G15.Key.M2 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M2 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m2mr";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M3 | G15.Key.MR)) == (G15.Key.M1 | G15.Key.M3 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M3 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m3mr";
			}
			if ((pressed_keys & (G15.Key.M2 | G15.Key.M3 | G15.Key.MR)) == (G15.Key.M2 | G15.Key.M3 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M2 | G15.LED.M3 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m2m3mr";
			}
			if ((pressed_keys & (G15.Key.M1 | G15.Key.M2 | G15.Key.M3 | G15.Key.MR)) == (G15.Key.M1 | G15.Key.M2 | G15.Key.M3 | G15.Key.MR)) {
				var ret = G15.set_leds(G15.LED.M1 | G15.LED.M2 | G15.LED.M3 | G15.LED.MR);
				printerr("set_leds ret: %s\n", ret.to_string());
				macro_set = "m1m2m3mr";
			}

			if ((pressed_keys & G15.Key.G1) == G15.Key.G1 && (last_pressed_keys & G15.Key.G1) != G15.Key.G1) {
				var macro = new MacroManager.Macro("g1", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G2) == G15.Key.G2 && (last_pressed_keys & G15.Key.G2) != G15.Key.G2) {
				var macro = new MacroManager.Macro("g2", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G3) == G15.Key.G3 && (last_pressed_keys & G15.Key.G3) != G15.Key.G3) {
				var macro = new MacroManager.Macro("g3", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G4) == G15.Key.G4 && (last_pressed_keys & G15.Key.G4) != G15.Key.G4) {
				var macro = new MacroManager.Macro("g4", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G5) == G15.Key.G5 && (last_pressed_keys & G15.Key.G5) != G15.Key.G5) {
				var macro = new MacroManager.Macro("g5", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G6) == G15.Key.G6 && (last_pressed_keys & G15.Key.G6) != G15.Key.G6) {
				var macro = new MacroManager.Macro("g6", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G7) == G15.Key.G7 && (last_pressed_keys & G15.Key.G7) != G15.Key.G7) {
				var macro = new MacroManager.Macro("g7", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G8) == G15.Key.G8 && (last_pressed_keys & G15.Key.G8) != G15.Key.G8) {
				var macro = new MacroManager.Macro("g8", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G9) == G15.Key.G9 && (last_pressed_keys & G15.Key.G9) != G15.Key.G9) {
				var macro = new MacroManager.Macro("g9", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G10) == G15.Key.G10 && (last_pressed_keys & G15.Key.G10) != G15.Key.G10) {
				var macro = new MacroManager.Macro("g10", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G11) == G15.Key.G11 && (last_pressed_keys & G15.Key.G11) != G15.Key.G11) {
				var macro = new MacroManager.Macro("g11", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G12) == G15.Key.G12 && (last_pressed_keys & G15.Key.G12) != G15.Key.G12) {
				var macro = new MacroManager.Macro("g12", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G13) == G15.Key.G13 && (last_pressed_keys & G15.Key.G13) != G15.Key.G13) {
				var macro = new MacroManager.Macro("g13", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G14) == G15.Key.G14 && (last_pressed_keys & G15.Key.G14) != G15.Key.G14) {
				var macro = new MacroManager.Macro("g14", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G15) == G15.Key.G15 && (last_pressed_keys & G15.Key.G15) != G15.Key.G15) {
				var macro = new MacroManager.Macro("g15", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G16) == G15.Key.G16 && (last_pressed_keys & G15.Key.G16) != G15.Key.G16) {
				var macro = new MacroManager.Macro("g16", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G17) == G15.Key.G17 && (last_pressed_keys & G15.Key.G17) != G15.Key.G17) {
				var macro = new MacroManager.Macro("g17", macro_set);
				macro.run();
			}
			if ((pressed_keys & G15.Key.G18) == G15.Key.G18 && (last_pressed_keys & G15.Key.G18) != G15.Key.G18) {
				var macro = new MacroManager.Macro("g18", macro_set);
				macro.run();
			}
		}
	}
}
