#!/usr/bin/bash

set -eoux pipefail

CONTAINER=${CONTAINER:-}

echo "::group::Executing build-gnome-extensions"
trap 'echo "::endgroup::"' EXIT

if [ -n "$CONTAINER" ]; then
    # Install tooling
    git submodule update --init --recursive
    dnf5 -y install glib2-devel
fi

rm -rf caffeine@patapon.info blur-my-shell@aunetx

# Build Extensions
glib-compile-schemas ./logomenu@aryan_k/schemas
glib-compile-schemas ./compiz-windows-effect@hermes83.github.com/schemas
glib-compile-schemas ./compiz-alike-magic-lamp-effect@hermes83.github.com/schemas
glib-compile-schemas ./hotedge@jonathan.jdoda.ca/schemas
glib-compile-schemas ./restartto@tiagoporsch.github.io/schemas
glib-compile-schemas ./appindicatorsupport@rgcjonas.gmail.com/schemas
glib-compile-schemas ./add-to-steam@pupper.space/schemas
cp -r ./stage/caffeine/caffeine@patapon.info ./caffeine@patapon.info
glib-compile-schemas ./caffeine@patapon.info/schemas

# Burn My Windows
make -C ./burn-my-windows@schneegans.github.com
glib-compile-schemas ./burn-my-windows@schneegans.github.com/schemas
rm ./burn-my-windows@schneegans.github.com/burn-my-windows@schneegans.github.com.zip

# Desktop Cube
make -C ./desktop-cube@schneegans.github.com
glib-compile-schemas ./desktop-cube@schneegans.github.com/schemas
rm ./desktop-cube@schneegans.github.com/desktop-cube@schneegans.github.com.zip

# Blur My Shell
make -C ./stage/blur-my-shell build
unzip -o ./stage/blur-my-shell/build/blur-my-shell@aunetx.shell-extension.zip -d ./blur-my-shell@aunetx
glib-compile-schemas ./blur-my-shell@aunetx/schemas
rm -rf ./blur-my-shell@aunetx/build

# Cleanup
if [ -n "$CONTAINER" ]; then
    dnf5 -y remove glib2-devel
    mkdir -p /usr/share/gnome-shell/extensions/
    rm -rf stage .git*
    cp -r "./*" /usr/share/gnome-shell/extensions/
fi