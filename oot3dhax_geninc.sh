# Usage: ./oot3dhax_geninc.sh <path to yellows8github/3ds_ropkit repo> <codebin path>

set -e

$1/generate_ropinclude.sh $2 $1

echo ""

# Calls srv_RegisterClient(), increments *r6, L_30aedc(sp+0), then executes "pop {r3, r4, r5, r6, r7, pc}". L_30aedc decreases *(inr0+8) by 1, and returns if that's >0 after decreasing it.
printstr=`ropgadget_patternfinder $2 --baseaddr=0x100000 --patterntype=sha256 --patterndata=1ebc0da2afb0458cd1130bb759b3ee38359a3e157825bd4fbc850d682019b66d --patterndatamask=000000ffffffffffffffffffffffffffffffffffffffffff000000ffffffffffffffffff0000000000000000ffffffffffffffffffffffff --patternsha256size=0x38 "--plainout=#define srvinit_RegisterClient "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: srvinit_RegisterClient not found."
	exit 1
fi

echo -e "\n#define ROPBUF 0x00587958"
