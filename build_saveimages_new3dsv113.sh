# build_saveimages_new3dsv113.sh serverip <readbuf in the linermem area, such as 0x3E220000> <save region for the user gamecard> <otherapp payload filename for the user gamecard> <github_repos/Myriachan/Powersaves3DS/MakePowersave.py filepath>
./build_saveimages.sh $1 $2 0x0802ecd8 $3 $4
./build_powersaves.sh $5
