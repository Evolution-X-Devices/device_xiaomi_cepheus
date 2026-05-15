# Device tree for Xiaomi Mi 9 (cepheus)

| Device          | Specs                          |
| --------------- | ------------------------------ |
| SoC             | Qualcomm Snapdragon 855 (SM8150) |
| CPU             | 8x Kryo 485 (1x 2.84 GHz + 3x 2.42 GHz + 4x 1.78 GHz) |
| GPU             | Adreno 640                     |
| RAM             | 6/8 GB LPDDR4X                 |
| Storage         | 64/128 GB UFS 2.1              |
| Display         | 6.39" FHD+ (1080×2340) AMOLED  |
| Fingerprint     | Optical under-display (FOD)    |
| Kernel          | Linux 4.14                     |

## Branch: lineage-23.2

Based on [LineageOS](https://github.com/LineageOS/android_device_xiaomi_cepheus) device tree, adapted for Android 16 builds.

## Features

- FOD (under-display fingerprint) with screen-off unlock
- DT2W (double tap to wake)
- Color modes: Saturated / Natural / Boosted
- Smooth cutout overlay
- PowerHAL configuration for DT2W

## Building

```bash
source build/envsetup.sh
lunch lineage_cepheus-userdebug
mka
```
