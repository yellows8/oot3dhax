# build_saveimages.sh serverip <readbuf in the linermem area, such as 0x3E220000> <proc9_patchaddr> <save region for the user gamecard> <otherapp payload filename for the user gamecard>

set -e

serverip=$1
readbuf=$2
patchaddr=$3

function init_keyslots
{
	3dshaxclient --serveradr=$serverip --keyslot=33 "--keyY=$1$2"fe009000000000
	3dshaxclient --serveradr=$serverip --keyslot=37 "--keyY=$1$2"fe009000000000
}

function build_region
{
	init_keyslots `cat accessdescsig_oot3d$1` "$3"

	rm -f clientscript

	for path in otherapp_payloads/otherapp/*_$2_*;
	do
		filename=$(basename "$path")
		basefn=$(echo -n "$filename" | cut "-d." -f1)
		echo "Building with payload: $filename"
		savedir=saveimages/cardids_"$3"fe009000000000/$1
		mkdir -p $savedir
		./build_saveimage_clientcmds.sh $serverip $readbuf $savedir/$basefn.sav oot3dhax_$1.bin "$path" >> clientscript
	done

	echo "quit" >> clientscript

	echo "Running clientscript..."
	cat clientscript | 3dshaxclient --serveradr=$serverip --shell=0
}

rm -R -f saveimages
mkdir -p saveimages

rm -R -f otherapp_payloads
rm -f othrapp.zip
curl -v https://smealum.github.io/ninjhax2/otherapp.zip > otherapp.zip
unzip otherapp.zip -d otherapp_payloads

# Temporarily NOP-out the Process9 code which sets the gamecard savedata keyslots' keyY.
3dshaxclient --serveradr=$serverip "--customcmd=readmem:9 $patchaddr 0xc @tmpcode.bin"
3dshaxclient --serveradr=$serverip "--customcmd=writemem:9 $patchaddr 0xc 0x0 0x0 0x0"

build_region "usa" "U" "c2"
build_region "usa" "U" "45"

build_region "eur" "E" "c2"
build_region "eur" "E" "45"

build_region "jpn" "J" "c2"
build_region "jpn" "J" "45"

echo "Building for your own gamecard..."
init_keyslots `cat accessdescsig_oot3dusa` "c2"
./build_saveimage_clientcmds.sh $serverip $readbuf savedump_usergamecardoot3dhax.bin oot3dhax_$4.bin otherapp_payloads/otherapp/$5 | 3dshaxclient --serveradr=$serverip --shell=0

3dshaxclient --serveradr=$serverip "--customcmd=writemem:9 $patchaddr 0xc @tmpcode.bin"

