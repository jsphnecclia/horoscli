#!/usr/bin/env ruby
require_relative 'lib/ruephbase.rb'
require_relative 'lib/rueph.rb'
require_relative 'lib/horoscli.rb'
require 'time'
require 'csv'
require 'chronic'
require 'geocoder'
require 'optparse'
require 'optparse/time'

SIGNS_EXP = { aries: "",
              taurus: "",
              gemini: "",
              cancer: "",
              leo: "",
              virgo: "",
              libra: "",
              scorpio: "",
              sagittarius: "",
              capricorn: "",
              aquarius: "",
              pisces: "" }

PLANETS_EXP = { sun: "",
                moon: "",
                mercury: "",
                venus: "",
                mars: "",
                jupiter: "",
                saturn: "",
                uranus: "",
                neptune: "",
                pluto: ""}

LUNAR_SIGNS_EXP = { aries: "",
                    taurus: "",
                    gemini: "",
                    cancer: "",
                    leo: "",
                    virgo: "",
                    libra: "",
                    scorpio: "",
                    sagittarius: "",
                    capricorn: "",
                    aquarius: "",
                    pisces: "" }

LUNAR_ASPECTS_EXP = { conjunct_sun: "",
                      sextile_sun: "",
                      trine_sun: "",
                      square_sun: "",
                      opposite_sun: "",
                      conjunct_mercury: "",
                      sextile_mercury: "",
                      trine_mercury: "",
                      square_mercury: "",
                      opposite_mercury: "",
                      conjunct_venus: "",
                      sextile_venus: "",
                      trine_venus: "",
                      square_venus: "",
                      opposite_venus: "",
                      conjunct_mars: "",
                      sextile_mars: "",
                      trine_mars: "",
                      square_mars: "",
                      opposite_mars: "",
                      conjunct_jupiter: "",
                      sextile_jupiter: "",
                      trine_jupiter: "",
                      square_jupiter: "",
                      opposite_jupiter: "",
                      conjunct_saturn: "",
                      sextile_saturn: "",
                      trine_saturn: "",
                      square_saturn: "",
                      opposite_saturn: "",
                      conjunct_uranus: "",
                      sextile_uranus: "",
                      trine_uranus: "",
                      square_uranus: "",
                      opposite_uranus: "",
                      conjunct_neptune: "",
                      sextile_neptune: "",
                      trine_neptune: "",
                      square_neptune: "",
                      opposite_neptune: "",
                      conjunct_pluto: "",
                      sextile_pluto: "",
                      trine_pluto: "",
                      square_pluto: "",
                      opposite_pluto: ""}

RETROGRADES_EXP = { sun: "",
                    moon: "",
                    mercury: "",
                    venus: "",
                    mars: "",
                    jupiter: "",
                    saturn: "",
                    uranus: "",
                    neptune: "",
                    pluto: ""}


exp = CSV.parse(File.read("astrologize.csv"), headers: true)
puts exp[1][0] + "\t" + exp[1][1]
puts exp[1][2]


ARGV << '-h' if ARGV.empty?

options = {}

OptionParser.new do |parser|
  parser.on("-g", "--general", "Print general instantaneous information then exit.") do 
    options[:general] = true
  end

  parser.on("-d", "--date DATETIME", "Perform calculations for a certain date, e.g. 2020-10-23 14:00. Natural Language Supported") do |date|
    options[:date] = Chronic.parse(date)
  end

  parser.on("-l", "--location LOCATION", "Perform calculations for a certain location") do |loc|
    options[:loc] = Geocoder.search(loc)
  end

  parser.on("-n", "--natal [NATAL]", "Calculate a basic natal chart") do |natal|
    options[:natal] = true
    options[:natal_type] = natal.upcase unless natal.nil?
  end

  parser.on("-b", "--bar OPTION", "Prints in bar # format") do |bar|
    options[:bar] = bar
  end

  parser.on("-r", "--retrograde [PLANET]", "Is PLANET in retrograde?") do |planet|
    options[:retrograde] = true
    options[:planet] = planet.upcase if planet
  end

  parser.on("-s", "--sign-of [PLANET]", "What sign is PLANET in?") do |planet|
    options[:sign_of] = true
    options[:planet] = planet.upcase if planet
  end

  parser.on("--degree-of [PLANET]", "What degree of sign is PLANET in?") do |planet|
    options[:sign_of_degree] = true
    options[:planet] = planet.upcase if planet
  end

  parser.on("-h", "--help [TOPIC]", "General help or information on a particular topic.") do |topic|
    unless topic
      puts <<~DOC

      Horoscli is a general astrological tool. It can take arguments
      and return information specific to your time and location. It can
      also output general information to help decipher the meaning in the
      astrological placement of the moon and the angles the moon makes
      with the other planets. There are other tools as well.
      
      DOC
      puts parser
      exit
    end

    options[:help_topic] = topic.upcase
    puts options[:help_topic]
  end
