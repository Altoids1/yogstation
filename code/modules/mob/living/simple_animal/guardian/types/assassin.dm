//Assassin
/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	dismember_chance = 0
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8
	playstyle_string = "<span class='holoparasite'>As an <b>assassin</b> type you do medium damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Space Ninja, a lethal, invisible assassin.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Assassin modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's an assassin carp! Just when you thought it was safe to go back to the water... which is unhelpful, because we're in space.</span>"

	toggle_button_type = /obj/screen/guardian/ToggleMode/Assassin
	var/toggle = FALSE
	var/stealthcooldown = 160
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Initialize()
	..()
	stealthcooldown = 0

/mob/living/simple_animal/hostile/guardian/assassin/Life()
	. = ..()
	updatestealthalert()
	if(loc == summoner && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/Stat()
	..()
	if(statpanel("Status"))
		if(stealthcooldown >= world.time)
			stat(null, "Stealth Cooldown Remaining: [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.adjustStaminaLoss(20)//so the assassin can actually secure kills on people it sneak attacks
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Recall()
	if(..() && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armour_penetration = initial(armour_penetration)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		pass_flags &= ~PASSMOB
		pass_flags &= ~PASSTABLE
		dismember_chance = initial(dismember_chance)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, "<span class='danger'><B>You exit stealth.</span></B>")
		else
			visible_message("<span class='danger'>\The [src] suddenly appears!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forced out of stealth and go on cooldown
			cooldown = world.time + 60 //can't recall for 6 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(src.loc == summoner)
			to_chat(src, "<span class='danger'><B>You have to be manifested to enter stealth!</span></B>")
			return
		melee_damage_lower = 50
		melee_damage_upper = 50
		armour_penetration = 100
		dismember_chance = 100
		obj_damage = 0
		environment_smash = 0
		new /obj/effect/overlay/temp/guardian/phase/out(get_turf(src))
		alpha = 15
		pass_flags |= (PASSTABLE | PASSMOB)
		if(!forced)
			to_chat(src, "<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /obj/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /obj/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null
