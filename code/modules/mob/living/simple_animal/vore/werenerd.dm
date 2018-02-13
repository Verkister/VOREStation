/mob/living/simple_animal/werenerd //CADILLAC BUS CADILLAC BUS
	name = "Cameron Eggbert?"
	desc = "Holy shit that is not the usual little nerdpup."
	icon = 'icons/mob/werenerd.dmi'
	icon_state = "werenerd"
	icon_living = "werenerd"
	icon_dead = "werenerd-ko"
	icon_rest = "werenerd-rest"
	var/icon_default = "werenerd" //Backup fuckery.
	var/icon_stance = "werenerd-stance" //Preparing to pounce or pinning down victim.
	var/icon_leap = "werenerd-leap" //Glorious aerobatics.
	faction = "werenerd"
	maxHealth = 666
	health = 666
	minbodytemp = 200
	move_to_delay = 4
	investigates = TRUE
	retaliate = 1
	speak_chance = 10
	speak = list("Food...","Uh hi.","Huff.","Got any snacks for me?","Has science gone too far?","So beastly...","Weh.", "Awooo~")
	speak_emote = list("growls", "roars", "yaps", "Awoos")
	emote_hear = list("rumbles", "groans softly", "murrs", "yawns", "howls softly")
	emote_see = list("stares ferociously", "snarls", "licks her chops", "stretches", "yawns", "scritches her butt", "flexes", "curiously feels over her unusual form", "adjusts her hair flower")
	say_maybe_target = list("Oi!", "WHAT?", "FEED ME!", "DIBS!")
	say_got_target = list("Now ya done goofed!", "BEASTMODE GO!", "FOOD!", "CHOMP CHOMP FUCKO!", "RAHH!", "HERE COMES PAIN TRAIN!", "GET IN MY BELLEH!", "HUG TIME YO!", "LET'S DANCE!")
	melee_damage_lower = 10
	melee_damage_upper = 20
	response_help = "pets the"
	response_disarm = "bops the"
	response_harm = "hits the"
	attacktext = "ravaged"
	friendly = list("nuzzles", "slobberlicks", "noses softly at", "noseboops", "headbumps against", "leans on", "nibbles affectionately on")
	grab_resist = 100
	old_x = -16
	old_y = 0
	pixel_x = -16
	pixel_y = 0

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	vore_active = TRUE
	vore_capacity = 3
	vore_pounce_chance = 40

/mob/living/simple_animal/werenerd/PunchTarget()
	if(istype(target_mob,/mob/living/simple_animal/mouse))
		return EatTarget()
	else ..()

/mob/living/simple_animal/werenerd/death(gibbed, deathmessage = "shudders and collapses!")
	.=..()
	resting = 0
	icon_state = icon_dead

/mob/living/simple_animal/werenerd/New()
	..()
	verbs |= /mob/living/simple_animal/werenerd/proc/leap

/mob/living/simple_animal/werenerd/proc/leap()
	set name = "Leap"
	set category = "IC"
	set desc = "Give them a good ol' werenerd pounce!"

	if(stat != CONSCIOUS)
		return

	if(resting)
		to_chat(src, "You cannot leap in your current state.")
		return

	icon_living = icon_stance
	update_icon()

	var/list/choices = list()
	for(var/mob/living/M in view(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") as null|anything in choices

	if(!T)
		icon_living = icon_default
		update_icon()
		return

	if(get_dist(get_turf(T), get_turf(src)) > 6) return

	if(resting)
		to_chat(src, "You cannot leap in your current state.")
		icon_living = icon_default
		update_icon()
		return
	if(stat == DEAD)
		to_chat(src, "You cannot leap in your current state.")
		icon_living = icon_default
		update_icon()
		return

	face_atom(T)
	icon_living = icon_leap
	pixel_x = -32
	update_icon()

	visible_message("<span class='danger'>\The [src] leaps at [T]!</span>")
	throw_at(get_step(get_turf(T),get_turf(src)), 6, 1, src)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 50, 1)
	pixel_x = old_x
	icon_living = icon_stance
	update_icon()

	sleep(5)
	icon_living = icon_default

	if(!src.Adjacent(T))
		to_chat(src, "<span class='warning'>You miss!</span>")
		return

	if(ishuman(T))
		var/mob/living/carbon/human/H = T
		if(H.species.lightweight == 1)
			H.Weaken(10)
			return
	var/armor_block = run_armor_check(T, "melee")
	var/armor_soak = get_armor_soak(T, "melee")
	T.apply_damage(20, HALLOSS,, armor_block, armor_soak)
	if(prob(66))
		T.apply_effect(10, WEAKEN, armor_block)
