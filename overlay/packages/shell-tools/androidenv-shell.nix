{ pkgs ? import (builtins.fetchTarball {
    name = "nixos-unstable";
    url = "https://github.com/nixos/nixpkgs/archive/7e9b0dff974c89e070da1ad85713ff3c20b0ca97.tar.gz";
    sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
  }) {
  config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
} }:

let
  android = {
    versions = {
      tools = "26.1.1";
      platformTools = "31.0.2";
      buildTools = "30.0.2";
      ndk = [
        "22.1.7171670"
        "21.3.6528147" # LTS NDK
      ];
      cmake = "3.18.1";
      # emulator = "30.6.3";
      emulator = "30.5.5";
    };

    platforms = [
      # "23"
      "24"
      # "25" "26" "27" "28" "29"
      "30"
    ];
    abis = ["x86" "x86_64" "armeabi-v7a" "arm64-v8a"];
    extras = [
      "extras;google;gcm"
      "extras;google;admob_ads_sdk"
      "extras;google;analytics_sdk_v2"
    ];
  };

  # If you copy this example out of nixpkgs, something like this will work:
  /*androidEnvNixpkgs = fetchTarball {
    name = "androidenv";
    url = https://github.com/NixOS/nixpkgs/archive/<fill me in from Git>.tar.gz;
    sha256 = "<fill me in with nix-prefetch-url --unpack>";
  };
  androidEnv = pkgs.callPackage "${androidEnvNixpkgs}/pkgs/development/mobile/androidenv" {
    inherit config pkgs pkgs_i686;
    licenseAccepted = true;
  };*/

  # Otherwise, just use the in-tree androidenv:
  androidEnv = pkgs.androidenv;
#  androidEnv = pkgs.callPackage ./.. {
#    inherit config pkgs pkgs_i686;
#    licenseAccepted = true;
#  };

  androidComposition = androidEnv.composeAndroidPackages {
    toolsVersion = android.versions.tools;
    platformToolsVersion = android.versions.platformTools;
    buildToolsVersions = [android.versions.buildTools];
    platformVersions = android.platforms;
    abiVersions = android.abis;

    includeSources = true;
    includeSystemImages = true;
    includeEmulator = true;
    emulatorVersion = android.versions.emulator;

    includeNDK = true;
    ndkVersions = android.versions.ndk;
    cmakeVersions = [android.versions.cmake];

    useGoogleAPIs = true;
    includeExtras = android.extras;

    # If you want to use a custom repo JSON:
    # repoJson = ../repo.json;

    # If you want to use custom repo XMLs:
    /*repoXmls = {
      packages = [ ../xml/repository2-1.xml ];
      images = [
        ../xml/android-sys-img2-1.xml
        ../xml/android-tv-sys-img2-1.xml
        ../xml/android-wear-sys-img2-1.xml
        ../xml/android-wear-cn-sys-img2-1.xml
        ../xml/google_apis-sys-img2-1.xml
        ../xml/google_apis_playstore-sys-img2-1.xml
      ];
      addons = [ ../xml/addon2-1.xml ];
    };*/

    # Accepting more licenses declaratively:
    extraLicenses = [
      # Already accepted for you with the global accept_license = true or
      # licenseAccepted = true on androidenv.
      # "android-sdk-license"

      # These aren't, but are useful for more uncommon setups.
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;
  platformTools = androidComposition.platform-tools;
  jdk = pkgs.jdk11;

  clojure-dalvik = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "xoreaxebx";
    repo = "clojure";
    rev = "dba59f834dfc56cdc17176d1a329b0b06f79d21b";
    sha256 = "1dwa0nwgk7avgmqmdxn4nfrxp9svaww2fa1mbw1ijmc7k7vw0a3h";
  }) { };

in

pkgs.mkShell rec {
  name = "androidenv-demo";
  packages = [
    androidSdk
    platformTools
    jdk
    pkgs.gradle
    # pkgs.glibc
  ];

  LANG = "C.UTF-8";
  LC_ALL = "C.UTF-8";
  JAVA_HOME = jdk.home;

  # Note: ANDROID_HOME is deprecated. Use ANDROID_SDK_ROOT.
  ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";

  # Ensures that we don't have to use a FHS env by using the nix store's aapt2.
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${android.versions.buildTools}/aapt2";

  CLOJURE_DALVIK="${clojure-dalvik}/clojure.jar";

  shellHook = ''
    # Add cmake to the path.
    cmake_root="$(echo "$ANDROID_SDK_ROOT/cmake/${android.versions.cmake}"*/)"
    export PATH="$cmake_root/bin:$PATH"
    # Write out local.properties for Android Studio.
    cat <<EOF > local.properties
# This file was automatically generated by nix-shell.
sdk.dir=$ANDROID_SDK_ROOT
ndk.dir=$ANDROID_NDK_ROOT
cmake.dir=$cmake_root
EOF
    cat local.properties
  '';
}
