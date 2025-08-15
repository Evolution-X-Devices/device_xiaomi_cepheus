#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    "device/xiaomi/cepheus",
	"hardware/qcom-caf/sm8150",
	"hardware/qcom-caf/wlan",
	"hardware/xiaomi",
	"vendor/qcom/opensource/dataservices",
	"vendor/qcom/opensource/commonsys-intf/display",
	"vendor/qcom/opensource/commonsys/display",
	"vendor/qcom/opensource/display",
	"vendor/qcom/common/system/telephony",
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'vendor.qti.hardware.bluetooth_audio@2.0.so',
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    'vendor/lib64/libwvhidl.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v34.so')
        .add_needed('libcrypto_shim.so'),
    'vendor/lib64/mediadrm/libwvdrmengine.so': blob_fixup()
        .add_needed('libcrypto_shim.so'),
    'vendor/lib64/camera/components/com.qti.node.watermark.so': blob_fixup()
        .add_needed('libpiex_shim.so'),
    'vendor/etc/init/init.batterysecret.rc': blob_fixup()
        .regex_replace(' +seclabel u:r:batterysecret:s0\n', ''),
    'vendor/lib/libaudioroute_ext.so': blob_fixup()
        .replace_needed('libaudioroute.so', 'libaudioroute-v34.so'),
    'vendor/lib/hw/audio.primary.msmnile.so': blob_fixup()
        .replace_needed('libaudioroute.so', 'libaudioroute-v34.so'),
    'vendor/lib64/hw/audio.primary.msmnile.so': blob_fixup()
        .replace_needed('libaudioroute.so', 'libaudioroute-v34.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'cepheus',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
