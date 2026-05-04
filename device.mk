# Copyright (C) 2025-2026 OrangeFox Recovery Project
# Copyright (C) 2026 chickendrop89
# SPDX-License-Identifier: GPL-3.0-only

DEVICE_PATH := device/xiaomi/spring

# Configure Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Enable developer GSI keys
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# OTA device(s)
TARGET_OTA_ASSERT_DEVICE := spring

# Boot control, Kernel prebuilts
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-qti.recovery \
    vendor_kernel_prebuilts

# FastbootD support
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

PRODUCT_PACKAGES += \
    otapreopt_script \
    checkpoint_gc

# Symlink /vendor/firmware to /odm/firmware for haptics and touchfeature
BOARD_ROOT_EXTRA_SYMLINKS += /vendor/firmware:/vendor/odm/firmware

# Stop build system from stripping blobs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root/vendor/odm) \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root/vendor/firmware_mnt)

# API
PRODUCT_SHIPPING_API_LEVEL  := 34
PRODUCT_TARGET_VNDK_VERSION := 35
BOARD_SHIPPING_API_LEVEL := 34
SHIPPING_API_LEVEL := 34

# Display Size & Density
TARGET_SCREEN_HEIGHT  := 2340
TARGET_SCREEN_DENSITY := 450
TARGET_SCREEN_WIDTH   := 1080

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION  := false

# Virtual A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    odm \
    product \
    recovery \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(DEVICE_PATH)/security/miui

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
	$(DEVICE_PATH) \
	vendor/qcom/opensource/commonsys-intf/display

# TWRP - Specifics
TW_THEME                := portrait_hdpi
TW_DEFAULT_LANGUAGE     := en
TW_USE_TOOLBOX          := true
TW_INCLUDE_NTFS_3G      := true
TW_INCLUDE_RESETPROP    := true
TW_INCLUDE_LIBRESETPROP := true
TW_MAX_BRIGHTNESS       := 4095
TW_EXTRA_LANGUAGES      := true
TW_DEFAULT_BRIGHTNESS   := 2047
TW_EXCLUDE_APEX         := true
TW_INCLUDE_FASTBOOTD    := true
TWRP_INCLUDE_LOGCAT     := true
TW_INCLUDE_PYTHON       := true
TW_NO_SCREEN_BLANK      := true
TW_FRAMERATE            := 120

# Blacklist Goodix fingerprint. There's no reason to include this input in recovery
TW_INPUT_BLACKLIST := "uinput-goodix"

TW_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone14/temp"
TW_BRIGHTNESS_PATH      := "/sys/class/backlight/panel0-backlight/brightness"

TW_LOAD_VENDOR_MODULES  += "adsp_loader_dlkm.ko qpnp-smb5-main.ko 
TW_LOAD_VENDOR_MODULES  += leds-qpnp-vibrator-ldo.ko camera.ko
TW_LOAD_VENDOR_MODULES  += focaltech_spi.ko nt36xxx_spi.ko xiaomi_tp.ko"

TW_EXCLUDE_DEFAULT_USB_INIT   := true
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true

TW_SUPPORT_INPUT_AIDL_HAPTICS := true
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/default"
TW_SUPPORT_INPUT_AIDL_HAPTICS_FIX_OFF := true

# TWRP - Crypto
TW_INCLUDE_CRYPTO               := true
TW_INCLUDE_CRYPTO_FBE           := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_QCOM_FBE_DECRYPTION  := true

PLATFORM_VERSION                := 99.87.36
PLATFORM_VERSION_LAST_STABLE    := $(PLATFORM_VERSION)

PLATFORM_SECURITY_PATCH := 2127-12-31
VENDOR_SECURITY_PATCH   := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH     := $(PLATFORM_SECURITY_PATCH)
