# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

################# Users ############################
User.create!(:email => "test@test.com", :password => "123456")
Registration.create!(year: "2015", user_id: 1, first_name: "Test", last_name: "Registration", street1: "123 Test Street", street2: "", city: "Test", state: "TX", zip: "12345", primaryphone: nil, secondaryphone: nil, emergency_contact_name: "", emergency_contact_phone: "", firsttime: true, mailinglist: true, donotpublish: false, dorm: true, dorm_selection: "d", share_housing_with: "", meals: true, meals_lunch_and_dinner_only: false, vegetarian: false, meals_selection: "f", gender: "F", participant: true, instrument_id: 22, monday: false, tshirtm: 0, tshirtl: 0, tshirtxl: 0, tshirtxxl: 0, discount: false, donation: 0, comments: "", aircond: false, payment_mode: "deposit_check", created_at: "2015-03-17 02:34:02", updated_at: "2015-03-17 02:34:02", country: "US", home_phone: "1235551212", cell_phone: "", work_phone: "", handicapped_access: false, airport_pickup: false, fan: false, sunday: false, wine_glasses: 0, tshirts: 0, tshirtxxxl: 0, occupation: "", single_room: false)

User.create!(:email => "midsummer@musicalretreat.org", :password => "walla2", :admin => true)

################# Instruments ############################

Instrument.create(:id => 1,  :display_name => "Voice-Soprano",      :large_ensemble => "chorus", :instrument_type => "vocal")
Instrument.create(:id => 2,  :display_name => "Voice-Alto",         :large_ensemble => "chorus", :instrument_type => "vocal")
Instrument.create(:id => 3,  :display_name => "Voice-Tenor",        :large_ensemble => "chorus", :instrument_type => "vocal")
Instrument.create(:id => 4,  :display_name => "Voice-Baritone",     :large_ensemble => "chorus", :instrument_type => "vocal")
Instrument.create(:id => 5,  :display_name => "Voice-Bass",         :large_ensemble => "chorus", :instrument_type => "vocal")
Instrument.create(:id => 6,  :display_name => "Violin",             :large_ensemble => "festival_or_string_orchestra", :instrument_type => "string")
Instrument.create(:id => 7,  :display_name => "Viola",              :large_ensemble => "festival_or_string_orchestra", :instrument_type => "string")
Instrument.create(:id => 8,  :display_name => "Cello",              :large_ensemble => "festival_or_string_orchestra", :instrument_type => "string")
Instrument.create(:id => 9,  :display_name => "Double Bass",        :large_ensemble => "festival_or_string_orchestra", :instrument_type => "string")
Instrument.create(:id => 10, :display_name => "Piccolo",            :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 11, :display_name => "Flute",              :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 12, :display_name => "Oboe",               :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 14, :display_name => "Bassoon",            :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 15, :display_name => "Clarinet",           :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 37, :display_name => "Clarinet-Alto",      :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 16, :display_name => "Clarinet-Bass",      :large_ensemble => "band_or_orchestra", :instrument_type => "woodwind")
Instrument.create(:id => 17, :display_name => "Saxophone",          :large_ensemble => "band", :instrument_type => "woodwind")
Instrument.create(:id => 18, :display_name => "Saxophone-Soprano",  :large_ensemble => "band", :instrument_type => "woodwind")
Instrument.create(:id => 19, :display_name => "Saxophone-Alto",     :large_ensemble => "band", :instrument_type => "woodwind")
Instrument.create(:id => 20, :display_name => "Saxophone-Tenor",    :large_ensemble => "band", :instrument_type => "woodwind")
Instrument.create(:id => 21, :display_name => "Saxophone-Baritone", :large_ensemble => "band", :instrument_type => "woodwind")
Instrument.create(:id => 22, :display_name => "Trumpet",            :large_ensemble => "band_or_orchestra", :instrument_type => "brass")
Instrument.create(:id => 23, :display_name => "Horn",               :large_ensemble => "band_or_orchestra", :instrument_type => "brass")
Instrument.create(:id => 24, :display_name => "Trombone",           :large_ensemble => "band_or_orchestra", :instrument_type => "brass")
Instrument.create(:id => 25, :display_name => "Trombone-Bass",      :large_ensemble => "band_or_orchestra", :instrument_type => "brass")
Instrument.create(:id => 26, :display_name => "Euphonium",          :large_ensemble => "band", :instrument_type => "brass")
Instrument.create(:id => 27, :display_name => "Tuba",               :large_ensemble => "band_or_orchestra", :instrument_type => "brass")
Instrument.create(:id => 28, :display_name => "Percussion",         :large_ensemble => "band_or_orchestra", :instrument_type => "percussion")
Instrument.create(:id => 31, :display_name => "Timpani",            :large_ensemble => "band_or_orchestra", :instrument_type => "percussion")
Instrument.create(:id => 32, :display_name => "Harp",               :large_ensemble => "festival_or_string_orchestra", :instrument_type => "string")
Instrument.create(:id => 34, :display_name => "Piano",              :large_ensemble => "none", :instrument_type => "string")

