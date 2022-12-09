#!/usr/bin/env ruby

# This file is part of horoscli.
#
# Copyright (c) 2022 Parker McGowan
# 
# Horoscli is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Horoscli is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License
# along with horoscli.  If not, see <https://www.gnu.org/licenses/>.

require_relative 'lib/ruephbase.rb'
require_relative 'lib/rueph.rb'
require_relative 'lib/horoscli.rb'
require 'time'
require 'csv'
require 'chronic'
require 'geocoder'
require 'optparse'
require 'optparse/time'

# SIGNS_EXP = { aries: "",
#               taurus: "",
#               gemini: "",
#               cancer: "",
#               leo: "",
#               virgo: "",
#               libra: "",
#               scorpio: "",
#               sagittarius: "",
#               capricorn: "",
#               aquarius: "",
#               pisces: "" }
#
# PLANETS_EXP = { sun: "",
#                 moon: "",
#                 mercury: "",
#                 venus: "",
#                 mars: "",
#                 jupiter: "",
#                 saturn: "",
#                 uranus: "",
#                 neptune: "",
#                 pluto: ""}
#
# LUNAR_SIGNS_EXP = { aries: "",
#                     taurus: "",
#                     gemini: "",
#                     cancer: "",
#                     leo: "",
#                     virgo: "",
#                     libra: "",
#                     scorpio: "",
#                     sagittarius: "",
#                     capricorn: "",
#                     aquarius: "",
#                     pisces: "" }
#
# LUNAR_ASPECTS_EXP = { conjunct_sun: "",
#                       sextile_sun: "",
#                       trine_sun: "",
#                       square_sun: "",
#                       opposite_sun: "",
#                       conjunct_mercury: "",
#                       sextile_mercury: "",
#                       trine_mercury: "",
#                       square_mercury: "",
#                       opposite_mercury: "",
#                       conjunct_venus: "",
#                       sextile_venus: "",
#                       trine_venus: "",
#                       square_venus: "",
#                       opposite_venus: "",
#                       conjunct_mars: "",
#                       sextile_mars: "",
#                       trine_mars: "",
#                       square_mars: "",
#                       opposite_mars: "",
#                       conjunct_jupiter: "",
#                       sextile_jupiter: "",
#                       trine_jupiter: "",
#                       square_jupiter: "",
#                       opposite_jupiter: "",
#                       conjunct_saturn: "",
#                       sextile_saturn: "",
#                       trine_saturn: "",
#                       square_saturn: "",
#                       opposite_saturn: "",
#                       conjunct_uranus: "",
#                       sextile_uranus: "",
#                       trine_uranus: "",
#                       square_uranus: "",
#                       opposite_uranus: "",
#                       conjunct_neptune: "",
#                       sextile_neptune: "",
#                       trine_neptune: "",
#                       square_neptune: "",
#                       opposite_neptune: "",
#                       conjunct_pluto: "",
#                       sextile_pluto: "",
#                       trine_pluto: "",
#                       square_pluto: "",
#                       opposite_pluto: ""}
#
# RETROGRADES_EXP = { sun: "",
#                     moon: "",
#                     mercury: "",
#                     venus: "",
#                     mars: "",
#                     jupiter: "",
#                     saturn: "",
#                     uranus: "",
#                     neptune: "",
#                     pluto: ""}
#


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
      
      Help topic can be a sign, e.g. 'GEMINI', which will tell you what it means
      for the moon to be in that sign or a planet, e.g. 'MERCURY', which will 
      describe the meaning of aspects that can be formed from the angle between 
      the moon and that planet. The topic can also be 'VOID', for a definition 
      of Void of Course Moon.

      DOC
      puts parser
      exit
    end

    options[:help_topic] = topic.upcase
  end
end.parse!


time = options[:date]? options[:date] : Time.now
unless options[:help_topic] or options[:bar]
  puts time
end

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
    # sun and moon sign, no void of course
    puts "#{horos.sign_of(Rueph::SUN)}::#{horos.sign_of(Horoscli::MOON)}"
  elsif options[:bar] == "2"
    # Instantaneous Sign of the Moon (With Void of Course)
    horos.print_lunar_instant
  elsif options[:bar] == "3"
    # Instantaneous Sign of the Moon (No Void of Course)
    puts "#{horos.sign_of(Horoscli::MOON)}"
  elsif options[:bar] == "4"
    # Lunar Transit for the day
    horos.print_lunar_transit
  end
  horos.close
  return
