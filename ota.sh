OTA=$HOME/Android-OTA
OUT=$HOME/android-phh/out/target/product/tdgsi_arm64_ab

version="$(date +v%Y.%m.%d)"

# Get the time when the GSI ROM is built
timestamp=$(cat $OUT/system/build.prop | grep ro.build.date.utc | awk -F "=" '{print $2}')
version=$version-$timestamp

[ -z "timestamp" ] && timestamp="$(date +%s)"
name="treble_arm64_bvN"
fileimg="$OUT/system.img"
filexz="$OTA/$name-13.0-$timestamp.img.xz"
cp $fileimg $HOME/builds/system-$timestamp.img

echo

echo "--> Delelte old and Generating new XZ file"
rm *.xz
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
