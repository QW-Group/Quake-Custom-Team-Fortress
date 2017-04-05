# Quake Custom Team Fortress

http://downloads.sourceforge.net/customtf/cutf-clientpack-2.0.7z?download

**COMPILES & currently requires MVDSV**

The compiled qwprogs.dat is included in the fortress folder along with the server config scripts and it works with MVDSV. The server configs are setup to run with any modification, though you may want to change the server name and rcon.

**To compile CUSTOM TEAM FORTRESS mod (GMQCC is used)**

git clone git://github.com/graphitemaster/gmqcc.git

cd gmqcc

make

copy the compiled gmqcc into the cutf_4tp folder

sudo chmod -R 777 cutf_4tp

cd cutf_4tp

./gmqcc -O3

cd prozaccoop

./gmqcc -O3


**To compile cpqw (not recomended)**

sudo apt-get install libmysqlclient-dev #(this is a little confusing but appears to be for server statistics)

cd cpqw

make all -j4

cd release

strip --strip-unneeded --remove-section=.comment cpqw
