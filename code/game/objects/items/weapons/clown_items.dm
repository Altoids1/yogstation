/* Clown Items
 * Contains:
 *		Soap
 *		Bike Horns
 *		Air Horns
 */

/*
 * Soap
 */

/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1
	flags = NOBLUDGEON
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/cleanspeed = 50 //slower than mop

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of high-class luxury."
	icon_state = "soapdeluxe"
	cleanspeed = 40 //same speed as mop because deluxe -- captain gets one of these

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes

/obj/item/weapon/soap/suicide_act(mob/user)
	user.say(";FFFFFFFFFFFFFFFFUUUUUUUDGE!!")
	user.visible_message("<span class='suicide'>[user] lifts the [src.name] to their mouth and gnaws on it furiously, producing a thick froth! They'll never get that BB gun now!")
	PoolOrNew(/obj/effect/particle_effect/foam, loc)
	return (TOXLOSS)

/obj/item/weapon/soap/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(4, 2, src)

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !check_allowed_items(target))
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='warning'>You need to take that [target.name] off before cleaning it!</span>")
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("[user] begins to scrub \the [target.name] out with [src].", "<span class='warning'>You begin to scrub \the [target.name] out with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
			qdel(target)
	else if(ishuman(target) && user.zone_selected == "mouth")
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with [src.name]!</span>", "<span class='notice'>You wash \the [target]'s mouth out with [src.name]!</span>") //washes mouth out with soap sounds better than 'the soap' here
		return
	else if(istype(target, /obj/structure/window))
		user.visible_message("[user] begins to clean \the [target.name] with [src]...", "<span class='notice'>You begin to clean \the [target.name] with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			target.color = initial(target.color)
			target.SetOpacity(initial(target.opacity))
	else
		user.visible_message("[user] begins to clean \the [target.name] with [src]...", "<span class='notice'>You begin to clean \the [target.name] with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.wash_cream()
	return


/*
 * Bike Horns
 */


/obj/item/device/assembly/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = 1
	throw_speed = 3
	throw_range = 7
	attack_verb = list("HONKED")
	var/spam_flag = 0
	var/honksound = 'sound/items/bikehorn.ogg'
	var/cooldowntime = 20

/obj/item/device/assembly/bikehorn/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] solemnly points the horn at \his temple! It looks like \he's trying to commit suicide..</span>")
	playsound(get_turf(src), honksound, 50, 1)
	return (BRUTELOSS)

/obj/item/device/assembly/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!spam_flag)
		playsound(get_turf(src), honksound, 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/device/assembly/bikehorn/attack_self(mob/user)
	if(!spam_flag)
		spam_flag = 1
		playsound(get_turf(src), honksound, 50, 1)
		src.add_fingerprint(user)
		spawn(cooldowntime)
			spam_flag = 0
	return

/obj/item/device/assembly/bikehorn/Crossed(mob/living/L)
	if(isliving(L))
		playsound(loc, honksound, 50, 1, -1)
	..()

/obj/item/device/assembly/bikehorn/activate()
	if(!..())
		return 0
	attack_self()
	return 1

/obj/item/device/assembly/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	honksound = 'sound/items/AirHorn2.ogg'
	cooldowntime = 50
	origin_tech = "materials=4;engineering=4"

/obj/item/device/assembly/bikehorn/golden
	name = "golden bike horn"
	desc = "Golden? Clearly, its made with bananium! Honk!"
	icon_state = "gold_horn"
	item_state = "gold_horn"
	cooldowntime = 10

/obj/item/device/assembly/bikehorn/golden/attack()
	flip_mobs()
	return ..()

/obj/item/device/assembly/bikehorn/golden/attack_self(mob/user)
	flip_mobs()
	..()

/obj/item/device/assembly/bikehorn/golden/proc/flip_mobs(mob/living/carbon/M, mob/user)
	if (!spam_flag)
		var/turf/T = get_turf(src)
		for(M in ohearers(7, T))
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if((istype(H.ears, /obj/item/clothing/ears/earmuffs)) || H.ear_deaf)
					continue
			M.emote("flip")

/obj/item/device/assembly/bikehorn/rubber_pigeon
	name = "rubber pigeon"
	desc = "Rubber chickens are so 2316."
	icon = 'icons/obj/items.dmi'
	icon_state = "rubber_pigeon"
	item_state = "rubber_pigeon"
	w_class = 1
	throw_speed = 3
	throw_range = 7
	attack_verb = list("Pigeoned")
	honksound = 'sound/items/rubber_pigeon.ogg'
	cooldowntime = 10
