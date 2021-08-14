[CCode(cheader_filename = "libg15.h")]
namespace G15 {
	[CCode(cname = "int", has_type_id = false)]
	public enum Log {
		INFO,
		WARN
	}
	[CCode(cname = "int", has_type_id = false)]
	[Flags]
	public enum LED {
		M1,
		M2,
		M3,
		MR
	}

	[CCode(cname = "int", has_type_id = false)]
	public enum Brightness {
		DARK,
		MEDIUM,
		BRIGHT
	}

	[CCode(cname = "int", has_type_id = false)]
	public enum Contrast {
		LOW,
		MEDIUM,
		HIGH
	}

	[CCode(cname = "int", has_type_id = false)]
	public enum LCD {
		OFFSET,
		HEIGHT,
		WIDTH
	}

	[CCode(cname = "int", cprefix = "G15_", has_type_id = false)]
	public enum Error {
		NO_ERROR,
		ERROR_OPENING_USB_DEVICE,
		ERROR_WRITING_PIXMAP,
		ERROR_TIMEOUT,
		ERROR_READING_USB_DEVICE,
		ERROR_TRY_AGAIN,
		ERROR_WRITING_BUFFER,
		ERROR_UNSUPPORTED
	}

	[CCode(cname = "int", has_type_id = false)]
	[Flags]
	public enum Key {
		G1,
		G2,
		G3,
		G4,
		G5,
		G6,
		G7,
		G8,
		G9,
		G10,
		G11,
		G12,
		G13,
		G14,
		G15,
		G16,
		G17,
		G18,
		G19,
		G20,
		G21,
		G22,
		M1,
		M2,
		M3,
		MR,
		L1,
		L2,
		L3,
		L4,
		L5,
		LIGHT
		// need to add them to the enum but not enough positions left
		// JOYBL,
		// JOYBD,
		// JOYBS
	}

	/* this one return G15_NO_ERROR on success, something
	 * else otherwise (for instance G15_ERROR_OPENING_USB_DEVICE
	 */
	[CCode(cname = "initLibG15")]
	public int init();

	/* re-initialise a previously unplugged keyboard ie ENODEV was returned at some point */
	[CCode(cname = "re_initLibG15")]
	public int re_init();

	[CCode(cname = "exitLibG15")]
	public int exit();

	/* enable or disable debugging */
	[CCode(cname = "libg15Debug")]
	public void debug(int option);

	// [CCode (cname = "writePixmapToLCD")]
	public int write_pixmap_to_lcd(ref uint8 data);

	[CCode(cname = "setLCDContrast")]
	public int set_lcd_contrast(uint level);

	[CCode(cname = "setLEDs")]
	public int set_leds(uint leds);

	[CCode(cname = "setLCDBrightness")]
	public int set_lcd_brightness(uint level);

	[CCode(cname = "setKBBrightness")]
	public int set_keyboard_brightness(uint level);

	/* Please be warned
	 * the g15 sends two different usb msgs for each key press
	 * but only one of these two is used here. Since we do not want to wait
	 * longer than timeout we will return on any msg recieved. in the good
	 * case you will get G15_NO_ERROR and ORd keys in pressed_keys
	 * in the bad case you will get G15_ERROR_TRY_AGAIN -> try again
	 */
	[CCode(cname = "getPressedKeys")]
	public int get_pressed_keys(out uint pressed_keys, uint timeout);

	[CCode(cname = "setG510LEDColor")]
	public int set_g510_led_color(uint8 r, uint8 g, uint8 b);
}
