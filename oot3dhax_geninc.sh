# Usage: ./oot3dhax_geninc.sh <path to yellows8github/3ds_ropkit repo> <codebin path>

set -e

$1/generate_ropinclude.sh $2 $1

echo ""

echo -e "\n#define ROPBUF 0x00587958"
