/*
	Anti Two-Shot ~ Kevin-Reinke

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

// ** INCLUDES

#include <a_samp>

// ** DEFINES

// *** FUNCTIONS

// **** KEY SIMULATIONS

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// ** VARIABLES

// *** PER-PLAYER VARIABLES

// **** GENERAL

new bool:pTwoShotting[MAX_PLAYERS],
pLastBulletAmount[MAX_PLAYERS],
bool:pFiredSawnoff[MAX_PLAYERS],
bool:pAttemptingTwoShot[MAX_PLAYERS];

// **** TIMERS

new ptmTwoShotFreezeOver[MAX_PLAYERS];

// **** TIMESTAMPS

new ptsAttemptingToBypassSystem[MAX_PLAYERS];

// ** CALLBACKS

public OnFilterScriptInit()
{
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	ResetPlayerVariables(playerid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!pTwoShotting[playerid])
	{
		if(PRESSED(KEY_FIRE))
		{
			switch(GetPlayerWeapon(playerid))
			{
				case WEAPON_SAWEDOFF:
				{
					new ammo = GetPlayerAmmo(playerid);
					if(((gettime() - ptsAttemptingToBypassSystem[playerid]) < 2) || (pAttemptingTwoShot[playerid] && (pLastBulletAmount[playerid] - ammo) == 2))
					{
						TogglePlayerControllable(playerid, false);

						pTwoShotting[playerid] = true;

						GameTextForPlayer(playerid, "~r~~h~DON'T 2-SHOT!", 3000, 4);

						KillTimer(ptmTwoShotFreezeOver[playerid]);
						ptmTwoShotFreezeOver[playerid] = SetTimerEx("TwoShotFreezeOver", 1500, false, "i", playerid);
					}

					pLastBulletAmount[playerid] = ammo;
					pFiredSawnoff[playerid] = true;
					pAttemptingTwoShot[playerid] = false;
				}
				default:
				{
					pAttemptingTwoShot[playerid] = false;
					ptsAttemptingToBypassSystem[playerid] = gettime();
				}
			}
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(pFiredSawnoff[playerid] && GetPlayerWeapon(playerid) != WEAPON_SAWEDOFF)
	{
		pFiredSawnoff[playerid] = false;
		pAttemptingTwoShot[playerid] = true;
	}

	if(pAttemptingTwoShot[playerid])
	{
		new anim_library[32], anim_name[32];
		GetAnimationName(GetPlayerAnimationIndex(playerid), anim_library, 32, anim_name, 32);

		if(!strcmp(anim_name, "sawnoff_reload", true))
		{
			pLastBulletAmount[playerid] = GetPlayerAmmo(playerid);
			pAttemptingTwoShot[playerid] = false;
		}
	}
	return 1;
}

// ** LOAD PLAYER COMPONENTS

stock ResetPlayerVariables(playerid)
{
	// ** GENERAL

	pTwoShotting[playerid] = false;
	pLastBulletAmount[playerid] = 0;
	pFiredSawnoff[playerid] = false;
	pAttemptingTwoShot[playerid] = false;

	// ** TIMERS

	KillTimer(ptmTwoShotFreezeOver[playerid]);

	// ** TIMESTAMPS

	ptsAttemptingToBypassSystem[playerid] = 0;
	return 1;
}

// ** FUNCTIONS

forward TwoShotFreezeOver(playerid);
public TwoShotFreezeOver(playerid)
{
	TogglePlayerControllable(playerid, true);

	pTwoShotting[playerid] = false;
	return 1;
}