end.parse!


time = options[:date]? options[:date] : Time.now
puts time
puts

horos = Horoscli.new(time)

if options[:natal]
  if !options[:loc]
    puts "Location required for natal chart"
    horos.close
    return
  end
  horos.location = options[:loc].first.coordinates[0], options[:loc].first.coordinates[1]
  horos.set_topo(horos.location[0], horos.location[1], 0)
  horos.flags += Rueph::FLG_TOPOCTR

  puts horos.location

  if options[:natal_type] == "PLANET-SIGNS" or options[:natal_type] == nil
    planet_signs = {}
  
    Rueph::PLANETS.each_with_index do |planet, index|
      planet_signs[planet] = Rueph::deg_to_sign(horos.calc(index)[0])
    end
  
    puts "#{horos.ascendant} ASCENDANT"

    planet_signs.each do |planet, sign|
      puts "#{planet} in #{sign}"
    end
    
    horos.close
    return
  elsif options[:natal_type] == "CUSPS"
    horos.houses[0].each_with_index do |deg, index|
      puts "#{index}th House #{Rueph::deg_to_sign(deg)}" unless index == 0
    end

    horos.close
    return
  elsif options[:natal_type] == "PLANET-HOUSES"
    planet_houses = {}
  
    Rueph::PLANETS.each_with_index do |planet, index|
      planet_houses[planet] = horos.house_pos(index)
    end
  
    planet_houses.each do |planet, house|
      puts "#{planet} in the #{house.floor}th House"
    end
    horos.close
    return

  else
    puts "Natal option type not recognized. Recognized arguements are planet-signs, cusps, and planet-houses"
  end

  #TODO is this ever reached
  horos.close
  return
end

if (options[:retrograde] && options[:planet])
  planet_index = Rueph::PLANETS.index("#{options[:planet]}")
  if horos.retrograde?(planet_index)
    puts "#{options[:planet]} is in Retrograde"
  else
    puts "#{options[:planet]} is in Direct Motion"
  end
  horos.close
  return
elsif options[:retrograde]
    Rueph::PLANETS.each_with_index do |planet, index|
    puts "#{planet} is in Retrograde" if horos.retrograde?(index)
  end
  horos.close
  return
end

if (options[:sign_of] && options[:planet])
  planet_index = Rueph::PLANETS.index("#{options[:planet]}")
  ret_sign = horos.sign_of(planet_index)
  horos.close
  puts "#{options[:planet]} is in #{ret_sign}"
  return
elsif options[:sign_of]
  Rueph::PLANETS.each_with_index do |planet, index|
    puts "#{planet} is in #{Rueph::sign_of(index)}"
  end
  horos.close
  return
end


if (options[:sign_of_degree] && options[:planet])
  planet_index = Rueph::PLANETS.index("#{options[:planet]}")
  ret_sign_deg = horos.sign_of_degree(planet_index)
  horos.close
  puts "#{options[:planet]} is at #{ret_sign_deg[1]} degrees #{ret_sign_deg[0]}"
  return
elsif options[:sign_of_degree]
  Rueph::PLANETS.each_with_index do |planet, index|
    ret_sign_deg = horos.sign_of_degree(index)
    puts "#{planet} is at \t#{ret_sign_deg[1]} degrees #{ret_sign_deg[0]}"
  end
  horos.close
  return
elsif options[:bar]
  if options[:bar] == "1"
    # sun and moon sign, with void of course
    moon_aspects = horos.daily_aspects
    puts "#{horos.sign_of(Rueph::SUN)}::#{horos.moon_void_instantaneous}"
  elsif options[:bar] == "2"
    # sun and moon sign, no void of course
    puts "#{horos.sign_of(Rueph::SUN)}::#{horos.sign_of(Horoscli::MOON)}"
  elsif options[:bar] == "3"
    # Lunar Transit for the day
    horos.print_lunar_transit
  elsif options[:bar] == "4"
    horos.print_lunar_instant
  end
  horos.close
  return
elsif options[:general]
  # Prints Sign of Sun
  puts "SUN in #{horos.sign_of(Rueph::SUN)}"

  # Prints Sign of Moon
  horos.print_lunar_instant
  puts

  # Prints Aspects of the Moon
  puts "Daily Lunar Aspects"
  horos.print_lunar_aspects
  puts 

  # Prints last aspect before vc moon
  puts "Last Aspect Before Void of Course Moon"
  puts horos.print_last_aspect_before_void 
  puts

  # Prints Course of Moon through the Day
  puts "Lunar Transit"
  horos.print_lunar_transit
  puts
end

horos.close
