/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/cultify()
	return

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	var/isbroken = 0
	light_range = 5
	light_color = "#3e0000"
	var/obj/item/wepon = null

/obj/structure/cult/pylon/attack_hand(mob/M as mob)
	attackpylon(M, 5)

/obj/structure/cult/pylon/attack_generic(var/mob/user, var/damage)
	attackpylon(user, damage)

/obj/structure/cult/pylon/attackby(obj/item/W as obj, mob/user as mob)
	attackpylon(user, W.force)

/obj/structure/cult/pylon/proc/attackpylon(mob/user as mob, var/damage)
	if(!isbroken)
		if(prob(1+ damage * 5))
			user.visible_message(
				SPAN_DANG("[user] smashed the pylon!"),
				SPAN_WARN("You hit the pylon, and its crystal breaks apart!"),
				"You hear a tinkle of crystal shards"
			)
			user.do_attack_animation(src)
			playsound(get_turf(src), 'sound/effects/Glassbr3.ogg', 75, 1)
			isbroken = 1
			density = 0
			icon_state = "pylon-broken"
			set_light(0)
		else
			user << "You hit the pylon!"
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	else
		if(prob(damage * 2))
			user << "You pulverize what was left of the pylon!"
			qdel(src)
		else
			user << "You hit the pylon!"
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)


/obj/structure/cult/pylon/proc/repair(mob/user as mob)
	if(isbroken)
		user << "You repair the pylon."
		isbroken = 0
		density = 1
		icon_state = "pylon"
		set_light(5)

/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult/pillar
	name = "Pillar"
	desc = "This should not exist"
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/spawnable = null

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/active
	light_range=5
	light_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat,
		/mob/living/simple_animal/hostile/creature,
		/mob/living/simple_animal/hostile/faithless
	)

/obj/effect/gateway/active/cult
	light_range=5
	light_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult
	)

/obj/effect/gateway/active/cult/cultify()
	return

/obj/effect/gateway/active/New()
	spawn(rand(30,60) SECONDS)
		var/t = pick(spawnable)
		new t(src.loc)
		qdel(src)

/obj/effect/gateway/active/Crossed(var/atom/A)
	if(!isliving(A))
		return

	var/mob/living/M = A

	if(M.stat != DEAD)
		if(M.transforming)
			return
		if(M.has_brain_worms())
			return //Borer stuff - RR

		if(iscultist(M)) return
		if(!ishuman(M) && !isrobot(M)) return

		M.transforming = 1
		M.canmove = 0
		M.icon = null
		M.overlays.len = 0
		M.invisibility = 101

		if(isrobot(M))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				qdel(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))
					qdel(W)
					continue
				W.layer = initial(W.layer)
				W.loc = M.loc
				W.dropped(M)

		var/mob/living/new_mob = new /mob/living/simple_animal/corgi(A.loc)
		new_mob.a_intent = I_HURT
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		new_mob << "<B>Your form morphs into that of a corgi.</B>"	//Because we don't have cluwnes
