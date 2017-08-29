/obj/item/organ/internal/chompers
	name = "chompers"
	icon = 'icons/mob/dogborg_vr.dmi'
	icon_state = "jaws"
	gender = PLURAL
	parent_organ = BP_HEAD
	force = 25
	sharp = 1
	edge = 1
	attack_verb = list("chomped", "bit", "ripped", "chewed")
	hitsound = 'sound/weapons/bite.ogg'
	embed_chance = 0

/obj/item/organ/internal/chompers/removed(var/mob/living/user)
	qdel(src)
	return

/mob/living/carbon/human/hit_with_weapon(obj/item/organ/internal/chompers/C, mob/living/user, var/effective_force, var/hit_zone)
	if(istype(C,/obj/item/organ/internal/chompers))
		var/obj/item/organ/O = user.zone_sel.selecting
		user.visible_message("<span class='warning'>[user] sinks their teeth into [src]'s [O] and begins ripping!</span>", "<span class='notice'>You sink your teeth into [src]'s [O] and begin ripping!</span>")

		var/soaked = get_armor_soak(hit_zone, "melee")
		var/blocked = run_armor_check(hit_zone, "melee")

		standard_weapon_hit_effects(C, user, effective_force, blocked, soaked, hit_zone)

		if(C.damtype == BRUTE && prob(33)) // Added blood for whacking non-humans too
			var/turf/simulated/location = get_turf(src)
			if(istype(location)) location.add_blood_floor(src)

	..()

/obj/item/organ/internal/chompers/afterattack(var/obj/item/organ/O, mob/living/user)
	user = loc
	if(istype(O,/obj/item/organ))
		if(istype(O.loc,/turf))//Yummy ground organs. Screw the 5 second rule!
			var/datum/belly/belly = user.vore_selected
			if(do_after(user, 30, O))
				user.visible_message("<span class='warning'>[user] violently devours the severed [O.name]!</span>", "<span class='notice'>You violently devour the severed [O.name]!</span>")
				playsound(user, belly.vore_sound, 80, 1)
				src.loc = user
				belly.internal_contents += src
				return

/obj/item/organ/internal/chompers/verb/bite(var/obj/item/weapon/grab/G in usr.get_active_hand())
	set name = "Chomp grabbed victim"
	set category = "IC"
	set src in usr
	if(istype(usr.get_active_hand(),/obj/item/weapon/grab))
		G = usr.get_active_hand()
		var/mob/living/carbon/human/victim = G.affecting
		if(victim.digestable < 1) //This fella ain't here for vorey deaths.
			return
		if(G.state >= GRAB_AGGRESSIVE && ishuman(victim))
			if(do_after(usr, 40, victim))
				src.attack(victim, usr, usr.zone_sel.selecting)

/obj/item/organ/internal/chompers/verb/bite_severed(var/obj/item/organ/O in usr.get_active_hand())
	set name = "Devour held organ"
	set category = "IC"
	set src in usr
	if(istype(O,/obj/item/organ))
		var/obj/item/organ/OG = O
		if(isturf(OG.loc))
			src.attack(OG,usr)

/datum/trait/gnarly_chompers
	name = "Gnarly Chompers"
	desc = "Gives you a dedicated hard vore ability."
	cost = 1
	apply(var/datum/species/S,var/mob/living/carbon/human/H)
		..(S,H)
		H.internal_organs += new /obj/item/organ/internal/chompers(H)