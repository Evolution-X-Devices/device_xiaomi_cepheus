#!/usr/bin/env sh

_top=${ANDROID_BUILD_TOP}
_mkernel=${_top}/kernel/xiaomi/sm8150
_mtree=${_top}/device/xiaomi/cepheus/kernel_patches
_mkernel_lineage_head=$(git -C ${_mkernel} rev-parse github-non-los/lineage-20)
_mkernel_current_head=$(git -C ${_mkernel} rev-parse HEAD)

# hax: js abort first. who knows what we dealing with
# pipe true so jerkins wont bitch about it and kill itself
git -C ${_mkernel} am --abort || true

if [[ ${_mkernel_current_head} == ${_mkernel_lineage_head} ]]; then
    # note that we dont pipe true here since we wont get a working kernel, throws an error so i can fix my shit
    (git -C ${_mkernel} am ${_mtree}/*.patch > /dev/null) || echo "Failed to apply kernel patches from ${_mtree} to ${_mkernel}."
else
    # already patched.
    echo "Skipping kernel patches"
fi
