#!/bin/bash
#
# Copyright (C) 2018-2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=cepheus
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}"/../../..

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    system_ext/lib64/libwfdnative.so)
        patchelf --remove-needed "android.hidl.base@1.0.so" "${2}"
        ;;
    vendor/bin/mi_thermald)
            sed -i 's/%d\/on/%d\/../g' "${2}"
        ;;
    vendor/lib64/hw/camera.qcom.so)
        patchelf --remove-needed "libMegviiFacepp-0.5.2.so" "${2}"
        patchelf --remove-needed "libmegface.so" "${2}"
        patchelf --add-needed "libshim_megvii.so" "${2}"
        ;;
    vendor/lib64/camera/components/com.qti.node.watermark.so)
        "${PATCHELF}" --add-needed "libwatermark_shim.so" "${2}"
        ;;
    proprietary/vendor/bin/sensors.qti | proprietary/vendor/lib64/libsnsapi.so | proprietary/vendor/lib64/libsnsdiaglog.so | proprietary/vendor/lib64/libssc.so | proprietary/vendor/lib64/libwvhidl.so | proprietary/vendor/lib64/mediadrm/libwvdrmengine.so | proprietary/vendor/lib64/sensors.ssc.so )
        "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
        ;;
    vendor/lib/libstagefright_soft_ddpdec.so | vendor/lib/libstagefright_soft_ac4dec.so | \
    vendor/lib/libstagefrightdolby.so | vendor/lib64/libstagefright_soft_ddpdec.so | \
    vendor/lib64/libdlbdsservice.so | vendor/lib64/libstagefright_soft_ac4dec.so | vendor/lib64/libstagefrightdolby.so)
        "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
