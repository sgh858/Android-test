OTA=$HOME/Android-test
OUT=$HOME/android-phh/out/target/product/tdgsi_arm64_ab
ROM_variant=$(cat ~/android-phh/device/phh/treble/treble_arm64_bvN.mk | grep PRODUCT_MODEL | awk -F '[ -]' '{print $4}')

version="$(date +v%Y.%m.%d)"

# Get the time when the GSI ROM is built
timestamp=$(cat $OUT/system/build.prop | grep ro.build.date.utc | awk -F "=" '{print $2}')
version=$version-$timestamp

[ -z "timestamp" ] && timestamp="$(date +%s)"
name="treble_arm64_bvN"
fileimg="$OUT/system.img"
filexz="$OTA/$name-13.0-$timestamp.img.xz"

if [[ $ROM_variant == *bas* || $ROM_variant == *Bas* ]] ; then
    echo "This is for base only, copy FW system-$ROM_variant-$timestamp.img and exitted"
    cp $fileimg $HOME/builds/system-$ROM_variant-$timestamp.img
    exit 0
fi

cp $fileimg $HOME/builds/system-$ROM_variant-$timestamp.img

rm $OTA/*.img
#echo "--> Generate Sparse Image"
#img2simg $fileimg $OTA/system-$ROM_variant-$timestamp.img
cp $fileimg $OTA/system-$ROM_variant-$timestamp.img

echo "--> Delelte old and Generating new XZ file"
rm $OTA/*.xz
xz -cv $fileimg -T0 > $filexz

echo "--> Generating OTA json file"

size=$(wc -c $filexz | awk '{print $1}')
url="https://github.com/sgh858/Android-test/raw/main/$name-13.0-$timestamp.img.xz"

json="{\n\t\"version\": \"$version\",\n\t\"date\": \"$timestamp\",\n\t\"variants\": ["
json="${json}\n\t\t{\n\t\t\t\"name\": \"$name\",\n\t\t\t\"size\": \"$size\",\n\t\t\t\"url\": \"$url\"\n\t\t}"
json="${json%?\n}\n\t]\n}"

echo -e "$json"

echo -e "$json" > $OTA/ota.json

echo
