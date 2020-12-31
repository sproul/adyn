:
cd $DROP/adyn/teacher/
. bin/teacher.env

Xlate()
{
	inputFile=$1
	xlateCapitalizeGerman=$2
	verbToAddTo=$3
	args=$4
	dataFile=`echo $inputFile|sed -e 's;xlate_input/;;'`
	perl -w ./tx.pl -xlate $inputFile -xlatePath $dataFile -xlateCapitalizeGerman $xlateCapitalizeGerman
	if [ -n "$verbToAddTo" ]; then
                echo "perl -w teacher.pl -genPath verb_$verbToAddTo -linkToPath $dataFile $args"
	fi
}

# never used:
#Xlate xlate_input/vocab_liquids

#Xlate xlate_input/days___do_not_run_this_again--these_data_are_customized
#Xlate xlate_input/months_and_seasons 1
#Xlate xlate_input/permanent_personal_adjectives___do_not_run_this_again--these_data_are_customized
#Xlate xlate_input/transient_personal_adjectives___do_not_run_this_again--these_data_are_customized
#Xlate xlate_input/countries
#Xlate xlate_input/vocab_ordinals 1
#Xlate xlate_input/vocab_numbers 1
#Xlate xlate_input/things_to_buy 1
#Xlate xlate_input/vocab_things_to_eat 1
#Xlate xlate_input/things_to_drink
#Xlate xlate_input/vocab_languages
#Xlate xlate_input/things_to_be_heard 1
#Xlate xlate_input/things_to_celebrate
#Xlate xlate_input/places_to_go
#Xlate xlate_input/places_to_come
#Xlate xlate_input/plural_things_to_possess
#Xlate xlate_input/things_to_wait_for
#Xlate xlate_input/vocab_time
#Xlate xlate_input/vocab_languages
#Xlate xlate_input/things_to_begin 1 begin
#Xlate xlate_input/things_to_brush 1 brush
#Xlate xlate_input/things_to_close 1 close
#Xlate xlate_input/things_to_share 1 share
#Xlate xlate_input/things_to_fry 1 fry
#Xlate xlate_input/things_to_understand 1 understand
#Xlate xlate_input/things_to_study 1 study
#Xlate xlate_input/things_to_describe 1 describe
#Xlate xlate_input/things_to_seem 1 seem
#Xlate xlate_input/things_to_amuse 1 amuse
#Xlate xlate_input/things_to_wake_up - awake
#Xlate xlate_input/things_to_fear - fear
#Xlate xlate_input/vocab_professions
#Xlate xlate_input/places_to_live
#Xlate xlate_input/how_much_things_can_be_worth
#Xlate xlate_input/vocab_animals
#Xlate xlate_input/things_to_prefer
#Xlate xlate_input/things_to_permit 1
#Xlate xlate_input/things_to_lift 1
#Xlate xlate_input/things_to_say 1
#Xlate xlate_input/things_to_receive 1
#Xlate xlate_input/things_to_wash 1
#Xlate xlate_input/things_to_protect 1
#Xlate xlate_input/things_to_steal 1
#Xlate xlate_input/things_to_become
#Xlate xlate_input/things_to_continue
#Xlate xlate_input/things_to_write 1
#Xlate xlate_input/things_to_be_able_to
#Xlate xlate_input/how_to_sleep
#Xlate xlate_input/things_to_read
#Xlate xlate_input/things_to_send
#Xlate xlate_input/things_to_construct
#Xlate xlate_input/things_to_forget
#Xlate xlate_input/things_to_feel_physically
#Xlate xlate_input/things_to_feel_emotionally
#Xlate xlate_input/things_to_serve
#Xlate xlate_input/things_to_lose
#Xlate xlate_input/things_to_reserve
#Xlate xlate_input/things_to_bring
#Xlate xlate_input/vocab_materials
#Xlate xlate_input/things_to_melt
#Xlate xlate_input/things_to_throw
#Xlate xlate_input/things_to_count
#Xlate xlate_input/ways_to_move
#Xlate xlate_input/ways_to_crawl
#Xlate xlate_input/things_to_climb
#Xlate xlate_input/things_to_smell
#Xlate xlate_input/things_resolve
#Xlate xlate_input/things_that_swell
# Marge asked to rvw all above this pt (but has some items not_sent)
#Xlate xlate_input/ways_to_turn
#Xlate xlate_input/ways_to_be_emotionally
#Xlate xlate_input/things_to_lend
#Xlate xlate_input/things_to_play
#Xlate xlate_input/things_to_bake
#Xlate xlate_input/things_that_gush
#Xlate xlate_input/things_to_separate
#Xlate xlate_input/things_to_perceive
#Xlate xlate_input/things_to_excuse
#Xlate xlate_input/things_to_cut
#Xlate xlate_input/things_to_dream_about
#Xlate xlate_input/where_to_fall
#Xlate xlate_input/how_to_quarrel
#Xlate xlate_input/things_to_sharpen
#Xlate xlate_input/things_to_realize
#Xlate xlate_input/things_to_give
#Xlate xlate_input/things_to_believe
#Xlate xlate_input/things_to_spend
#Xlate xlate_input/things_to_deny
#Xlate xlate_input/things_to_blow
#Xlate xlate_input/people
#Xlate xlate_input/relatives
# Mommy asked to rvw all above this pt
#Xlate xlate_input/things_to_announce
#Xlate xlate_input/people_to_name
#Xlate xlate_input/things_to_meditate
#Xlate xlate_input/things_to_pull
#Xlate xlate_input/vocab_linking
#Xlate xlate_input/vocab_pronouns_subject
#Xlate xlate_input/vocab_pronouns_possessive
#Xlate xlate_input/things_to_resolve
#Xlate xlate_input/things_to_abolish
#Xlate xlate_input/things_to_buy_imperfect
#Xlate xlate_input/things_to_escape
#Xlate xlate_input/things_to_correct
#Xlate xlate_input/vocab_place_setting
#Xlate xlate_input/vocab_body
#Xlate xlate_input/vocab_travel
#Xlate xlate_input/things_to_burst
#Xlate xlate_input/how_to_swear
#Xlate xlate_input/things_to_create
#Xlate xlate_input/things_to_use
#Xlate xlate_input/things_to_direct
#Xlate xlate_input/things_to_replace
#Xlate xlate_input/things_to_try
#Xlate xlate_input/things_to_know
#Xlate xlate_input/things_to_put 1 put
Xlate xlate_input/places_to_swim 1 swim

exit
bx $DROP/adyn/teacher/xlate.sh 