# Quake Custom Team Fortress

**COMPILES yet it requires cpqw and crashes upon a player join**

The compiled qwprogs.dat is included in the fortress folder along with the server config scripts. The server configs are setup to run with any modification, though you may want to change the server name and rcon. (assuming that this mod is converted to MVDSV)

To compile CUSTOM TEAM FORTRESS (GMQCC is used)

git clone git://github.com/graphitemaster/gmqcc.git

cd gmqcc

make

copy the compiled gmqcc into the cutf_4tp folder

sudo chmod -R 777 cutf_4tp

cd cutf_4tp

./gmqcc -O3
