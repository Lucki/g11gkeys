include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

use clap::Parser;
use macro_manager::Manager;

#[derive(Parser)]
struct Cli {}

const ENODEV: u32 = 19;

struct KeyLedMapping {
    key: u32,
    led: u32,
    macro_set_name: &'static str,
}

const KEY_LED_MAP: [KeyLedMapping; 15] = [
    KeyLedMapping { key: G15_KEY_M1 as u32, led: G15_LED_M1, macro_set_name: "m1" },
    KeyLedMapping { key: G15_KEY_M2 as u32, led: G15_LED_M2, macro_set_name: "m2" },
    KeyLedMapping { key: G15_KEY_M3 as u32, led: G15_LED_M3, macro_set_name: "m3" },
    KeyLedMapping { key: G15_KEY_MR as u32, led: G15_LED_MR, macro_set_name: "mr" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M2) as u32, led: G15_LED_M1 | G15_LED_M2, macro_set_name: "m1m2" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M3) as u32, led: G15_LED_M1 | G15_LED_M3, macro_set_name: "m1m3" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_MR) as u32, led: G15_LED_M1 | G15_LED_MR, macro_set_name: "m1mr" },
    KeyLedMapping { key: (G15_KEY_M2 | G15_KEY_M3) as u32, led: G15_LED_M2 | G15_LED_M3, macro_set_name: "m2m3" },
    KeyLedMapping { key: (G15_KEY_M2 | G15_KEY_MR) as u32, led: G15_LED_M2 | G15_LED_MR, macro_set_name: "m2mr" },
    KeyLedMapping { key: (G15_KEY_M3 | G15_KEY_MR) as u32, led: G15_LED_M3 | G15_LED_MR, macro_set_name: "m3mr" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M2 | G15_KEY_M3) as u32, led: G15_LED_M1 | G15_LED_M2 | G15_LED_M3, macro_set_name: "m1m2m3" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M2 | G15_KEY_MR) as u32, led: G15_LED_M1 | G15_LED_M2 | G15_LED_MR, macro_set_name: "m1m2mr" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M3 | G15_KEY_MR) as u32, led: G15_LED_M1 | G15_LED_M3 | G15_LED_MR, macro_set_name: "m1m3mr" },
    KeyLedMapping { key: (G15_KEY_M2 | G15_KEY_M3 | G15_KEY_MR) as u32, led: G15_LED_M2 | G15_LED_M3 | G15_LED_MR, macro_set_name: "m2m3mr" },
    KeyLedMapping { key: (G15_KEY_M1 | G15_KEY_M2 | G15_KEY_M3 | G15_KEY_MR) as u32, led: G15_LED_M1 | G15_LED_M2 | G15_LED_M3 | G15_LED_MR, macro_set_name: "m1m2m3mr" },
];

struct GKeyMapping {
    key: u32,
    name: &'static str,
}

const G_KEY_MAP: [GKeyMapping; 18] = [
    GKeyMapping { key: G15_KEY_G1 as u32, name: "g1" },
    GKeyMapping { key: G15_KEY_G2 as u32, name: "g2" },
    GKeyMapping { key: G15_KEY_G3 as u32, name: "g3" },
    GKeyMapping { key: G15_KEY_G4 as u32, name: "g4" },
    GKeyMapping { key: G15_KEY_G5 as u32, name: "g5" },
    GKeyMapping { key: G15_KEY_G6 as u32, name: "g6" },
    GKeyMapping { key: G15_KEY_G7 as u32, name: "g7" },
    GKeyMapping { key: G15_KEY_G8 as u32, name: "g8" },
    GKeyMapping { key: G15_KEY_G9 as u32, name: "g9" },
    GKeyMapping { key: G15_KEY_G10 as u32, name: "g10" },
    GKeyMapping { key: G15_KEY_G11 as u32, name: "g11" },
    GKeyMapping { key: G15_KEY_G12 as u32, name: "g12" },
    GKeyMapping { key: G15_KEY_G13 as u32, name: "g13" },
    GKeyMapping { key: G15_KEY_G14 as u32, name: "g14" },
    GKeyMapping { key: G15_KEY_G15 as u32, name: "g15" },
    GKeyMapping { key: G15_KEY_G16 as u32, name: "g16" },
    GKeyMapping { key: G15_KEY_G17 as u32, name: "g17" },
    GKeyMapping { key: G15_KEY_G18 as u32, name: "g18" },
];

fn main() {
    let _args = Cli::parse();

    assert!(LIBG15_VERSION == 1201);

    unsafe {
        let ret = initLibG15();
        if ret != i32::try_from(G15_NO_ERROR).unwrap() {
            panic!("Error initializing keyboard!")
        }
    }

    unsafe {
        // Known state
        setLEDs(G15_LED_M1);
        setKBBrightness(G15_BRIGHTNESS_BRIGHT);
    }

    let mut active_set = &KEY_LED_MAP[0];
    let mut last_pressed_keys: u32 = 0;
    loop {
        let mut pressed_keys: u32 = 0;

        unsafe {
            match u32::try_from(getPressedKeys(&mut pressed_keys, 1000)).ok() {
                None => { u32::try_from(re_initLibG15()).ok().unwrap(); },
                Some(ret) => {
                    match ret {
                        G15_NO_ERROR => {
                            last_pressed_keys = handle_pressed_keys(pressed_keys, last_pressed_keys, &mut active_set);
                        },
                        G15_ERROR_OPENING_USB_DEVICE | G15_ERROR_READING_USB_DEVICE | ENODEV => { u32::try_from(re_initLibG15()).ok(); },
                        G15_ERROR_TRY_AGAIN | G15_ERROR_TIMEOUT => continue,
                        _ => panic!("Unhandled keyboard error"),
                    }
                }
            }
        }
    }
}

fn handle_pressed_keys(mut pressed_keys: u32, last_pressed_keys: u32, active_set: &mut &KeyLedMapping) -> u32 {
    if pressed_keys == 0 {
        return pressed_keys;
    }

    // Only allow addition of M-Keys to allow for multi-presses
    if pressed_keys & G15_KEY_M1 as u32 == G15_KEY_M1 as u32
    || pressed_keys & G15_KEY_M2 as u32 == G15_KEY_M2 as u32
    || pressed_keys & G15_KEY_M3 as u32 == G15_KEY_M3 as u32
    || pressed_keys & G15_KEY_MR as u32 == G15_KEY_MR as u32 {
        for key in [G15_KEY_M1 as u32, G15_KEY_M2 as u32, G15_KEY_M3 as u32, G15_KEY_MR as u32] {
            if last_pressed_keys & key == key {
               pressed_keys |= key;
            }
        }
    }

    get_active_set(pressed_keys, active_set);

    for key_mapping in G_KEY_MAP {
        // Only start macros for newly pressed keys and ignore already pressed ones
        if pressed_keys & key_mapping.key == key_mapping.key && last_pressed_keys & key_mapping.key != key_mapping.key {
            let macro_manager = Manager::new();

            match macro_manager.get_macro(active_set.macro_set_name.to_owned(), key_mapping.name.to_string()) {
                Ok(m) => {
                    m.run();
                },
                Err(error) => {
                    println!("{error}");
                },
            }
        }
    }

    return pressed_keys;
}

fn get_active_set(pressed_keys: u32, active_set: &mut &KeyLedMapping) -> () {
    for mapping in KEY_LED_MAP.iter() {
        if (pressed_keys & mapping.key) == mapping.key {
            *active_set = mapping;
        }
    }

    unsafe {
        let _ret = setLEDs(active_set.led);
    }
}