##################### Dummy registrations ###########################

 def create_test_registrations
   Instrument.all.each{|i| create_standard_registration(i)}
 end

 def create_test_registration(instrument)
   u = User.new(:email => "#{instrument.display_name.gsub(' ', '-').downcase}@mmr.org")
   u.password = "mmr"
   u.save!
   Registration.create(year: "2015", user_id: u.id, first_name: "Test", 
                       last_name: instrument.display_name, street1: "Any", city: "Any", state: "WA", zip: "98101",
                       home_phone: "2061111111", work_phone: "2061111111", cell_phone: "2061111111",
                       instrument_id: instrument.id)
 end

####################### Electives ############################

def link_elective_to_instruments(elective, list_of_instrument_ids)
  list_of_instrument_ids.each{|iid| elective.instruments << Instrument.find(iid)}
  elective.save!
end

e = Elective.create(
:name => "Free Time",
:instructor => "You!",
:description => "You're not being lazy; you deserve it! And don't let anybody tell you otherwise. If they do, punch them!  Then take a nap."
)

e = Elective.create(
:name => "Composition",
:instructor => "Roupen Shakarian",
:description => "The composition class is a workshop for those who are already working on a piece or would like to have input on their completed work(s). Prior experience and knowledge of intermediate theory is required."
)

e = Elective.create(
:name => "Music Theory for the Fun of It",
:instructor => "Thane Lewis",
:description => "Join us for a four-day journey into the language of music. You will do some simple and fun ear training and dictation. You will experience enlightenment as you clarifiy musical terms and review simple notation, keys and key signatures and their relationships.  A special guest artist of the musical occult will join us to plumb the human psychology and mystery of the progression and you will investigate some friendly web-based musical resources to take your study of theory and ear-training with you when you return to the mundane world. An experience not to be missed."
)

e = Elective.create(
:name => "Beginning Voice Class",
:instructor => "Gabriel Gargari",
:description => "This elective is specifically geared toward those who may be new to singing and will cover the basics of vocal production and singing. Participants will each learn one song for possible solo performance. Open to instrumentalists and vocalists; previous music fundamentals or sight-reading skills study recommended."
)

e = Elective.create(
:name => "Bowing Techniques",
:instructor => "Cecilia Archuleta",
:description => "A class emphasizing bow control. How to sustain a beautiful sound, on those slow movements.  Learn to play comfortably at the frog and tip of the bow.  Produce the sound you want to hear!"
)
link_elective_to_instruments(e, [6,7,8,9])

e = Elective.create(
:name => "Baroque String Ensemble",
:instructor => "Sandi Schwarz",
:description => "A chance to explore repertoire, style and technique with a true master of baroque performance.  Open to all strings."
)
link_elective_to_instruments(e, [6,7,8,9])

e = Elective.create(
:name => "Flute Choir",
:instructor => "Faculty",
:description => "A choir!  Of Flutes!!  Lots of flutes!!!  The more flutes the better!!!!  Maybe if we all play up an octave we can break a wine glass!!!!"
)
link_elective_to_instruments(e, [11,10])

e = Elective.create(
:name => "Percussion Ensemble",
:instructor => "Matt Drumm",
:description => "An ensemble.  Of percussion.  Loud! Not annoying loud, just loud!  As long as you're not living upstairs."
)
link_elective_to_instruments(e, [28,31])

e = Elective.create(
:name => "Drum Circle",
:instructor => "Karen Sunmark",
:description => "You do not have to be a master drummer to succeed in this class. After learning the basic technique for hand drumming we will learn African and Latin drumming patterns. Through these patterns we practice our ensemble skills of listening, feeling the internal pulse and fitting our rhythm into the pattern. Past students have said that transferring what they learn in this class to their other instruments helps them in rehearsal and performance settings. "
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Afternoon Elective Orchestra",
:instructor => "Roger Nelson",
:description => "An afternoon ensemble for strings and classical brass and winds. Repertoire drawn from all eras. Lots of sight reading; low key performance. Very fun!"
)
link_elective_to_instruments(e, [6,7,8,9,10,11,12,14,15,16,22,23,24,25,27,28,31,32])

e = Elective.create(
:name => "Brass Ensemble",
:instructor => "William Berry",
:description => "Open to all brass. Uses standard, modern instruments. So if you have non-standard non-modern instruments, leave them in your dorm room!"
)
link_elective_to_instruments(e, [22,23,24,25,26,27])

e = Elective.create(
:name => "Jazz Big Band",
:instructor => "Greg Yasinitsky",
:description => "The Jazz Big Band features traditional big band instrumentation: saxophones, trumpets, trombones and rhythm section players -- piano, bass and drums. Repertoire is drawn from a mix of unique arrangements of  jazz standards and originals. The band performs at Skit Night."
)
link_elective_to_instruments(e, [17,18,19,20,21,22,24,25,28,31,34])

