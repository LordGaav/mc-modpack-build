#!/bin/bash

echo "Loading config..."

if [ ! -r "config.sh" ]; then
	echo "Could not read config.sh, make sure it exists and is readable!"
	exit 1
fi

source "config.sh"

set -e

echo "Using temp dir '$TMPDIR'"

echo "Building client MultiMC compatible structure..."
SPROOT="$TMPDIR/$PACKNAME"

mkdir -v "$SPROOT"
mkdir -v "$SPROOT/minecraft"
mkdir -v "$SPROOT/minecraft/config"
mkdir -v "$SPROOT/minecraft/mods"
mkdir -v "$SPROOT/minecraft/resourcepacks"

echo "Copying files..."

cp -r $MULTIMCTEMPLATEDIR/meta/* "$SPROOT/"
cp -r $MULTIMCTEMPLATEDIR/instance/* "$SPROOT/minecraft/"
cp -r $CONFIGDIR/* "$SPROOT/minecraft/config/"
cp -r $MODSDIR/* "$SPROOT/minecraft/mods/"
cp -r $RESOURCEPACKDIR/* "$SPROOT/minecraft/resourcepacks/"

FILENAME="$OUTPUTDIR/$PACKNAME-client_${PACKVERSION}.zip"

if [ -f "$FILENAME" ]; then
	echo "Removing old version of archive..."
	rm -v "$FILENAME"
fi

echo "Creating archive..."

(cd "$TMPDIR" && zip -q0vr "$FILENAME" "$PACKNAME")

echo "Building server Forge compatible structure..."
MPROOT="$TMPDIR/forge"

mkdir -v "$MPROOT"
mkdir -v "$MPROOT/config"
mkdir -v "$MPROOT/mods"

echo "Copying files..."

cp $FORGESERVERJAR "$MPROOT/"
cp $MINECRAFTSERVERJAR "$MPROOT/"
cp -r $CONFIGDIR/* "$MPROOT/config/"
cp -r $MODSDIR/* "$MPROOT/mods/"

echo "Creating ServerStart.sh..."
(
cat <<EOF
#!/bin/bash
echo "Starting $PACKNAME version $PACKVERSION daemon"
java -Xms512m -Xmx1500m -jar $(basename ${FORGESERVERJAR}) nogui
EOF
) > "$MPROOT/ServerStart.sh"

chmod +x "$MPROOT/ServerStart.sh"

FILENAME="$OUTPUTDIR/$PACKNAME-server_${PACKVERSION}.zip"

if [ -f "$FILENAME" ]; then
	echo "Removing old version of archive..."
	rm -v "$FILENAME"
fi

echo "Creating archive..."
(cd "$MPROOT" && zip -q0vr "$FILENAME" *)

if [ "$TMPDIRCLEAN" -eq "1" ]; then
	echo "Removing tempdir..."
	rm -r "$TMPDIR"
fi
