# Usage: ./oot3dhax_geninc.sh <path to yellows8github/3ds_ropkit repo> <codebin path>

$1/generate_ropinclude.sh $2 $1
if [[ $? -ne 0 ]]; then
	echo "//ERROR: 3ds_ropkit generate_ropinclude.sh returned an error."
	exit 1
fi

echo ""

# Calls srv_RegisterClient(), increments *r6, L_30aedc(sp+0), then executes "pop {r3, r4, r5, r6, r7, pc}". L_30aedc decreases *(inr0+8) by 1, and returns if that's >0 after decreasing it.
printstr=`ropgadget_patternfinder $2 --baseaddr=0x100000 --patterntype=sha256 --patterndata=1ebc0da2afb0458cd1130bb759b3ee38359a3e157825bd4fbc850d682019b66d --patterndatamask=000000ffffffffffffffffffffffffffffffffffffffffff000000ffffffffffffffffff0000000000000000ffffffffffffffffffffffff --patternsha256size=0x38 "--plainout=#define srvinit_RegisterClient "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: srvinit_RegisterClient not found."
	exit 1
fi

# mov r4, r0. ptr = inr0, if(*ptr)svcCloseHandle(*ptr). *ptr = 0, r0 = ptr, "pop {r4, pc}".
printstr=`ropgadget_patternfinder $2 --baseaddr=0x100000 --patterntype=sha256 --patterndata=21665d66ea3ddfbdd79414c8d822e69303e74b5ac7bce44aaedf9bd7013b5e39 --patternsha256size=0x24 "--plainout=#define CLOSEHANDLE "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: CLOSEHANDLE not found."
	exit 1
fi

# Stores r0 from "mrc 15, 0, r0, cr13, cr0, {3}" to r3+4, increments the word @ r3+8, r0=1 then pop {r4} bx	lr
printstr=`ropgadget_patternfinder $2 --baseaddr=0x100000 --patterntype=sha256 --patterndata=4756715c4a4e99e6c2ca7ff72bd4ea4115713e1c9d36983b27285dafb5b45114 --patternsha256size=0x20 "--plainout=#define GETTHREADSTORAGE "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GETTHREADSTORAGE not found."
	exit 1
fi

# r4 = r0 + r1<<2. classptr = *(r5+0x38). Calls vtable funcptr +16 with r3 for the funcptr, r2=*r4, r1=<ptr loaded from pool>
printstr=`ropgadget_patternfinder $2 --baseaddr=0x100000 --patterntype=sha256 --patterndata=23231e1ffd8a1c7334687414fcd4d63435c4d1279c86f85806da4b6438a236d3 --patternsha256size=0x24 "--plainout=#define ADDSHIFTVAL_BLXR3 "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: ADDSHIFTVAL_BLXR3 not found."
	exit 1
fi

echo -e "\n#define ROPBUF 0x00587958"
