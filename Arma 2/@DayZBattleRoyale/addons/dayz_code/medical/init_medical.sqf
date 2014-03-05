// init_related_scripts.sqf ArmA2 revive
// � AUGUST 2010 - norrin

// Functions

// Added pvEH - scripts modified to remove the need for sending long strings via setVehicleInit to reduce network traffic and JIP load - 04072010

// INCLUDE REQUIRED GAME CODES
#include "\ca\editor\Data\Scripts\dikCodes.h"

//Settings
usec_bandage_recovery = 5;		//time to recover after bandaging

//"colorCorrections" ppEffectEnable true;
//"dynamicBlur" ppEffectEnable true;

//[man2] call fnc_usec_damageHandle;
//[player] call fnc_usec_damageHandle;

//random morphine chance
//Epi pen not working chance
//Water Unconscious handling
//	localize "CLIENT: Medical System Initiated";

while {true} do {
	//hintSilent format["Injured: %1\nUnconscious: %2 (%7)\nBlood: %5\nPain: %6\nMust Evac: %8\nHandler: %3\nAction: %4\nLeg Damage: %9\nArm Damage: %10\nInfected: %11",r_player_injured,r_player_unconscious,r_player_handler,r_action,r_player_blood,r_player_inpain,r_player_timeout,r_player_dead, player getVariable ["hit_legs",0], player getVariable ["hit_arms",0],r_player_infected];
	
	//Blood forced.
	if (r_player_blood > 12000) then {
		r_player_blood = 12000;
		player setVariable["USEC_BloodQty",r_player_blood,true];
		player setVariable["medForceUpdate",true];
	};

	if ((r_player_bloodregen < 1) or (r_player_blood == 12000)) then {
		r_player_bloodregen = 0;
		r_player_foodstack = 0;
	};

	if (r_player_blood <= 0) then {
		[player,900] call fnc_usec_damageUnconscious;
		_id = [dayz_sourceBleeding,"bled"] spawn player_death;
	};

	if ((r_player_blood <= 3000) and !r_player_unconscious) then {
		_rnd = random 100;
		if (_rnd > 99) then {
			[player,((random 0.1) + 0.2)] call fnc_usec_damageUnconscious;
		};
	};

	//Handle Unconscious player
	if ((r_player_unconscious) and (!r_player_handler1)) then {
		//localize "CLIENT: Start Unconscious Function";
		[] spawn fnc_usec_unconscious;
	};

	if (r_player_injured) then {
		if (!r_player_handler) then {
			r_player_handler = true;
			[] spawn fnc_usec_playerHandleBlood;
		};
	} else {
		[] spawn fnc_usec_playerHandleBlood;
	};

	//Add player actions
	[] call fnc_usec_damageActions;
	[] call fnc_usec_selfActions;

    //Player aggro system
    [] call player_aggro_check;
    
    //Reduce antibiotics from player
    [player,"biotics",-1] call DZU_fnc_setVariable;
	//Low Blood Effects
	[] spawn {
		if (!r_player_unconscious) then {
			if (((r_player_blood/r_player_bloodTotal) < 0.35)) then {
				r_player_lowblood = true;
				playSound "heartbeat_1";
				addCamShake [2, 0.5, 25];
				if (r_player_lowblood) then {
					0 fadeSound ((r_player_blood/r_player_bloodTotal) + 0.5);
					"dynamicBlur" ppEffectEnable true;"dynamicBlur" ppEffectAdjust [4]; "dynamicBlur" ppEffectCommit 0.2;
				};
				sleep 0.5;
				if (r_player_lowblood) then {
					"dynamicBlur" ppEffectEnable true;"dynamicBlur" ppEffectAdjust [1]; "dynamicBlur" ppEffectCommit 0.5;
				};
				sleep 0.5;
				_lowBlood = player getVariable ["USEC_lowBlood", false];
				if ((r_player_blood < r_player_bloodTotal) and !_lowBlood) then {
					player setVariable["USEC_lowBlood",true,true];
				};
			};
		};
	};
	sleep 1;
};
endLoadingScreen;