elsif options[:general]
  # Prints Sign of Sun
  puts "SUN in #{horos.sign_of(Rueph::SUN)}"

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
elsif options[:help_topic]
    # Astrological Explanations CSV File
    #
    # exp[0-5]    definitions
    # exp[6-17]   moon in signs
    # exp[18-57]  lunar aspects
    exp = CSV.parse(File.read("astrologize.csv"), headers: true)
    
    topic = options[:help_topic].upcase

    case topic
    when "BAR"
      puts <<~DOC

      The bar (-b) option provides minimal information, mainly for use in a bar
      or other output script.

      Option 1: Shows the SUN and MOON sign in the format <SUN>::<MOON>.
      Option 2: Shows the instantaneous sign of the moon, with Void of Course.
      Option 3: Shows the instantaneous sign of the moon, ignoring Void of Course.
      Option 4: Shows the lunar transit times for the day.

      DOC
    # VOID
    when "VOID"
      puts exp[0][0]
      puts exp[0][2]
    # MOON SIGNS  
    when "ARIES"
      puts exp[6][0]
      puts exp[6][2]
    when "TAURUS"
      puts exp[7][0]
      puts exp[7][2]
    when "GEMINI"
      puts exp[8][0]
      puts exp[8][2]
    when "CANCER"
      puts exp[9][0]
      puts exp[9][2]
    when "LEO"
      puts exp[10][0]
      puts exp[10][2]
    when "VIRGO"
      puts exp[11][0]
      puts exp[11][2]
    when "LIBRA"
      puts exp[12][0]
      puts exp[12][2]
    when "SCORPIO"
      puts exp[13][0]
      puts exp[13][2]
    when "SAGITTARIUS"
      puts exp[14][0]
      puts exp[14][2]
    when "CAPRICORN"
      puts exp[15][0]
      puts exp[15][2]
    when "AQUARIUS"
      puts exp[16][0]
      puts exp[16][2]
    when "PISCES"
      puts exp[17][0]
      puts exp[17][2]
    # ASPECTS
    when "MERCURY"
      # CONJUNCT
      puts exp[18][0] 
      puts exp[18][2]

      # SQUARE
      puts 
      puts exp[26][0]
      puts exp[26][2]

      # OPPOSITE
      puts
      puts exp[34][0]
      puts exp[34][2]

      # SEXTILE
      puts
      puts exp[42][0]
      puts exp[42][2]

      # TRINE
      puts
      puts exp[50][0]
      puts exp[50][2]

    when "VENUS"
      puts exp[19][0] 
      puts exp[19][2]

      puts 
      puts exp[27][0]
      puts exp[27][2]

      puts
      puts exp[35][0]
      puts exp[35][2]

      puts
      puts exp[43][0]
      puts exp[43][2]

      puts
      puts exp[51][0]
      puts exp[51][2]

    when "MARS"
      puts exp[20][0] 
      puts exp[20][2]

      puts 
      puts exp[28][0]
      puts exp[28][2]

      puts
      puts exp[36][0]
      puts exp[36][2]

      puts
      puts exp[44][0]
      puts exp[44][2]

      puts
      puts exp[52][0]
      puts exp[52][2]

    when "JUPITER"
      puts exp[21][0] 
      puts exp[21][2]

      puts 
      puts exp[29][0]
      puts exp[29][2]

      puts
      puts exp[37][0]
      puts exp[37][2]

      puts
      puts exp[45][0]
      puts exp[45][2]

      puts
      puts exp[53][0]
      puts exp[53][2]

    when "SATURN"
      puts exp[22][0] 
      puts exp[22][2]

      puts 
      puts exp[30][0]
      puts exp[30][2]

      puts
      puts exp[38][0]
      puts exp[38][2]

      puts
      puts exp[46][0]
      puts exp[46][2]

      puts
      puts exp[54][0]
      puts exp[54][2]

    when "URANUS"
      puts exp[23][0] 
      puts exp[23][2]

      puts 
      puts exp[31][0]
      puts exp[31][2]

      puts
      puts exp[39][0]
      puts exp[39][2]

      puts
      puts exp[47][0]
      puts exp[47][2]

      puts
      puts exp[55][0]
      puts exp[55][2]

    when "NEPTUNE"
      puts exp[24][0] 
      puts exp[24][2]

      puts 
      puts exp[32][0]
      puts exp[32][2]

      puts
      puts exp[40][0]
      puts exp[40][2]

      puts
      puts exp[48][0]
      puts exp[48][2]

      puts
      puts exp[56][0]
      puts exp[56][2]

    when "PLUTO"
      puts exp[25][0] 
      puts exp[25][2]

      puts 
      puts exp[33][0]
      puts exp[33][2]

      puts
      puts exp[41][0]
      puts exp[41][2]

      puts
      puts exp[49][0]
      puts exp[49][2]

      puts
      puts exp[57][0]
      puts exp[57][2]

    else
      puts "Not a valid help topic."
    end
    horos.close
    return
end
horos.close
