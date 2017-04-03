/*
 *  QWProgs-TF2003
 *  Copyright (C) 2004  [sd] angel
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 *  $Id: player.h,v 1.4 2005/05/16 09:35:43 AngelD Exp $
 */
#include "spy.h"

void ThrowGib( char *gibname, float dm );
void Headless_Think();
void player_stand1();
void player_run();
void player_touch();

void player_shot1();
void player_shot2();
void player_shot3();
void player_shot4();
void player_shot5();
void player_shot6();

void player_autorifle1();
void player_autorifle2();
void player_autorifle3();

void player_axe1();
void player_axe2();
void player_axe3();
void player_axe4();
void player_axeb1();
void player_axeb2();
void player_axeb3();
void player_axeb4();
void player_axec1();
void player_axec2();
void player_axec3();
void player_axec4();
void player_axed1();
void player_axed2();
void player_axed3();
void player_axed4();

void player_chain1();
void player_chain1a();
void player_chain2();
void player_chain2a();
void player_chain3();
void player_chain4();
void player_chain5();

void player_medikit1();
void player_medikit2();
void player_medikit3();
void player_medikit4();
void player_medikitb1();
void player_medikitb2();
void player_medikitb3();
void player_medikitb4();
void player_medikitc1();
void player_medikitc2();
void player_medikitc3();
void player_medikitc4();
void player_medikitd1();
void player_medikitd2();
void player_medikitd3();
void player_medikitd4();

void player_bioweapon1();
void player_bioweapon2();
void player_bioweapon3();
void player_bioweapon4();
void player_bioweaponb1();
void player_bioweaponb2();
void player_bioweaponb3();
void player_bioweaponb4();
void player_bioweaponc1();
void player_bioweaponc2();
void player_bioweaponc3();
void player_bioweaponc4();
void player_bioweapond1();
void player_bioweapond2();
void player_bioweapond3();
void player_bioweapond4();

void player_nail1();
void player_nail2();

void player_assaultcannonup1();
void player_assaultcannonup2();
void player_assaultcannon1();
void player_assaultcannon2();
void player_assaultcannondown1();

void player_light1();
void player_light2();

void player_rocket1();
void player_rocket2();
void player_rocket3();
void player_rocket4();
void player_rocket5();
void player_rocket6();

void PainSound();

void player_pain1();
void player_pain2();
void player_pain3();
void player_pain4();
void player_pain5();
void player_pain6();

void player_axpain1();
void player_axpain2();
void player_axpain3();
void player_axpain4();
void player_axpain5();
void player_axpain6();

void player_pain( gedict_t * attacker, float take  );

void player_diea1();
void player_dieb1();
void player_diec1();
void player_died1();
void player_diee1();
void player_die_ax1();

void DeathBubblesSpawn();
void DeathSound();
void PlayerDead();
void KillPlayer();
void GibPlayer();
void PlayerDie();

void set_suicide_frame();