e = Elective.create(
:name => "Jazz Improvisation",
:instructor => "Greg Yasinitsky",
:description => "Open to instrumentalists and vocalists, this class will cover the basics of improvising: chord progressions, what scales to use with what chords, articulation styles, and how to develop a melody."
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Saxophone Ensemble", 
:instructor => "Patrick Sheng",
:description => "An ensemble.  Of saxophones. You will all think you are the coolest musicians at MMR!  And who's to say you are wrong about that?"
)
link_elective_to_instruments(e, [17,18,19,20,21])

e = Elective.create(
:name => "Fiddling",
:instructor => "Carol Ann Wheeler",
:description => "Delve into fiddle styles and techniques with a master fiddler."
)
link_elective_to_instruments(e, [6,7])

e = Elective.create(
:name => "Solo Bach For The String Player",
:instructor => "Meg Brennand",
:description => "Now offered for all strings!  Explore the mystical world of solo Bach. Get the insider's perspective on tempi, articulation, and style that Bach would have expected any accomplished 18th century string player to know. Master class format (performance optional). Prepare a movement to perform from the Bach cello suites, the violin sonatas or partitas; or simply come and observe."
)
link_elective_to_instruments(e, [6,7,8,9])

e = Elective.create(
:name => "Eurythmics",
:instructor => "Deede Cook",
:description => "Develop your musical understanding with a dip into the system of rhythmical physical movements created by Emile Jaques-Dalcroze."
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Building A Vocal Community",
:instructor => "Margaret Green",
:description => "Participants in this elective will create a community through our singing together. All music will be taught in call and response style (up to four parts) and will include music from African, spiritual, and gospel vocal traditions. Participants may also experiment with playing djembe and other percussion that enhances the singing. No prior singing experience is necessary."
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Opera Choruses for Women",
:instructor => "Adam Burdick",
:description => "Explore choruses for women's voices from great English and Italian operas in a supportive, creative learning environment. Learn the stories behind the choruses and their place in each production. Good sight-reading skills required."
)
link_elective_to_instruments(e, [1,2])

e = Elective.create(
:name => "Just for Mens\' Voices",
:instructor => "Jason Anderson",
:description => "Breath, imagination, text/meaning, and body/mind will help guide participants in this vocal elective as we explore music from chant to music of the 21st century. Prior singing experience and a working knowledge of music fundamentals is recommended."
)
link_elective_to_instruments(e, [3,4,5])

e = Elective.create(
:name => "Just for Womens\' Voices",
:instructor => "Lisa Cardwell Ponten",
:description => "Breath, imagination, text/meaning, and body/mind will help guide participants in this vocal elective as we explore music from chant to music of the 21st century. Prior singing experience and a working knowledge of music fundamentals is recommended."
)
link_elective_to_instruments(e, [1,2])

e = Elective.create(
:name => "Music Fundamentals for Singers",
:instructor => "Loren Ponten",
:description => "Sing in a choir and want to hone your music reading skills? Study with the proven Kodaly Method. Through this introductory workshop, you will develop your musical thinking, and inner hearing through direct experience with the elements of music."
)
link_elective_to_instruments(e, [1,2,3,4,5])

e = Elective.create(
:name => "Solfege is Fun!",
:instructor => "Katie Weld",
:description => "Connect solfege to part song singing, mix in some music theory, some more singing, a bit more theory, and much more singing. In this elective you will learn to turn your DO RE MIs into music and perform some good ol' madrigals and/or part songs along the way."
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Opera Workshop",
:instructor => "Charles Robert Stephens",
:description => "Participants will explore short scenes from selected operas, hone stage presence skills, and learn to work both as a soloist and ensemble cast member. Ability to sing in German, Italian, and/or French required; previous stage experience recommended."
)
link_elective_to_instruments(e, [1,2,3,4,5])

e = Elective.create(
:name => "Rock Orchestra for Strings",
:instructor => "Adam Burdick",
:description => "String ensembles have backed up pop and rock songs in a wide span of styles ranging from the swooning strings of nearly any later Roy Orbison song, to the clarity of the quartet in the Beatles\' \"Eleanor Rigby.\" Come re-create some favorites!"
)
link_elective_to_instruments(e, [6,7,8,9])

e = Elective.create(
:name => "And the Beat Goes On... ",
:instructor => "Michael Burch-Pesses",
:description => "Before Melody and Harmony came Rhythm. Immerse yourself in the  fundamental tool of the singer or instrumentalist."
)
link_elective_to_instruments(e, [])

e = Elective.create(
:name => "Clarinet Choir",
:instructor => "Faculty",
:description => "A Choir!  Of Clarinets!! What could be more heavenly than that? I mean let's face it, clarinet is the Rodney Dangerfield of woodwinds.  It gets no respect.  But it should -- it should get lots of respect!! And if you join the Clarinet Choir, you can help prove everybody wrong and stop all those nasty and false things they are saying about clarinets.  So in some sense it is your moral duty to sign up for Clarinet Choir.  Whether or not you are a clarinet player."
)
link_elective_to_instruments(e, [15,16,37])

