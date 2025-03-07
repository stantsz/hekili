-- WarriorProtection.lua
-- October 2023

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID, RangeType = ns.FindPlayerAuraByID, ns.RangeType

local strformat = string.format

local spec = Hekili:NewSpecialization( 73 )

local base_rage_gen = 2

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return (  swing + floor( ( t - swing ) / state.swings.mainhand_speed )  * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function ()
            if state.talent.devastator.enabled then -- 1 Rage for instigate with devastator, 2 rage for instigate with devastate
                return ( base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 ) ) + ( state.talent.instigate.enabled and 1 or 0 ) -- 1 Rage for instigate
            else
                return ( base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 ) ) + ( state.talent.instigate.enabled and 2 or 0 ) -- 2 Rage for instigate
            end
        end
    },

    conquerors_banner = {
        aura = "conquerors_banner",

        last = function ()
            local app = state.buff.conquerors_banner.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,

        value = 4,
    },
} )

spec:RegisterTalents( {
    -- Warrior Talents
    armored_to_the_teeth            = { 90259, 394855, 2 }, -- Gain Strength equal to $s2% of your Armor.
    avatar                          = { 92639, 401150, 1 }, -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    barbaric_training               = { 90377, 390675, 1 }, -- Revenge deals $s1% increased damage but now costs ${$s2/10} more rage.
    berserker_rage                  = { 90372, 18499 , 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.; Also remove fear effects from group members within $384102A1 yds.
    berserkers_torment              = { 90362, 390123, 1 }, -- Activating Avatar or Recklessness casts the other at reduced effectiveness.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores $s1% health instantly and removes all diseases, poisons and curses affecting you.;
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar or Bladestorm casts the other at reduced effectiveness.
    blood_and_thunder               = { 90342, 384277, 1 }, -- Thunder Clap $?!a137048[costs ${$s2/10} more Rage and ][]deals $s1% increased damage.$?!a137050[ If you have Rend, Thunder Clap affects $s3 nearby targets with Rend.][]
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by ${$m1/-1000} sec, and Heroic Leap now also increases your movement speed by $202164s1% for $202164d.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand $s1% more damage before breaking.
    champions_might                 = { 90323, 386285, 1 }, -- [386284] The duration of Champion's Spear is increased by ${$s1/1000} sec. While you remain within the area of your Champion's Spear your critical strike damage is increased by $386286s1%.
    champions_spear                 = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing $376080s1 Physical damage instantly and an additional $376080o4 damage over $376081d. Deals reduced damage beyond $<cap> targets.; Enemies hit are chained to the spear's location for the duration.; Generates $/10;376080s3 Rage.
    concussive_blows                = { 90334, 383115, 1 }, -- Cooldown of Pummel reduced by ${$s1/-1000}.1 sec. ; Successfully interrupting an enemy increases the damage you deal to them by $383116s2% for $383116d.
    crackling_thunder               = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by $s1%, and it reduces movement speed by an additional $s2%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%.
    crushing_force                  = { 90347, 382764, 2 }, -- Slam deals an additional $s1% damage and has a ${$s3/10}.2% increased critical strike chance.
    defensive_stance                = { 90330, 386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1%, and all damage you deal by $s2%. ; Lasts until canceled.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by ${$s2/-1000} sec.
    dual_wield_specialization       = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by $s1%.
    endurance_training              = { 90339, 382940, 1 }, -- Stamina increased by $s1% and the duration of Fear, Sap and Incapacitate effects on you is reduced by ${$s6/10}.1%.
    fast_footwork                   = { 90371, 382260, 1 }, -- Movement speed increased by $s1%.
    frothing_berserker              = { 90370, 392790, 1 }, -- Revenge has a $h% chance to immediately refund $s1% of the Rage spent.
    furious_blows                   = { 90336, 390354, 1 }, -- Auto-attack speed increased by $s1%.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $52174s1 Physical damage to all enemies within $52174a1 yards$?c3[, and resetting the remaining cooldown on Taunt][].
    honed_reflexes                  = { 90361, 391271, 1 }, -- Cooldown of Shield Slam and Pummel reduced by ${$s2/-1000}.1 sec.
    immovable_object                = { 90364, 394307, 1 }, -- Activating Avatar or Shield Wall casts the other at reduced effectiveness.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing $s1 damage and healing you for $202166s1% of your maximum health.; Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for $147833d while they remain within $147833A1 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- $?s275338[Causes the targeted enemy and up to $s1 additional enemies within $5246A3 yards to cower in fear.][Causes the targeted enemy to cower in fear, and up to $s1 additional enemies within $5246A3 yards to flee.] Targets are disoriented for $d.
    leeching_strikes                = { 90344, 382258, 1 }, -- Leech increased by $s1%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for $316595d instead of fleeing.
    onehanded_weapon_specialization = { 90324, 382895, 1 }, -- Damage with one-handed weapons and Leech increased by $s1%.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by ${$s1/10}.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for ${$m1/10}.2% of your maximum health. ; This can only occur once every $357946d.
    piercing_challenge              = { 90379, 382948, 1 }, -- Instant damage of Champion's Spear increased by $s1% and its Rage generation is increased by $s2%.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within $A1 yards, reducing their movement speed by $s1% for $d.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within $a1 yards $s1% temporary and maximum health for $97463d.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by $s1%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by $s3 yards and when Shockwave strikes at least $s1 targets, its cooldown is reduced by $s2 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores $202147s1% health every $202147t1 sec when you have not taken damage for $202149d.
    seismic_reverberation           = { 90340, 382956, 1 }, -- If Whirlwind $?a137048[or Revenge hits $s1 or more enemies, it hits them $s2 additional time for $s5% damage.][hits $s1 or more enemies, it hits them $s2 additional time for $s5% damage.]
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor, and removing any magical immunities. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing $s2 damage and stunning all enemies within $a1 yards for $132168d.; Generates ${$m5/10} Rage.
    sidearm                         = { 90334, 384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional $384391s1 Physical damage.
    sonic_boom                      = { 90321, 390725, 1 }, -- Shockwave deals $s1% increased damage and will always critical strike.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your $?c3[shield][weapon], reflecting $?a213915[the next $213915s3 spells cast][the first spell cast] on you, and reduce magic damage you take by $385391s1% for $d.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing $s1 Physical damage and stunning for $132169d.
    thunder_clap                    = { 90343, 6343  , 1 }, -- Blasts all enemies within $6343A1 yards for $s1 Physical damage$?(s199045)[, rooting them for $199042d]?s199045[ and roots them for $199042d.][.] and reduces their movement speed by $s2% for $d. Deals reduced damage beyond $s5 targets.$?s386229[; Generates ${$s4/10} Rage.][]
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing $s1 Physical damage to enemies within $A1 yds and cause them to bleed for $397364o1 physical damage over $397364d.; Generates ${$m3/10} Rage.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by ${$s2/1000}.1 sec and increases the damage of your bleed effects by $s1% at all times.
    titanic_throw                   = { 90341, 384090, 1 }, -- Throws your weapon at the enemy, causing $s1 Physical damage to it and $s2 nearby enemies. ; Generates high threat.
    titans_torment                  = { 90362, 390135, 1 }, -- Activating Avatar casts Odyn's Fury, activating Odyn's Fury casts Avatar at reduced effectiveness.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by $s1%.;
    unstoppable_force               = { 90364, 275336, 1 }, -- Avatar increases the damage of Thunder Clap and Shockwave by $s1%, and reduces the cooldown of Thunder Clap by $s2%.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by ${$s1/-1000} sec.
    war_machine                     = { 90345, 316733, 1 }, -- Your auto attacks generate $s2% more Rage.; Killing an enemy instantly generates ${$262232s1/10} Rage, and increases your movement speed by $262232s2% for $262232d.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar or Colossus Smash casts Recklessness at reduced effectiveness.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $392778d.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.

    -- Protection Talents
    anger_management                = { 90311, 152278, 1 }, -- Every $?c1[$s1]?c2[$s3][$s2] Rage you spend$?c1[ on attacks][] reduces the remaining cooldown on $?c1&s262161[Warbreaker and Bladestorm]?c1[Colossus Smash and Bladestorm]?c2[Recklessness and Ravager][Avatar and Shield Wall] by 1 sec.
    battering_ram                   = { 90262, 394312, 1 }, -- Shield Charge critical strike chance and critical strike damage increased by $s2%, and Shield Charge increases your auto-attack damage and speed by $394313s1% for $394313d.
    battle_stance                   = { 90261, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. ; Lasts until canceled.
    battlescarred_veteran           = { 90435, 386394, 1 }, -- When your health is brought below $s3%, you take $386397s1% less damage for $386397d and healing you receive is increased by $386397s2%.; Cannot occur more than once every $proccooldown sec.
    best_served_cold                = { 90304, 202560, 1 }, -- Revenge deals $s1% more damage, or ${$s1+$5302s2}% more damage when your successful dodges or parries have made it cost no Rage.
    bloodborne                      = { 90448, 385704, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal $s1% increased damage.;
    bloodsurge                      = { 90300, 384361, 1 }, -- Your Bleed effects have a chance to grant you ${$384362s1/10} Rage.
    bolster                         = { 90264, 280001, 1 }, -- Last Stand's cooldown is reduced by ${$s1/-1000} sec, and it grants you the Shield Block effect for its duration.
    booming_voice                   = { 90314, 202743, 1 }, -- Demoralizing Shout also generates ${$m1/10} Rage, and increases damage you deal to affected targets by $s2%.
    brace_for_impact                = { 90296, 386030, 1 }, -- Using Shield Slam increases the damage of Shield Slam by $386029s1% for $386029d, and it increases the block value of your shield by $386029s2%. Stacking up to $s2 times.
    brutal_vitality                 = { 90451, 384036, 1 }, -- $s1% of damage you deal adds to your active Ignore Pain.
    challenging_shout               = { 90309, 1161  , 1 }, -- Taunts all enemies within $A1 yds to attack you for $d.
    champions_bulwark               = { 90316, 386328, 1 }, -- Shield Charge deals $s3% increased damage, grants you Shield Block, makes your next Revenge cost no Rage, and generates an additional ${$s2/10} Rage.
    dance_of_death                  = { 90260, 393965, 1 }, -- If your Ravager helps kill an enemy, it lasts ${$393966s1/1000}.1 sec longer and deals $393966s2% increased damage.; This effect also applies to future Ravagers for the next $393966d.;
    defenders_aegis                 = { 90310, 397103, 1 }, -- Shield Wall gains $s2 additional charge, and its cooldown is reduced by ${$s1/-1000} sec.
    demoralizing_shout              = { 90305, 1160  , 1 }, -- $?s199023[Demoralizes all enemies within $A2 yards, reducing the damage they do by $s2% for $d.][Demoralizes all enemies within $A2 yards, reducing the damage they deal to you by $s1% for $d.]$?s202743[; Generates ${$m5/10} Rage.][]
    devastator                      = { 90299, 236279, 1 }, -- Your auto attacks deal an additional $236282s1 Physical damage and have a $s2% chance to reset the remaining cooldown on Shield Slam.
    disrupting_shout                = { 90307, 386071, 1 }, -- Taunts all enemies within $A1 yds to attack you for $d, interrupts all spellcasting within $A1 yds and prevents any spell in that school from being cast for $d.;
    enduring_alacrity               = { 90433, 384063, 1 }, -- Increases Stamina and Armor by $s1% and your Haste by $s2%.
    enduring_defenses               = { 90313, 386027, 1 }, -- Shield Block lasts ${$s1/1000} sec longer.
    focused_vigor                   = { 90318, 384067, 1 }, -- Increases Strength and Armor by $s1% and your critical strike chance by $s2%.;
    fueled_by_violence              = { 90451, 383103, 1 }, -- You are healed for $s1% of the damage dealt by Deep Wounds.
    heavy_repercussions             = { 90319, 203177, 1 }, -- Shield Slam generates ${$s2/10} more Rage and extends the duration of Shield Block by ${$m1/100}.1 sec.
    ignore_pain                     = { 90295, 190456, 1 }, -- Fight through the pain, ignoring $s2% of damage taken, up to ${$mhp*$s4/100} total damage prevented.
    impenetrable_wall               = { 90310, 384072, 1 }, -- Shield Slam generates an additional ${$s2/10} Rage and reduces the remaining cooldown of Shield Wall by $s1 sec.
    improved_heroic_throw           = { 90306, 386034, 1 }, -- Heroic Throw deals $s2% increased damage and inflicts Deep Wounds.
    indomitable                     = { 90434, 202095, 1 }, -- Your maximum health is increased by $s3%, and every ${$s2/10} Rage you spend heals you for ${$s1/10}% of your maximum health.
    instigate                       = { 90301, 394311, 1 }, -- Devastate deals $s1% increased damage and generates ${$s2/10} Rage.; Devastator deals $s3% increased damage and generates ${$s4/10} Rage.
    into_the_fray                   = { 90319, 202603, 1 }, -- You gain $202602s1% Haste for each enemy or ally within $s1 yards, up to ${$202602s1*$202602u}% Haste.
    juggernaut                      = { 90449, 393967, 1 }, -- Execute increases Execute's damage dealt by $393968s1% for $393968d, stacking up to $393968u times.
    last_stand                      = { 90297, 12975 , 1 }, -- Increases maximum health by $s1% for $d, and instantly heals you for that amount.
    massacre                        = { 90313, 281001, 1 }, -- $?a317320[Condemn][Execute] is now usable on targets below $s2% health.;
    punish                          = { 90449, 275334, 1 }, -- Shield Slam deals $s1% increased damage, and reduces enemies' damage against you by $275335s1% for $275335d. Multiple punishments may overlap.
    ravager                         = { 90432, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $<damage> Physical damage to all enemies over $d. Deals reduced damage beyond $156287s2 targets.; Generates ${$334934s1/10} Rage each time it deals damage.
    rend                            = { 90302, 394062, 1 }, -- Wounds the target, causing $s1 Physical damage instantly and an additional $394063o1 Bleed damage over $394063d.
    revenge                         = { 90298, 6572  , 1 }, -- Swing in a wide arc, dealing $s1 Physical damage to all enemies in front of you. Deals reduced damage beyond $<cap> targets.; Your successful dodges and parries have a chance to make your next Revenge cost no Rage.
    shield_charge                   = { 90317, 385952, 1 }, -- Charge to an enemy with your shield, dealing $385954s1 Physical damage to it and $385954s2 Physical damage to all enemies within 10 yards.; Also stuns the primary target for $385954d.; Generates ${$385954s4/10} Rage.
    shield_specialization           = { 90315, 386011, 2 }, -- Increases Block chance by $s1% and your Block value by $s2%.
    shield_wall                     = { 90312, 871   , 1 }, -- Reduces all damage you take by $s1% for $d.
    show_of_force                   = { 90320, 385843, 1 }, -- Revenge damage increased by $s2% and Revenge increases the damage of your next Thunder Clap by $s1%.
    spell_block                     = { 90450, 392966, 1 }, -- You are able to block spells for $392966d.
    storm_of_steel                  = { 90431, 382953, 1 }, -- Ravager's damage is reduced by $s1% but it now has $s4 charges and generates $s6 Rage each time it deals damage.
    strategist                      = { 90303, 384041, 1 }, -- Devastate, Thunder Clap, Revenge, and Execute have a $s1% chance to reset the remaining cooldown on Shield Slam.
    sudden_death                    = { 90320, 29725 , 1 }, -- Your attacks have a chance to make your next $?a317320[Condemn][Execute] cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent $s1 Rage.
    thunderlord                     = { 90308, 385840, 1 }, -- Increases the radius of Demoralizing Shout by $s3 yards.; Each enemy hit by Thunder Clap reduces the remaining cooldown on Demoralizing Shout by ${$s1/1000}.1 sec, up to ${$s1*$s2/1000}.1 sec.
    tough_as_nails                  = { 90450, 385888, 1 }, -- Blocking an attack deals $385890s1 Physical damage to the attacker, ignoring armor. ; Generates high threat.
    unnerving_focus                 = { 90452, 384042, 1 }, -- Last Stand increases your Rage generation by $s1%.
    violent_outburst                = { 90265, 386477, 1 }, -- Consuming $s1 rage grants a stack of Seeing Red, which transforms at $386486u stacks into Violent Outburst, causing your next Shield Slam or Thunder Clap to deal $386478s1% increased damage, generate $386478s3% more Rage and grant Ignore Pain.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander = 5629, -- (424742) Your Shout abilities have additional effects.; $@spellicon6673 $@spellname6673:; Increases Stamina by $s1%.; $@spellicon12323 $@spellname12323:; Roots targets hit for $424752d.; $@spellicon384100 $@spellname384100:; Range increased by $s2 yds.; $@spellicon5246 $@spellname5246:; Cooldown reduced by ${$s3/-1000} sec.; $@spellicon97462 $@spellname97462:; Removes movement impairing effects and grants $s4% movement speed to allies.; $@spellicon384318 $@spellname384318:; Targets receive $s5% more damage from all sources while bleeding.
    bodyguard             = 168 , -- (213871) Protect an ally, causing $m1% of all Physical damage they take to be transfered to you. When the target takes Physical damage, your Shield Slam cooldown has a $231834s1% chance to be reset. Bodyguard is cancelled if the target is further than $m2 yards from you. Lasts $d.; Only one target can be Bodyguarded at a time.
    demolition            = 5374, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by $s1% and increases its damage to absorb shields by an additional ${$s3*5}%.
    disarm                = 24  , -- (236077) Disarm the enemy's weapons and shield for $d. Disarmed creatures deal significantly reduced damage.
    dragon_charge         = 831 , -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take $206579s1 Physical damage and be knocked back.
    morale_killer         = 171 , -- (199023) Reduces the cooldown of Demoralizing Shout by ${($m2/1000)*-1} sec, and Demoralizing Shout now reduces the damage enemies deal to all targets, not just you.
    oppressor             = 845 , -- (205800) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    rebound               = 833 , -- (213915) Spell Reflection reflects the next $s3 incoming spells cast on you and reflected spells deal $s1% extra damage to the attacker.; Spell Reflection's cooldown is increased by ${$s2/1000} sec.
    safeguard             = 5626, -- (424654) Intervene now has ${$s1+1} charges and reduces the ally's damage taken by $424655s1% for $424655d.; Intervene's cooldown is increased by ${$s2/1000} sec.
    shield_bash           = 173 , -- (198912) When Shield Slam is used on targets that are casting, it reduces their damage done by $23922s4% for $23922d and the cooldown is instantly reset.
    storm_of_destruction  = 5627, -- (236308) Reduces the cooldown of $?c2[Ravager][Bladestorm] by $m1%, and $?c2[Ravager][Bladestorm] now also snares all targets you hit by $424597s1% for $424597d.
    thunderstruck         = 175 , -- (199045) Thunder Clap roots all targets it damages for $199042d.
    warbringer            = 5432, -- (356353) Charge roots enemies for ${1+$s1/1000} sec and emanates a shockwave past the target, rooting enemies and dealing $356356s2 Physical damage in a $356356a1 yd cone.
    warpath               = 178 , -- (199086) When landing with Heroic Leap, all targets are stunned for $199085d.
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 401150,
        duration = 20,
        max_stack = 1,
        copy = 107574
    },
    battering_ram = {
        id = 394313,
        duration = 20,
        max_stack = 1,
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlescarred_veteran = {
        id = 386397,
        duration = 8,
        max_stack = 1
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        max_stack = 1
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        max_stack = 1
    },
    bodyguard = {
        id = 213871,
        duration = 60,
        tick_time = 1,
        max_stack = 1
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1,
    },
    brace_for_impact = {
        id = 386029,
        duration = 16,
        max_stack = 5
    },
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1,
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    dance_of_death = {
        id = 393966,
        duration = 120,
        max_stack = 1,
    },
    deep_wounds = {
        id = 115767,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    demoralizing_shout = {
        id = 1160,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    disrupting_shout = {
        id = 386071,
        duration = 6,
        max_stack = 1
    },
    dragon_charge = {
        id = 206572,
        duration = 1.2,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8,
        max_stack = 1
    },
    -- Target Swapping
    execute_ineligible = {
        duration = 3600,
        max_stack = 1,
        generate = function( t )
            if buff.sudden_death.down and target.health_pct > ( talent.massacre.enabled and 35 or 20 ) then
                t.count = 1
                t.expires = query_time + 3600
                t.applied = query_time
                t.duration = 3600
                t.caster = "player"
                return
            end
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
    },
    indelible_victory = {
        id = 336642,
        duration = 8,
        max_stack = 1
    },
    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        duration = function () return talent.menace.enabled and 15 or 8 end,
        max_stack = 1
    },
    into_the_fray = {
        id = 202602,
        duration = 3600,
        max_stack = 5
    },
    juggernaut = {
        id = 393968,
        duration = 12,
        max_stack = 15,
        copy = 383290
    },
    last_stand = {
        id = 12975,
        duration = 15,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    punish = {
        id = 275335,
        duration = 9,
        max_stack = 5
    },
    rallying_cry = {
        id = 97463,
        duration = 10,
        max_stack = 1,
        shared = "player",
    },
    ravager = {
        id = 228920,
        duration = function () return ( buff.dance_of_death.up and 14 or 12 ) * haste end,
        tick_time = 2,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    revenge = {
        id = 5302,
        duration = 6,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    safeguard = {
        id = 424655,
        duration = 5.0,
        max_stack = 1,
    },
    seeing_red = {
        id = 386486,
        duration = 30,
        max_stack = 8
    },
    shield_bash = {
        id = 198912,
        duration = 8,
        max_stack = 1
    },
    shield_block = {
        id = 132404,
        duration = function () return ( talent.enduring_defenses.enabled and 8 or 6 ) + ( talent.heavy_repercussions.enabled and 1 or 0 )  end,
        max_stack = 1
    },
    shield_charge = {
        id = 385954,
        duration = 4,
        max_stack = 1,
    },
    shield_wall = {
        id = 871,
        duration = 8,
        max_stack = 1
    },
    shockwave = {
        id = 132168,
        duration = 2,
        max_stack = 1
    },
    show_of_force = {
        id = 385842,
        duration = 12,
        max_stack = 1
    },
    spell_block = {
        id = 392966,
        duration = 20,
        max_stack = 1
    },
    spell_reflection = {
        id = 23920,
        duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
        max_stack = 1
    },
    spell_reflection_defense = {
        id = 385391,
        duration = 5,
        max_stack = 1
    },
    stance = {
        alias = { "battle_stance", "berserker_stance", "defensive_stance" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    storm_bolt = {
        id = 107570,
        duration = 4,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    storm_of_destruction = {
        id = 424597,
        duration = 6.0,
        max_stack = 1,
    },
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 397364,
        duration = function () return talent.thunderous_words.enabled and 10 or 8 end,
        tick_time = 2,
        max_stack = 1
    },
    unnerving_focus = {
        id = 384043,
        duration = 15,
        max_stack = 1
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1
    },
    violent_outburst = { -- Renamed from Outburst to violent Outburst in build 45779
        id = 386478,
        duration = 30,
        max_stack = 1
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
    },
    wild_strikes = {
        id = 392778,
        duration = 10,
        max_stack = 1
    }
} )


-- Dragonflight Season 1
spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427 )
spec:RegisterSetBonuses( "tier29_2pc", 393710, "tier29_4pc", 393711 ) -- Dragonflight Season 1
-- 2-Set - Revenge grants you Vanguard's Determination, increasing your damage done and reducing damage you take by 4% for 5 sec seconds.
-- 4-Set - During Vanguard's Determination, gain Ignore Pain equal to 5% of damage you deal.
spec:RegisterAura( "vanguards_determination", {
    id = 394056,
    duration = 5,
    max_stack = 1,
} )

spec:RegisterGear( "tier30", 202446, 202444, 202443, 202442, 202441 )
spec:RegisterSetBonuses( "tier30_2pc", 405581, "tier30_4pc", 405582 )
--(2) Shield Slam deals 15% increased damage and reduces the cooldown of Last Stand by 1 sec. During Last Stand these effects are doubled.
--(4) For 10 sec after Last Stand ends, Shield Slam unleashes a wave of force dealing (45% of Attack power) Physical damage to enemies in front of you and reducing damage they deal to you by 5% for 5 sec.
spec:RegisterAura( "earthen_tenacity", {
    id = 410218,
    duration = 5,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207180, 207181, 207182, 207183, 207185 )
spec:RegisterSetBonuses( "tier31_2pc", 422927, "tier31_4pc", 422928 )
-- (2) Spending Rage has a chance to cause your next Shield Slam to consume your bleeds on a target, instantly dealing 40% of the remaining damage of your Deep Wounds and Rend and 100% of Thunderous Roar's, and reducing your damage taken by 10% for 5 sec.
-- (4) For each bleed effect consumed from a target, your damage taken is reduced by an additional 2%. When Shield Slam consumes a bleed, the cooldown of Thunder Clap is reset and the cooldown of Thunderous Roar is reduced by 3.0 sec.
spec:RegisterAuras( {
    fervid = {
        id = 425517,
        duration = 10,
        max_stack = 1
    },
    fervid_opposition = {
        id = 427413,
        duration = 5,
        max_stack = 1
    },
} )


local rageSpent = 0
local gloryRage = 0
local outburstRage = 0

spec:RegisterStateExpr( "glory_rage", function () return gloryRage end )
spec:RegisterStateExpr( "rage_spent", function () return rageSpent end )
spec:RegisterStateExpr( "outburst_rage", function () return outburstRage end )

local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )
        if current < lastRage - 3 then -- Spent Rage, -3 is used as a Hack to avoid Rage decaying
            if state.talent.anger_management.enabled or state.talent.indomitable.enabled then
                rageSpent = ( rageSpent + lastRage - current ) % 10 -- Anger Management / Indomitable
            end

            if state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) then
                gloryRage = ( gloryRage + lastRage - current ) % 10 -- Glory.
            end

            if state.talent.violent_outburst.enabled then
                outburstRage = ( outburstRage + lastRage - current ) % 30 -- Outburst T28 or Violent Outburst
            end
        end
        lastRage = current
    end
end )


-- model rage expenditure and special effects
spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" and amt < 0 then
        if talent.indomitable.enabled or talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local activations = floor( rage_spent / 10 )
            rage_spent = rage_spent % 10

            if activations > 0 then
                if talent.anger_management.enabled then
                    if talent.shield_wall.enabled then
                        cooldown.shield_wall.expires = cooldown.shield_wall.expires - activations
                    end
                    if talent.avatar.enabled then
                        cooldown.avatar.expires = cooldown.avatar.expires - activations
                    end
                end
                if talent.indomitable.enabled then
                    gain( ( 0.1 * activations ) * health.max, "health" )
                end
            end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local addition = floor( glory_rage / 10 ) * 0.5
            glory_rage = glory_rage % 10

            buff.conquerors_banner.expires = buff.conquerors_banner.expires + addition
        end

        if talent.violent_outburst.enabled then
            outburst_rage = outburst_rage + amt
            local stacks = floor( outburst_rage / 30 )
            outburst_rage = outburst_rage % 30
            if stacks > 0 then
                addStack( "seeing_red", nil, stacks )
                if buff.seeing_red.stack > 7 then
                    applyBuff( "violent_outburst" )
                    removeBuff( "seeing_red" )
                end
            end
        end
    end
end )

spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )

local TriggerEarthenTenacity = setfenv( function()
    applyBuff( "earthen_tenacity" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if set_bonus.tier30_4pc > 0 and buff.last_stand.up then
        state:QueueAuraExpiration( "last_stand_earthen_tenacity", TriggerEarthenTenacity, buff.last_stand.expires )
    end
end )

-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 401150,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = function () return buff.unnerving_focus.up and -15 or -10 end,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.immovable_object.enabled then
                applyBuff( "shield_wall", 4 )
            end
            if talent.violent_outburst.enabled then
                applyBuff( "violent_outburst" )
            end
        end,
    },


    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        startsCombat = false,
        texture = 132333,

        nobuff = "battle_shout",
        essential = true,

        handler = function ()
            applyBuff( "battle_shout" )
        end,
    },


    battle_stance = {
        id = 386164,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "battle_stance",
        startsCombat = false,
        nobuff = function() return settings.stance_weaving and "battle_stance" or "stance" end,

        handler = function ()
            applyBuff( "battle_stance" )
            removeBuff( "defensive_stance" )
        end,
    },


    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_rage",
        startsCombat = false,
        texture = 136009,

        toggle = "defensives",

        handler = function ()
            applyBuff( "berserker_rage" )
        end,
    },


    berserker_shout = {
        id = 384100,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_shout",
        startsCombat = false,
        texture = 136009,

        toggle = "defensives",

        handler = function ()
            applyBuff( "berserker_shout" )
        end,
    },


    bitter_immunity = {
        id = 383762,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "bitter_immunity",
        startsCombat = false,
        texture = 136088,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "dispellable_disease" )
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            gain( 0.2 * health.max, "health" )
        end,
    },


    bodyguard = {
        id = 213871,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        pvptalent = "bodyguard",
        startsCombat = false,
        texture = 132359,

        handler = function ()
        end,
    },


    challenging_shout = {
        id = 1161,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "challenging_shout",
        startsCombat = true,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "challenging_shout" )
            active_dot.challenging_shout = active_enemies
        end,
    },


    charge = {
        id = 100,
        cast = 0,
        charges  = function () return talent.double_time.enabled and 2 or 1 end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",
        icd = 1,

        spend = function () return -20 * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.minR > 8 and ( query_time - action.charge.lastCast > gcd.execute ), "target too close" end,
        handler = function ()
            applyDebuff( "target", "charge" )
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "defensive_stance",
        startsCombat = false,
        essential = true,
        nobuff = function() return settings.stance_weaving and "defensive_stance" or "stance" end,

        handler = function ()
            removeBuff( "battle_stance" )
            applyBuff( "defensive_stance" )
        end,
    },


    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function () return ( talent.booming_voice.enabled and -30 or 0 ) * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "demoralizing_shout",
        startsCombat = false,
        texture = 132366,

        handler = function ()
            applyDebuff( "target", "demoralizing_shout" )
            active_dot.demoralizing_shout = max( active_dot.demoralizing_shout, active_enemies )
        end,
    },


    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( talent.instigate.enabled and -2 or 0 ) * ( buff.unnerving_focus.up and 1.5 or 1) end,
        spendType = "rage",

        startsCombat = true,
        notalent = "devastator",

        handler = function ()
            applyDebuff( "target", "deep_wounds" )
        end,
    },


    disarm = {
        id = 236077,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "disarm",
        startsCombat = false,
        texture = 132343,

        handler = function ()
            applyDebuff( "target", "disarm" )
        end,
    },


    disrupting_shout = {
        id = 386071,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "disrupting_shout",
        startsCombat = false,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "disrupting_shout" )
            active_dot.disrupting_shout = active_enemies
        end,
    },


    dragon_charge = {
        id = 206572,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dragon_charge",
        startsCombat = false,
        texture = 1380676,

        handler = function ()
        end,
    },


    execute = {
        id = function () return talent.massacre.enabled and 281000 or 163201 end,
        known = 163201,
        copy = { 163201, 281000 },
        noOverride = 317485, -- Condemn
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        hasteCD = true,

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up then return true end
            if cycle_for_execute then return true end
            return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
        end,

        cycle = "execute_ineligible",

        indicator = function () if cycle_for_execute then return "cycle" end end,

        timeToReady = function()
            if buff.sudden_death.up then return 0 end
            local threshold = settings.reserve_rage + 40
            if rage.current >= threshold or ( buff.shield_block.remains > 3 and buff.ignore_pain.remains > 3 ) or not tanking then return 0 end
            return rage[ "time_to_" .. ( settings.reserve_rage + 40 ) ]
        end,

        handler = function()
            if not buff.sudden_death.up then
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
            else
                removeBuff( "sudden_death" )
            end
            if talent.juggernaut.enabled then addStack( "juggernaut" ) end
        end,
    },


    hamstring = {
        id = 1715,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132316,

        handler = function ()
            applyDebuff( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
        charges = function () return legendary.leaper.enabled and 3 or nil end,
        recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
        gcd = "off",
        icd = 0.8,

        talent = "heroic_leap",
        startsCombat = false,
        texture = 236171,

        handler = function ()
            if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
        end,
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        startsCombat = true,

        usable = function () return target.minR > 7, "requires 8 yard range or more" end,
        handler = function ()
            if talent.improved_heroic_throw.enabled then applyDebuff( "target", "deep_wounds" ) end
        end,
    },


    ignore_pain = {
        id = 190456,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 35,
        spendType = "rage",

        talent = "ignore_pain",
        startsCombat = false,
        texture = 1377132,

        toggle = "defensives",

        readyTime = function ()
            if settings.overlap_ignore_pain then return end
            if buff.ignore_pain.up and buff.ignore_pain.v1 >= 0.3 * health.max then
                return buff.ignore_pain.remains - gcd.max
            end
        end,

        handler = function ()
            if buff.ignore_pain.up then
                buff.ignore_pain.expires = query_time + class.auras.ignore_pain.duration
                -- TODO: Remove retail/PTR compatibility statement post 10.1 release. (3.5 [retail] vs 4.375 [10.1 patch])
                buff.ignore_pain.v1 = min( 0.3 * health.max, buff.ignore_pain.v1 + stat.attack_power * (Hekili.CurrentBuild > 100007 and 4.375 or 3.5) * ( 1 + stat.versatility_atk_mod / 100 ) )
            else
                applyBuff( "ignore_pain" )
                -- TODO: Remove retail/PTR compatibility statement post 10.1 release. (3.5 [retail] vs 4.375 [10.1 patch])
                buff.ignore_pain.v1 = min( 0.3 * health.max, stat.attack_power * (Hekili.CurrentBuild > 100007 and 4.375 or 3.5) * ( 1 + stat.versatility_atk_mod / 100 ) )
            end
        end,
    },


    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = function() return buff.victorious.up and 0 or 10 end,
        spendType = "rage",

        talent = "impending_victory",
        startsCombat = true,

        handler = function ()
            removeBuff( "victorious" )
            gain( health.max * 0.3, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = function ()
            if pvptalent.safeguard.enabled then return 40 end
            return 30
        end,
        charges = function () if pvptalent.safeguard.enabled then return 2 end end,
        recharge = function () if pvptalent.safeguard.enabled then return 40 end end,
        gcd = "off",
        icd = 1.5,

        talent = "intervene",
        startsCombat = false,

        handler = function ()
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end

            if pvptalent.safeguard.enabled then
                applyBuff( "safeguard" )
            end
        end,
    },


    intimidating_shout = {
        id = function() return talent.menace.enabled and 316593 or 5246 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = true,
        texture = 132154,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "intimidating_shout" )
            active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
        end,

        copy = { 316593, 5246 },
    },


    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = function() return 180 - ( talent.bolster.enabled and 60 or 0 ) end,
        gcd = "off",

        talent = "last_stand",
        startsCombat = false,
        texture = 135871,

        toggle = function()
            return settings.last_stand_offensively and "cooldowns" or "defensives"
        end,

        usable = function()
            if settings.last_stand_offensively and ( talent.unnerving_focus.enabled or conduit.unnerving_focus.enabled or set_bonus.tier30_2pc > 0 ) then return true end

            local dmg_required = ( ( settings.last_stand_amount or 10 ) * 0.01 ) * health.max * ( solo and 0.5 or 1 )
            local hp_required = ( ( settings.last_stand_health or 10 ) * 0.01 )
            local hp = health.percent or 10

            if settings.last_stand_condition then
                if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
                if health.percent > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", health.percent, hp_required ) end
                return true
            end

            if incoming_damage_5s >= dmg_required or hp <= hp_required then return true end
            if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
            if hp > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", hp, hp_required ) end
            return false
        end,

        handler = function ()
            applyBuff( "last_stand" )

            if talent.bolster.enabled then
                applyBuff( "shield_block", buff.last_stand.duration )
            end

            if talent.unnerving_focus.enabled then
                applyBuff( "unnerving_focus" )
            end

            if set_bonus.tier30_4pc > 0 then
                state:QueueAuraExpiration( "last_stand_earthen_tenacity", TriggerEarthenTenacity, buff.last_stand.expires )
            end
        end,
    },


    oppressor = {
        id = 205800,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "oppressor",
        startsCombat = false,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end
    },


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "piercing_howl",
        startsCombat = false,
        texture = 136147,

        handler = function ()
            applyDebuff( "target", "piercing_howl" )
            active_dot.piercing_howl = max( active_dot.piercing_howl, active_enemies )
        end,
    },


    pummel = {
        id = 6552,
        cast = 0,
        cooldown = function () return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.concussive_blows.enabled then applyDebuff( "target", "concussive_blows" ) end
        end,
    },


    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "rallying_cry",
        startsCombat = false,
        texture = 132351,

        toggle = "defensives",

        usable = function()
            local dmg_required = ( settings.rallying_cry_amount * 0.01 ) * health.max * ( solo and 0.5 or 1 )
            local hp_required = ( settings.rallying_cry_health * 0.01 )

            if settings.rallying_cry_condition then
                if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
                if health.percent > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", health.percent, hp_required ) end
                return true
            end

            if incoming_damage_5s >= dmg_required or ( health.percent or 50 ) <= hp_required then return true end
            if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
            if health.percent > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", health.percent, hp_required ) end
            return false
        end,

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( 0.10 * health.max, "health" )
        end,
    },


    ravager = {
        id = 228920,
        cast = 0,
        charges = function () return ( talent.storm_of_steel.enabled and 2 or 1 ) end,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ravager" )
        end,
    },


    rend = {
        id = 394062,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "rend",
        startsCombat = true,
        texture = 132155,

        handler = function ()
            applyDebuff( "target", "rend" )
        end,
    },


    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.revenge.up then return 0 end
            return talent.barbaric_training.enabled and 30 or 20
        end,
        spendType = "rage",

        talent = "revenge",
        startsCombat = true,
        texture = 132353,

        readyTime = function()
            if buff.revenge.up then return 0 end
            local threshold = action.revenge.cost + ( settings.reserve_rage or 40 )
            if rage.current >= threshold or ( buff.shield_block.remains > 3 and buff.ignore_pain.remains > 3 ) or not tanking then return 0 end
            return rage[ "time_to_" .. threshold ]
        end,

        handler = function ()
            if set_bonus.tier29_2pc > 0 then applyBuff( "vanguards_determination" ) end
            if buff.revenge.up then removeBuff( "revenge" ) end
            if talent.show_of_force.enabled then applyBuff( "show_of_force" ) end
            applyDebuff( "target", "deep_wounds" )
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            removeDebuff( "target", "all_absorbs" )
        end,
    },


    shield_bash = {
        id = 198912,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        spend = -3,
        spendType = "rage",

        pvptalent = "shield_bash",
        startsCombat = false,
        texture = 132357,

        handler = function ()
            applyDebuff( "target", "shield_bash" )
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 2,
        cooldown = 16,
        recharge = 16,
        hasteCD = true,
        gcd = "off",

        toggle = "defensives",
        equipped = "shield",
        defensive = true,

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        nobuff = function()
            if not settings.stack_shield_block then return "shield_block" end
        end,

        handler = function ()
            applyBuff( "shield_block" )
        end,
    },


    shield_charge = {
        id = 385952,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = -20,
        spendType = "rage",

        talent = "shield_charge",
        equipped = "shield",
        startsCombat = true,

        handler = function ()
            if talent.battering_ram.enabled then
                applyBuff( "battering_ram" )
            end
            if talent.champions_bulwark.enabled then
                applyBuff( "shield_block" )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = function () return 9 - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        hasteCD = true,
        gcd = "spell",

        spend = function ()
            local reduction = 0
            -- The Wall Legendary overtakes the new Impenetrable Wall talent, they do not stack in 10.0
            if legendary.the_wall.enabled then reduction = -5
            elseif talent.impenetrable_wall.enabled then reduction = -3
            end

            return
            ( -15 + reduction + ( talent.heavy_repercussions.enabled and -2 or 0 ) )
            * ( buff.violent_outburst.up and 1.5 or 1 ) -- Build 45969
            * ( buff.unnerving_focus.up and 1.5 or 1 )
        end,
        spendType = "rage",

        equipped = "shield",
        startsCombat = true,
        texture = 134951,

        handler = function ()
            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end

            if talent.brace_for_impact.enabled then applyBuff( "brace_for_impact" ) end

            if talent.heavy_repercussions.enabled and buff.shield_block.up then
                buff.shield_block.expires = buff.shield_block.expires + 1
            end

            if talent.punish.enabled then applyDebuff( "target", "punish" ) end

            if ( legendary.the_wall.enabled or talent.impenetrable_wall.enabled ) and cooldown.shield_wall.remains > 0 then
                reduceCooldown( "shield_wall", 5 )
            end

            if set_bonus.tier30_2pc > 0 then
                reduceCooldown( "last_stand", buff.last_stand.up and 4 or 2 )
            end

            if buff.fervid.up then
                removeDebuff( "target", "deep_wounds" )
                removeDebuff( "target", "rend" )
                removeDebuff( "target", "thunderous_roar" )
                if set_bonus.tier31_4pc > 0 then applyBuff( "fervid_opposition" ) end
            end
        end,
    },


    shield_wall = {
        id = 871,
        cast = 0,
        charges = function () return 1 + ( talent.defenders_aegis.enabled and 1 or 0 ) + ( legendary.unbreakable_will.enabled and 1 or 0 ) end,
        cooldown = function() return 210 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.defenders_aegis.enabled and 30 or 0 ) end,
        recharge = function() return 210 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.defenders_aegis.enabled and 30 or 0 ) end,
        gcd = "off",

        talent = "shield_wall",
        startsCombat = false,
        texture = 132362,

        toggle = "defensives",

        usable = function()
            local dmg_required = ( ( settings.shield_wall_amount or 10 ) * 0.01 ) * health.max * ( solo and 0.5 or 1 )
            local hp_required = ( ( settings.shield_wall_health or 10 ) * 0.01 )

            if settings.shield_wall_condition then
                if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
                if health.percent > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", health.percent, hp_required ) end
                return true
            end

            if incoming_damage_5s >= dmg_required or ( health.percent or 50 ) <= hp_required then return true end
            if incoming_damage_5s < dmg_required then return false, format( "incoming_damage_5s[%.2f] < dmg_required[%.2f] setting", incoming_damage_5s, dmg_required ) end
            if health.percent > hp_required then return false, format( "health.percent[%.2f] > hp_required[%.2f] setting", health.percent, hp_required ) end
            return false
        end,

        handler = function ()
            applyBuff( "shield_wall" )
            if talent.immovable_object.enabled then applyBuff( "avatar", 10 ) end
        end,
    },


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return
            ( ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 )
            - ( conduit.disturb_the_peace.enabled and 5 or 0 )
            ) end,
        gcd = "spell",

        talent = "shockwave",
        startsCombat = true,
        texture = 236312,

        toggle = "interrupts",
        debuff = function () return settings.shockwave_interrupt and "casting" or nil end,
        readyTime = function () return settings.shockwave_interrupt and timeToInterrupt() or nil end,

        usable = function () return not target.is_boss end,

        handler = function ()
            applyDebuff( "target", "shockwave" )
            active_dot.shockwave = max( active_dot.shockwave, active_enemies )
            if not target.is_boss then interrupt() end
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
        end,
    },


    spell_block = {
        id = 392966,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "spell_block",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "spell_block" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "storm_bolt",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "storm_bolt" )
        end,
    },


    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "taunt" )
        end,
    },


    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
        gcd = "spell",
        hasteCD = true,

        spend = function () return -5
            * ( buff.violent_outburst.up and 2 or 1 )
            * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
            removeBuff( "show_of_force" )

            if ( talent.thunderlord.enabled or legendary.thunderlord.enabled ) and cooldown.demoralizing_shout.remains > 0 then
                reduceCooldown( "demoralizing_shout", min( 3, active_enemies ) )
            end

            if talent.blood_and_thunder.enabled and talent.rend.enabled then -- Blood and Thunder now directly applies Rend to 5 nearby targets
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end

            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end
        end,
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = function() return talent.uproar.enabled and 60 or 90 end,
        gcd = "spell",

        spend = -10,
        spendType = "rage",

        talent = "thunderous_roar",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "thunderous_roar" )
            active_dot.thunderous_roar = max( active_dot.thunderous_roar, active_enemies )
        end,
    },


    titanic_throw = {
        id = 384090,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        talent = "titanic_throw",
        startsCombat = true,

        handler = function ()
            if talent.improved_heroic_throw.enabled then
                applyDebuff( "target", "deep_wounds" )
                active_dot.deep_wounds = min( active_enemies, 5 )
            end
        end,
    },


    victory_rush = {
        id = 34428,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        buff = "victorious",

        handler = function ()
            removeBuff( "victorious" )
            gain( 0.2 * health.max, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = true,

        handler = function ()
            removeDebuff( "target", "all_absorbs" )
        end,
    },
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting (and talented).",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "overlap_ignore_pain", false, {
    name = "Overlap |T1377132:0|t Ignore Pain",
    desc = "If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active.  This setting may cause you to spend more Rage on mitigation.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "stack_shield_block", false, {
    name = "Overlap |T132110:0|t Shield Block",
    desc = function()
        return "If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage. \n\n" ..
        "This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "stance_weaving", false, {
    name = "Allow Stance Changes",
    desc = function()
        return "If checked, custom priorities can be written to recommend changing between stances.  For example, Battle Stance could be recommended when "
            .. "using offensive cooldowns, then Defensive Stance can be recommended when tanking resumes.\n\n"
            .. "If left unchecked, the addon will not recommend changing your stance as long as you are already in a stance.  This choice prevents the addon "
            .. "from endlessly recommending that you change your stance when you do not want to change it."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "reserve_rage", 35, { -- Ignore Pain cost is 35, Shield Block is 30.
    name = "|T135726:0|t Reserve Rage for Mitigation",
    desc = "If set above 0, the addon will not recommend |T132353:0|t Revenge or |T135358:0|t Execute unless you'll be still have this much Rage afterward.\n\n"
        .. "When set to |cFFFFD10035|r or higher, this feature ensures that you can always use |T1377132:0|t Ignore Pain and |T132110:0|t Shield Block when following recommendations for damage and threat.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shield_wall_amount", 50, {
    name = "|T132362:0|t Shield Wall Damage Required",
    desc = "If set above 0, the addon will not recommend |T132362:0|t Shield Wall unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Shield Wall when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shield_wall_health", 50, {
    name = "|T132362:0|t Shield Wall Health Percentage",
    desc = "If set below 100, the addon will not recommend |T132362:0|t Shield Wall unless your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shield_wall_condition", false, {
    name = "Require |T132362:0|t Shield Wall Damage and Health",
    desc = "If checked, |T132362:0|t Shield Wall will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\n"
        .. "Otherwise, Shield Wall can be recommended when |cFFFFD100either|r requirement is met.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "rallying_cry_amount", 50, {
    name = "|T132351:0|t Rallying Cry Damage Required",
    desc = "If set above 0, the addon will not recommend |T132351:0|t Rallying Cry unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Rallying Cry when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rallying_cry_health", 50, {
    name = "|T132351:0|t Rallying Cry Health Percentage",
    desc = "If set below 100, the addon will not recommend |T132351:0|t Rallying Cry unless your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rallying_cry_condition", false, {
    name = "Require |T132351:0|t Rallying Cry Damage and Health",
    desc = "If checked, |T132351:0|t Rallying Cry will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\n"
        .. "Otherwise, Rallying Cry can be recommended when |cFFFFD100either|r requirement is met.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "last_stand_offensively", false, {
    name = "Use |T135871:0|t Last Stand Offensively",
    desc = function()
        return "If checked, the addon will recommend using |T135871:0|t Last Stand to generate rage.\n\n"
            .. "If unchecked, the addon will only recommend |T135871:0|t Last Stand defensively after taking significant damage.\n\n"
            .. "Requires " .. ( state.set_bonus.tier30_2pc > 0 and "|cFF00FF00" or "|cFFFF0000" ) .. "2-piece Tier 30|r or "
            .. "|W|T571316:0|t " .. ( ( state.talent.unnerving_focus.enabled or state.conduit.unnerving_focus.enabled ) and "|cFF00FF00" or "|cFFFF0000" ) .. " Unnerving Focus|r|w"
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "last_stand_amount", 50, {
    name = "|T135871:0|t Last Stand Damage Required",
    desc = "If set above 0, the addon will not recommend |T135871:0|t Last Stand unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Last Stand when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
    disabled = function() return state.settings.last_stand_offensively end,
} )

spec:RegisterSetting( "last_stand_health", 50, {
    name = "|T135871:0|t Last Stand Health Percentage",
    desc = "If set below 100, the addon will not recommend |T135871:0|t Last Stand unless your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
    disabled = function() return state.settings.last_stand_offensively end,
} )

spec:RegisterSetting( "last_stand_condition", false, {
    name = "Require |T135871:0|t Last Stand Damage and Health",
    desc = "If checked, |T135871:0|t Last Stand will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\n"
        .. "Otherwise, Last Stand can be recommended when |cFFFFD100either|r requirement is met.",
    type = "toggle",
    width = "full",
    disabled = function() return state.settings.last_stand_offensively end,
} )


local LSR = LibStub( "SpellRange-1.0" )

spec:RegisterRanges( "hamstring", "devastate", "execute", "storm_bolt", "charge", "heroic_throw", "taunt" )

spec:RegisterRangeFilter( strformat( "Can %s but cannot %s (8 yards)", Hekili:GetSpellLinkWithTexture( spec.abilities.taunt.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.charge.id ) ), function()
    return LSR.IsSpellInRange( spec.abilities.taunt.name ) == 1 and LSR.IsSpellInRange( class.abilities.charge.name ) ~= 0
end )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    rangeChecker = "hamstring",
    rangeFilter = true,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_strength",

    package = "Protection Warrior",
} )


spec:RegisterPack( "Protection Warrior", 20240116, [[Hekili:fRvBVTTTw4Flbxa3ySghl74K0ERdWUf7dRyR3I6nSVzzAjABTilPlfvAtHH)TFphskjsAsz7(cg2ABI4HNxFohE4lZdM)hZNft405VF0Wr3mmi42bb3n5(GrZNXFUGoFwbj6rYA4hYiBH)(dSConINKNTFXFrySKCgsZZP5KyKxL5vSiGUnCEr5RV(61j8nvlheLV96YKTvPeCQrmYko(7rxpF2YQKu(VMnFPBfja4zbnA(7VBmW1K4yQKuAz08zaPJVki4QHtE9(f7x8bcpAZ(fbdhmAW(3T)DIHho5Qr3lg(plqbSFbpF)cGv00y4FtjB3VOQemX9lsaJ6N)V)I5ChkMBn9)fjnD)ITjz5myAcgAq(qPO(5yGwsCCcAUeyg)YNPrvCLmktYwNsVItyRPC4tR2V4JsfOC)Ijd)P9lUSKNGckzl4)5uGzlFgiIwszprRPEfQd)oiI1ezajVa)3(Ak0nxnwQ)JYI9R23C1OBfu976eacGLdoNznXT3IXnLCbNCGglgxZcWrH0u7VE7g0ibFrM(VSmhTIpuTDlnvn2SckAWFKUkvIVga4kw(QKuanreFPCqbJciPLe(pn96y6kAwzYt0WsojlI(YKvtxwTA1a5Voio)tz7FNRzc)npfM2M8kUBkQkPHjC62xIG(PKuimbQEyr1x(cmXL5F290iprGykQixWjP0m(aEcOmLH8C2w4xDpl4hFmLwwMb)rFU1FpKSe8qq8fC2)RgKe4YOprzaQGNSfb1BqhBehJnimc0LKuYYumoRKkiRsryjmseiqHHtE6qDs6ASczetNHyylK1e10hR2lwQ)rPpsyj)PmRlFLD6fQ)RbiclRg5JLasiPjFrH0lPCoKev(VXFe4X1BOpMKMSFXdaSQPeLlt)tGeegN0jNSDB(tOBkmF5FdZAand)T4EcOKuznHsiaknppoCvf491)kLbPNpcQLH9YIizuebW0raWiPjR3Wld)7Q41BTgAvcJkeIbNauDjNrsdJqVKUKjRdZxfYzjrpA4SlYXFQjZqzovf60KSgY5PHfKKmPFblknydLKY3mOiI)W0rd7DjdcvdGuUKOe(BMgmPxuEEk6xgO8RLqHuaYsIFE3otIVz4belXysY7PIeW32wG6u4YQ0prypwhkS53OU5Nn5J1ipMUnNHWiiijZ)n1HL55BXHEkpbQGCcYx5rDB3t(gfSedMsk5IsCXqGRM(QSmyLaCgRYJQk9PQJ9OQF7CE0Wtim3IjKc8PKCugHG5VSIvY1elG3E6zOosbLbsTuuKS2n0KQwqZOqcaMTIPX(0TjDHo9RjNTp5hHUhCxx6(Xf4b87(tGFE1U(72jY8Fy6Dq8wU6kLIocgngxOn6XP31tsX4j99jQTqTLsqxKUy1yq9TOhRh8HP30dQPdlTMb(xEcLnoiCur0lX1qYxTkCDu80a7vn(niybRDWfnqiw0lTm)hWshTGcTvoSaf9U0rLZxbETd(mM80h)UkZpTKtzoCnOJC3UlSO7c3IF3ol33q099WqBx2hHO7Z4sulEl27WpKvAzkzegzUajdkbTMY0)0H1f18WolkA1QIAjdqRjgmg21rwmLLxvgYYnhsdB2SY4k0xgBTYiOprp(jYtunDQmpljke1mNDkOxZOKNxuisPGgM1QQ30Fx12LPO9bQoGmAsG9lPoNypzRys4w5GgLhYm92bOJbeyV2EPnaKvmbOaYKn6kKvLfk)TW0KsUQP5C6llXos4tdq2zQDQWtyukPWsbXMBoKDRHcuaZWEGR7HgKqBGwWjuoX54sRq5BTYo14jrBBqwCOAsnouGEB(AHsU0v6LJKUBkI63ZVT(MP3PQJkID0Sqoe(Gk1pRJ98yAEx5YP8eU2Bpx0PToWGnzKj3oq9cb18OKMuUfGOijmO5xb2WdAuXg9qTB)mkK3m926vBolRfCUD5cpQPnw1tZdyVm1ygcd(FWkHvhtYGKUwhvl)uGttRX1WhhSoYt)jM7MTLJu5UbBtyRWtijmMsGkdTXBJpFqO(a2Dk6(LDKrhSBxxTc07cFb3(UKSwGs1nY9y8XE12r1Ggf9sZ3XIV9KGm)TgjuYtGzpiwiVlDA8KtGnqF6t((PtyFyQO(wszjjI5i52jaYzkl21vNHedna8iFRyNPhd8CwyNy6tqZB45kodQsHTkloGXXbbdNmFgSntmNUC(S)ap(eOp4Cw9bC9cOkXl2VGr)FvWUXHUJkZXZzHuXZ3seN)cSgk4dkHEF(TKmyOGxdDvLNbYrm8l8TSZlKhbP3XRdxaDxg85(hJ)ybelwkQPCax2)ohwjStbsvk)mT07CRkwnLAPvE2g1bMPhMR6a227j)6)Om7B0SDgxAoHWZlYCJBn08CiTuqZb9z8t8H(mpLYdqIMd7Y6)vHHJm9gXryMG77aB9dnR5ZaRDdEldwNd98zcsWlDaYuH)59IlZqX)5)N5ZIyjqWmHmFM96S7x8MPq4C)IEG2EKSqDI0ZRQpv65Z0lFnNd1x8Qhxk2p1b9rUFXUDog5gCK(c57VEP0uUtYcFDw2QRAfurvDSxv1xvw)QJuBGTfERGgRtCuZl6T5t)U0B8QNmXwBFa9bd1fsNDN6WiuROjz14wnr9DujMCeLade3ouls8v4(ebtVHRBfODx(in9cO7UtWDnwPPTF5gdhO3oFD5BGSr1AUnjIUmbtT0FEI781rT4kN9h7h(CeyUvtZgWihno3khvZtniu7VBAV(Xpx2Dg(dIAvyWQRgJeQ9fDb9673dDBx6wle5(AiIvxNcDCKo2VThvFZqesL8Rn)j4EXh62opdHOuR(YjD62Y4jNLyqvhNYpABbLrFD8PDl(olC5VCGNAGOY7eLFVxozOVk)UtL5vF1zbtp90GVQCGGH65WA7CqplMJJiAz2vlhwf9KNYM81kWskKJD2xGRHBwql4jg2Dfun6AukL2uxpS(ZYl11QwLr5m7l51vDTAABU0xlImw6s2wWrw0YYxI3lHLN87Wfi)YUpwBteUiJZ3ngFqtpILKQZzQnM2Ro2Y6FLbvnxLSfvMquZ7w2MuJvHTUSzBAhPtBZTpBtLbSX86OTj1a)yC)02u6FvrZoi1aSIB1wmz7LTQjr7sT9wKsvuTDvi1Qd1xEMQi(KUkItIFUTlkZjQ6MQRRQwVqU3R)2h)hDk839uhBnvF3oTr7GoVmMtu30V7zV(RjF3uQ6erJlZ1Chio3s(P6VmnNV3sB0WZesPJf7CTVwvQJBqwNmVxmSpnCYXZwoMg(v6l)XBBb3Dk22POeE4FNTlAX)o0Ex96ENER52xHVOpbPXPT9WMon7UzR2dsrYBhxUVA3LcICDj)YMgu3Yp2tfwz3x3aTid)nd8n9Uao)oc6ctEP7o5b)XRuHKo2zu)Akuf7moCsp(CXffjM2fDoZloEkLZdLsCCvpO6)mWE)a(IiF1p7GJgnA2HH2JoqOAgnuPE6b2haXWo2oJ)fy03JG9Auc2A05L1JuWwfm68Y6vlyt7rogJMhXWb9oxF(rJ8FoA1N3XbV6GwC25DyEwOm3pAbdaUhzFeg0ZExJnV8HdolVMre(cJTTyTHnt)U)dhXr(N6rsOQmo8ariitW2tDB5hUnyWMKVTcSAzli38DyipG8q572hpICuM2jSnOuRxDHXKRpApXUFBUycx7)12Z0(uS1tAmF42nBKTD7cTVpBRqHDgGY4o8bARTpfhdY76eLBXSUVyKd2glVRJ2tldWZvHOfa1Ej4cNT8)M)))d]] )