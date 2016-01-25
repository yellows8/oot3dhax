# build_powersaves.sh <github_repos/Myriachan/Powersaves3DS/MakePowersave.py filepath>

set -e

rm -R -f saveimages_powersaves
mkdir -p saveimages_powersaves

buildcmd=$1

for path in saveimages/*/*/*;
do
	filenamebase=$(basename "$path")
	filenamebase=$(echo -n "$filenamebase" | cut "-d." -f1)
	basepath=$(echo -n "$path" | cut "-d/" -f2- | cut "-d." -f1)
	basepathdir=$(echo -n "$basepath" | cut "-d/" -f1-2)
	echo "Building save: $filenamebase"

	mkdir -p saveimages_powersaves/$basepathdir
	python $buildcmd saveimages/$basepath.sav saveimages_powersaves/$basepath.bin "$filenamebase"
done

