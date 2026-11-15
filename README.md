# EasyEffects 8.3.0 speaker preset collection — v4

**55 speaker output presets / 11 physical speaker systems / no headphones / stereo PCM only.**

v4 replaces the **five Creative Pebble V1-V2** profiles. The remaining 50 profiles are unchanged from v3. Preset filename convention stays `Device - Style.json`.

## Creative Pebble V1/V2: why this revision exists

The previous pack could make the analog Pebbles sound flat because its bass/warm profiles combined *Bass Enhancer*, *Bass Loudness*, up to -3.2 dB of EQ input gain and (on gaming) compression. Added DSP can make these tiny speakers sound worse, especially if volume is not matched. **These settings are not measured with a microphone, and results depend on room, DAC and volume.**

This revision deliberately eliminates Bass Loudness, Compressor, Crystalizer and Stereo Tools from all Pebble profiles. Bass has **light** Bass Enhancer; every other profile uses an equalizer only (plus peak limiter for non-neutral profiles). There is no high-pass filter and no artificial stereo width.

| Profile | 125 Hz | 250 Hz | 4 kHz | 8 kHz | Processing |
|---|---:|---:|---:|---:|---|
| Balanced | 0 dB | 0 dB | 0 dB | 0 dB | **Flat EQ-only control** (no limiter); ideally nearly identical to effects bypass |
| Bass | +3.5 dB | +2.3 dB | +0.2 dB | +0.2 dB | EQ, mild Bass Enhancer, Limiter |
| Treble | +0.2 dB | +0.1 dB | +1.6 dB | +1.8 dB | EQ, Limiter |
| Warm & Rich | +2.8 dB | +1.7 dB | +0.2 dB | +0.5 dB | EQ, Limiter |
| Desktop Gaming | +2.3 dB | +1.1 dB | +0.8 dB | +0.3 dB | EQ, Limiter |

EQ preamp is negative on profiles with boosted bands to control digital clipping; it is **0 dB on Balanced**. Increase physical speaker volume modestly when comparing presets so louder is not mistaken for better. Hardware distortion is still possible even with a limiter.

### Audio troubleshooting before further EQ

1. Use **Creative Pebble V1-V2 - Balanced** as a neutral control, then compare to global effects bypass at the **same playback volume**. If Balanced sounds markedly worse, don't keep stacking effects: check EasyEffects routing / PipeWire graph / sample-rate behavior.
2. Compare **Warm & Rich** next (EQ, no artificial bass). Then **Bass**. If either distorts, lower hardware volume and reduce the 125 Hz EQ gain / Bass Enhancer amount.
3. Pebble V1/V2 USB connection supplies power; the 3.5 mm cable carries analog audio. Linux's reported 48/96/192 kHz sample rate describes the sound card DAC / audio graph, **not the analog speakers' operating rate**. Raising the rate does not inherently make the speakers better. The earlier 48 kHz behavior might be changing the DSP/routing, not sound quality. These presets do not edit sample rate.
4. If this is **Pebble V2** with High/Auto gain switch, Creative recommends a separate **5 V / 2 A** supply to enable up to 8 W RMS. An underpowered USB port can cause distortion at higher listening levels. V1 is lower power.
5. For diagnosis, run `pactl info | grep 'Server Name'` and `pw-top` while playing through EasyEffects; compare the graph and physical output device with bypass / changed sample rates. Be cautious about manual PipeWire quantum/rate overrides.

## Safe installer: BACKUP EVERYTHING FIRST

The new `install.sh` **backs up every existing EasyEffects preset in both INPUT and OUTPUT**, **not only speaker presets matching the new names**, into a timestamped `backups/<date>-<unique>/` folder *next to the installer script*. It also preserves the `autoload`, `irs`, and `rnnoise` directories if present (IR files can be large). It includes both Flatpak current data and legacy config roots, plus native EasyEffects data/config roots if installed.

It **verifies the backup** before installing new presets. By default, it **never deletes** unrelated existing presets, nor does it automatically select a new output, change your sample rate, PipeWire setup, or activate any sound effects. The optional `--replace-output` flag clears the Flatpak OUTPUT JSON folder **only after the complete verified backup**; use it if you want exactly the 55 new output presets without older generated names. It does not remove input presets. If there is a backup error, it stops before importing any presets.

**Extract ZIP to a writable directory** (for example, `~/Downloads/EasyEffects-v4`) and run as your normal user, **not `sudo`**:

```bash
bash install.sh --dry-run    # Preview backup sources & changes, make no writes
bash install.sh              # Snapshot all old presets, then add/replace 55 output presets
bash install.sh --replace-output  # Optional CLEAN SLATE: backup then replace all output presets
```

Flatpak destination: `~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/`.

The backups will be e.g. `~/Downloads/EasyEffects-v4/backups/20261115-123000-XXXXXXXX/flatpak-data/output/` alongside the installer. If you move/delete the extracted package folder, **move the `backups/` directory somewhere safe first**.

**Restore example** for an older output preset if desired (adjust backup folder):

```bash
cp -a -- backups/YOUR_BACKUP_FOLDER/flatpak-data/output/. \
  "$HOME/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/"
```

Avoid restoring old custom settings while EasyEffects is editing them. Existing old names from earlier packages are left installed; manually remove them later if no longer needed.

## Other supported speaker systems

- Logitech S120; ThinkPad T470; LG S80QR
- Edifier R1280DB; Logitech Z623; Klipsch ProMedia 2.1 THX
- Bose Companion 2 Series III; Creative Stage V2; Samsung HW-Q990F; Sony HT-S40R

Each retains the five styles created in v3: Balanced, Bass, Treble, and two device-specific styles.
For soundbars with actual Atmos / discrete surround, bypass EasyEffects and let the soundbar receive native surround audio. The software presets target only **stereo PCM** coming from this Linux host.

## References

- Creative Pebble V2 3.5 mm + USB power: https://support.creative.com/kb/ShowArticle.aspx?sid=200196
- Creative Pebble V2 power/gain and distortion guidance: https://support.creative.com/kb/ShowArticle.aspx?sid=200273
- EasyEffects preset paths from official v8.3.0 source: `src/presets_directory_manager.cpp` in https://github.com/wwmm/easyeffects/tree/v8.3.0

**Not hardware-auditioned**: all JSON and installer paths were structurally validated and the install / backup were tested in a simulated HOME; no microphone measurement or actual Flatpak import was possible here.
