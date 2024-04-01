# G11GKeys

Listens for G-Keys on the Logitech G11 and calls scripts based on the pressed key and selected macro set.
Allows to use up to 15 different sets.

This calls [`macro-manager`](https://github.com/Lucki/macro-manager) in the background so look there on how to do your configuration:
* The set names are `m1`, `m2`, `m3`, `mr`.
* Multiple simultaneous pressed macro keys are concatenated left to right - resulting in e.g. `m1mr`.<br>
  This means, there are now 15 usable macro banks per application.
* The id names are `g1` … `g18`.

This is intended to run in a user environment - e.g. `systemctl --user start g11gkeys.service`

## Installation
Make requires `rust`, [`libg15`](https://gitlab.com/menelkir/libg15), [`xdototool`](https://github.com/jordansissel/xdotool) and `clang`.
It also expects [`macro-manager`](https://github.com/Lucki/macro-manager) in a folder besides this project for now. (`{ path = "../macro-manager" }`)
Build with `make build` or directly with `cargo build --release`.<br>
The executable is in `target/release/g11gkeys`.

Runtime dependencies are [`libg15`](https://gitlab.com/menelkir/libg15) and `clang`.
Optional is [`xdototool`](https://github.com/jordansissel/xdotool).

Install with `make install`.<br>
Adjust `PREFIX` and `DESTDIR` as needed.
