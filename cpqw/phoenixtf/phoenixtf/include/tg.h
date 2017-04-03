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
 *  $Id: tg.h,v 1.10 2006/03/04 15:10:06 AngelD Exp $
 */

#define TG_CONC_IMPULSE 205
#define TG_FLASH_IMPULSE 206
#define TG_EFF_REMOVE_IMPULSE 207

#define TG_MAINMENU_IMPULSE 220
#define TG_SG_REBUILD_IMPULSE 221
#define TG_SG_RELOAD_IMPULSE 222
#define TG_SG_UPGRADE_IMPULSE 223
#define TG_DISP_LOAD_IMPULSE 224
#define TG_DISP_UNLOAD_IMPULSE 225

typedef enum tg_sg_find_e
{
 TG_SG_FIND_IGNORE_TEAM,
 TG_SG_FIND_IGNORE_OWNER,
 TG_SG_FIND_IGNORE_OFF,
 TG_SG_FIND_IGNORE_ALL,
 TG_SG_FIND_IGNORE_NUM
}tg_sg_find_t;

typedef enum tg_sg_fire_e
{
 TG_SG_FIRE_NORMAL,
 TG_SG_FIRE_BULLETS,
 TG_SG_FIRE_LIGHTING,
 TG_SG_FIRE_NUM
}tg_sg_fire_t;

typedef enum tg_detpack_clip_e
{
	TG_DETPACK_CLIP_OWNER,
	TG_DETPACK_CLIP_ALL,
	TG_DETPACK_SOLID_ALL,
	TG_DETPACK_CLIP_NUM
}tg_detpack_clip_t;

typedef enum tg_gren_effect_e
{
	TG_GREN_EFFECT_ON,
	TG_GREN_EFFECT_OFF,
	TG_GREN_EFFECT_OFF_FORSELF,
	TG_GREN_EFFECT_NUM
}tg_gren_effect_t;


typedef struct tf_tg_server_data_s{
 int                    tg_enabled;
 int                    godmode;
 int                    unlimit_ammo,unlimit_grens;
 int                    disable_reload;
 int                    detpack_clip;
 int                    detpack_drop;   // 1 can drop, 0 - cannot
 int                    disable_disarm; // 0 normal, 1 - disable
 tg_gren_effect_t       gren_effect;    //0 -default, 1 - off for all, 2 off for self
 int                    gren_time;      //0 -full time , 10 ,5 in sek

 tg_sg_find_t   sg_allow_find;
 int            sg_disable_fire;
 qboolean       sg_fire_bullets,
                sg_fire_rockets,
                sg_fire_lighting;
 qboolean       sg_unlimit_ammo;
// tg_sg_fire_t sg_fire_type;
 int tg_sbar;
}tf_tg_server_data_t;

extern tf_tg_server_data_t tg_data;

void	TG_Eff_Conc(gedict_t *head);
void	TG_Eff_Flash(gedict_t *te);
void	TG_Eff_Remove(gedict_t *pl);
void 	TG_LoadSettings();

void    Eng_StaticSG_Activate(  );
void    Eng_SGUp(  );
void    Eng_SGReload(  );
void    Eng_DispLoad(  );
void    Eng_DispUnload(  );
