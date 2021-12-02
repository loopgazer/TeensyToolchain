SOURCE=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
ARCHIVE=$(basename ${SOURCE})
PKGS="/home/$USER/.platformio/packages"
TOOLCHAIN="toolchain-gccarmnoneeabi"
REVISION="10.3"
CURRENT="1.50401.190816"

function headline() { echo && echo && echo ">> ${1^^} <<" && echo; }

headline "Removing previous toolchain package"

rm -rf ${PKGS}/${TOOLCHAIN}

headline "Preparing Temp"

mkdir -p temp && cd temp && echo "Successfully entered temp path."

headline "Fetching Stock Toolchain Base"

platformio platform install teensy

headline "Collecting Patch Files"

cp -v ${PKGS}/${TOOLCHAIN}/arm-none-eabi/lib/*.a ./ && echo "Collected missing libraries."
cp -v ${PKGS}/${TOOLCHAIN}/package.json ./ && echo "Collected missing manifest."
cp -v ${PKGS}/${TOOLCHAIN}/.piopm ./ && echo "Collected missing pm file."

headline "Downloading latest toolchain"

if ! [ -f ${ARCHIVE} ]; then
  echo "From: ${SOURCE}..." && curl -#SL -o ${ARCHIVE} ${SOURCE}
else
  echo "Toolchain ${ARCHIVE} already exists!"
fi

headline "Extracting Archive"

if ! [ -d ${TOOLCHAIN} ]; then
  echo "Extracting to ${TOOLCHAIN}..."
  mkdir -p ${TOOLCHAIN} && tar -C ${TOOLCHAIN} -xvjf ${ARCHIVE} --strip-components=1
else
  echo "Toolchain seems to be extracted already."
fi

headline "Applying Libraries"

cp -v ./*.a ${TOOLCHAIN}/arm-none-eabi/lib/

headline "Fixing and applying Metadata"

pattern="s/${CURRENT}/${REVISION}/"

sed "${pattern}" package.json >${TOOLCHAIN}/package.json
sed "${pattern}" .piopm >${TOOLCHAIN}/.piopm

headline "Removing Stock Toolchain"

rm -rf ${PKGS}/${TOOLCHAIN}

headline "Publishing latest toolchain"

cp -vr ${TOOLCHAIN}/ ${PKGS}/${TOOLCHAIN}/ && echo "Successfully published"

cd .. && echo "${PWD} was entered"

headline "Reinitializing Project"

platformio project init --ide vscode --board teensy41 \
  --project-option="platform_packages=${TOOLCHAIN}@${REVISION}" \
  --project-option="build_unflags= -std=c++11" \
  --project-option="build_flags= -std=gnu++20"

headline "Generating Payload"

touch src/firmware.cxx

cat <<EOF >src/firmware.cxx
#include "Arduino.h"
#include <vector>

std::vector<int> vect1{4, 'z', 'k'};

auto setup() -> void
{
    while (!Serial and millis() < 4000)
    {
        continue;
    }

    Serial.println("Done.");
}

auto last = 0;

auto loop() -> void
{
    if (millis() > last + 1000)
    {
        last = millis();
        Serial.println(vect1[millis() % (unsigned long)vect1.size()]);
    }
}

EOF

headline "Build, Upload and Monitor"

platformio run -e teensy41 --target upload && sleep 1 &&
  platformio run -e teensy41 --target monitor
