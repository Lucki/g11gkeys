# G11GKeys

Listenes for G-Keys on the Logitech G11 and calls scripts based on the pressed key and selected macro set.
Allows to use up to 15 different sets.

This calls [`macro-manager`](https://github.com/Lucki/macro-manager) in the background so verify your config.
* The set names are `m1`, `m2`, `m3`, `mr`. Multiple simultanous pressed macro keys are concanated left to right - resulting in e.g. `m1mr`.
* The id names are `g1` … `g18`.

This is intended to run in a user environment - e.g. `systemctl --user start g11gkeys.service`
