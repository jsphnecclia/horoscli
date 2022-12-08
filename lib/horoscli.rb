#require 'rueph'
require_relative 'rueph.rb'

class Horoscli
  include Rueph

  attr_accessor :time, :tz_offset, :location, :ephe_path, :flags, :hsystem
  # Lazily defined attributes are:
  #   self.lunar_aspects
  #   self.lunar_transit
  #   self.house_cusps

  def initialize(time = Time.now, tz_offset: time.utc_offset/(60*60), flags: Rueph::FLG_SWIEPH + Rueph::FLG_SPEED, ephe_path: 'ephe', hsystem: 'P')
    Rueph::set_ephe_path ephe_path

    @time = [time.year, time.month, time.day, time.hour + (time.min/60.0)]
    @tz_offset = tz_offset

    @flags = flags

    @location = nil

    @hsystem = hsystem.ord

    # Lazy attributes
    @lunar_aspects = nil
    @lunar_transit = nil
    @houses_cusps  = nil
  end

  # Lazy-Loading
  def initialize_houses
    @house_cusps = houses
  end

  def house_cusps
    @house_cusps ||= initialize_houses
  end

  def initialize_lunar_aspects
    @lunar_aspects = daily_aspects
  end

  def lunar_aspects
    @lunar_aspects ||= initialize_lunar_aspects
  end

  def initialize_lunar_transit
    @lunar_transit = daily_lunar_transit
  end

  def lunar_transit
    @lunar_transit ||= initialize_lunar_transit
  end

  # Functions from Rueph

  def calc(planet)
    super(planet, @time, flags: @flags)
  end

  def retrograde?(planet)
    super(planet, @time)
  end

  def sign_of(planet)
    super(planet, @time)
  end

  def sign_of_degree(planet)
    super(planet, @time)
  end

  def houses
    super(@location[0], @location[1], Rueph::off_set_time_array(@time.dup, @tz_offset), @hsystem)
  end

  def house_pos(planet)
    super(planet, @location[0], @location[1], self.house_cusps[0], self.house_cusps[1], Rueph::off_set_time_array(@time.dup, @tz_offset))
  end

  # end Rueph functions

  def ascendant
    Rueph::deg_to_sign self.house_cusps[1][0]
  end

  def voidless_lunar_transit(time = @time)
    start_array = time.clone
    end_array = start_array.clone
    start_array[3] = 0
    end_array[3] = 24

    # TODO: Might be related to 2020-12-16 bug
    start_array = Rueph::off_set_time_array(start_array, @tz_offset)
    end_array = Rueph::off_set_time_array(end_array, @tz_offset)

    lres = Rueph::calc(Rueph::MOON, start_array)
    rres = Rueph::calc(Rueph::MOON, end_array)

    if Rueph::deg_to_sign(lres[0]) == Rueph::deg_to_sign(rres[0])
      return [false, Rueph::deg_to_sign(lres[0])]
    else
      left_array = start_array.clone
      right_array = end_array.clone
      mid_array = start_array.clone
      mid_array[3] += 12.0
      i = 6.0
      while (i > 3.0/128.0) do
        mres = Rueph::calc(Rueph::MOON, mid_array)

        if Rueph::deg_to_sign(mres[0]) == Rueph::deg_to_sign(lres[0])
          left_array = mid_array.clone
          mid_array[3] = mid_array[3] + i
        else
          right_array = mid_array.clone
          mid_array[3] = mid_array[3] - i
        end
      
        i = i/2.0
      end 
      return_array = Rueph::reset_time_array(mid_array, @tz_offset)
      return [return_array, Rueph::deg_to_sign(lres[0]), Rueph::deg_to_sign(rres[0])]
    end
  end

  def planet_aspect_with(planet1, planet2, time = @time)
    planet1_pos = Rueph::calc(planet1, time)
    planet2_pos = Rueph::calc(planet2, time)

    difference = (planet1_pos[0] - planet2_pos[0]).abs

    if (difference <= 0.01 or difference >= 359.99)
      return "Conjunction"
    elsif ((difference >= 59.99 and difference <= 60.01) or (difference >= 299.99 and difference <= 300.01))
      return "Sextile"
    elsif ((difference >= 89.99 and difference <= 90.01) or (difference >= 269.99 and difference <= 270.01))
      return "Square"
    elsif ((difference >= 119.99 and difference <= 120.01) or (difference >= 239.99 and difference <= 240.01))
      return "Trine"
    elsif (difference >= 179.99 and difference <= 180.01)
      return "Opposition"
    else
      return "No Aspect"
    end
  end

  def daily_aspects(planet = Rueph::MOON, time = @time)
    planet_aspects = {}
    starts_with = time.clone

    starts_with[3] = 0.0

    starts_with = Rueph::off_set_time_array(starts_with, @tz_offset)

    Rueph::PLANETS.each_index do |index|
      cur_time = starts_with.clone
      cur_aspect = "No Aspect"
      prev_aspect = "No Aspect"

      if planet != index
        while (cur_time[3] < (24.0 + starts_with[3])) do 
          cur_aspect = planet_aspect_with(planet, index, cur_time)
          if ((cur_aspect != prev_aspect) && (prev_aspect == "No Aspect"))
            aspect_time_TZ = Rueph::reset_time_array(cur_time.clone, @tz_offset)
            planet_aspects[index] = [cur_aspect, aspect_time_TZ]
          end
          cur_time[3] += (1.0/240.0)
          prev_aspect = cur_aspect
        end
      end
    end

    planet_aspects.sort_by {|key, val| val[1][3]}
  end

  def print_lunar_aspects()
    self.lunar_aspects.each do |key, val|
      puts "MOON #{val[0]} #{Rueph::PLANETS[key]} " \
           "#{Time.at(val[1][3]*3600).utc.strftime("%H:%M")}"
    end
  end

  def daily_lunar_transit
    cur_date = @time.clone

    moon_transit = voidless_lunar_transit
    # TODO: comment about how the time offset doesnt matter here because all
    #       the time functions used work daily, not for any instant

    cur_date = Rueph::off_set_time_array(cur_date, @tz_offset)
    lunar_aspects = self.lunar_aspects.reverse 

    yesterday = @time.clone
    yesterday[2] -= 1

    tomorrow_date = cur_date.clone
    tomorrow_date[2] += 1
    moon_transit_tomorrow = voidless_lunar_transit(tomorrow_date.clone)

    two_days_date = tomorrow_date.clone
    two_days_date[2] += 1
    moon_transit_two_days = voidless_lunar_transit(two_days_date.clone)

    if (moon_transit[0])
      lunar_aspects.each do |planet, aspect|
        # TODO: Dec 16 2020 bug. if the timezone offset is divisible by three
        #       then the time of lunar transit falls before the SATURN Conjunction.
        #       Otherwise, the time of lunar transit falls afterwards.
        # 
        #       Hacky solution below, simply dismisses any last aspects about
        #       2 and a half minutes from before the actual transit.
        #
        #       replace with this line if a better solution is found:
        #         if (aspect[1][3] < moon_transit[0][3])
        if (aspect[1][3] < moon_transit[0][3] and (moon_transit[0][3] - aspect[1][3]).abs > 0.04)
          return [1, aspect[1][3], moon_transit[0][3], moon_transit, [planet, aspect]] 
        end
      end
      #TODO: Find out if the following line is ever used
      #return [2, moon_transit[0][3], moon_transit, lunar_aspects.last] unless lunar_aspects.empty?
      return [2, moon_transit[0][3], moon_transit, daily_aspects(Rueph::MOON, yesterday).last]
    else

      tomorrow_moon_aspects = daily_aspects(Rueph::MOON, tomorrow_date).reverse

      if (moon_transit_tomorrow[0]) 
        tomorrow_moon_aspects.each do |planet, aspect|
          if (aspect[1][3] <= moon_transit_tomorrow[0][3])
            return [0, Rueph::calc(Rueph::MOON, cur_date)[0], nil]
          end
        end
        unless lunar_aspects.empty?
          return [3, lunar_aspects[0][1][1][3], moon_transit_tomorrow, lunar_aspects[0]]
        else
          puts "ERROR 006: Not sure what causes this"
          return [4]
        end
      else

        two_days_moon_aspects = daily_aspects(Rueph::MOON, two_days_date).reverse

        if (moon_transit_two_days[0])
          two_days_moon_aspects.each do |planet, aspect|
          if (aspect[1][3] <= moon_transit_two_days[0][3])
            return [0, Rueph::calc(Rueph::MOON, cur_date)[0], nil]
          end
        end
        unless tomorrow_moon_aspects.empty?
          return [0, Rueph::calc(Rueph::MOON, cur_date)[0], nil]
        else
          unless lunar_aspects.empty?
            return [3, lunar_aspects[0][1][1][3], moon_transit_tomorrow, lunar_aspects[0]]
          else
            puts "ERROR 005: Error has occurred, lunar_aspects empty"
            return [0, Rueph::calc(Rueph::MOON, cur_date)[0], nil]
          end
        end
        else
          puts "ERROR 004: second else statement"
          return [0, Rueph::calc(Rueph::MOON, cur_date)[0], nil]
        end
      end
    end
  end

  def print_last_aspect_before_void
    aspect = self.lunar_transit.last
    return "MOON #{aspect[1][0]} #{Rueph::PLANETS[aspect[0]]}" if aspect != nil
    return "N/A"
  end

  def print_lunar_transit
    # if there is a lunar_transit today
    if self.lunar_transit[0] != 0
      # simple lunar transit takes place within day
      if self.lunar_transit[0] == 1
        puts "#{self.lunar_transit[3][1]} --#{Time.at(self.lunar_transit[1]*3600).utc.strftime("%H:%M")}-> V/C --#{Time.at(self.lunar_transit[2]*3600).utc.strftime("%H:%M")}-> #{self.lunar_transit[3][2]}"
      # lunar transit takes place during day, last aspect was day before
      elsif self.lunar_transit[0] == 2
        puts "V/C --#{Time.at(self.lunar_transit[2][0][3]*3600).utc.strftime("%H:%M")}-> #{self.lunar_transit[2][2]}"
      # lunar transit the next day, last aspect during day
      elsif self.lunar_transit[0] == 3
        puts "#{self.lunar_transit[2][1]} --#{Time.at(self.lunar_transit[1]*3600).utc.strftime("%H:%M")}-> V/C "
      # lunar transit the next day, last aspect the previous day
      elsif self.lunar_transit[0] == 4
        puts "lunar_transit[0] == 4"
        puts "V/C"
      end
    else
      # no lunar_transit today
      puts "MOON in #{Rueph::deg_to_sign(self.lunar_transit[1])}"
    end
  end 

  def lunar_instant(time = @time)
    if self.lunar_transit[0] != 0
      if self.lunar_transit[0] == 1
        if time[3] <= self.lunar_transit[1]
          return self.lunar_transit[3][1]
        elsif (time[3] >= self.lunar_transit[1] and time[3] <= self.lunar_transit[2])
          return "V/C"
        elsif time[3] >= self.lunar_transit[2]
          return self.lunar_transit[3][2]
        else
          return "ERROR"
        end
      elsif self.lunar_transit[0] == 2
        if time[3] <= self.lunar_transit[2][0][3]
          return "V/C"
        else
          return self.lunar_transit[2][2]
        end
      elsif self.lunar_transit[0] == 3
        if time[3] <= self.lunar_transit[1]
          return self.lunar_transit[2][1]
        else
          return "V/C"
        end
      elsif self.lunar_transit[0] == 4
        return "V/C"
      end
    else
      return Rueph::deg_to_sign(self.lunar_transit[1])
      #return self.lunar_transit[1]
    end
  end

  # VERBOSE Lunar Instant
  #
  # def print_lunar_instant
  #   if self.lunar_instant == "ERROR"
  #     puts "MOON instantaneous SIGN ERROR"
  #   elsif self.lunar_instant == "V/C"
  #     puts "MOON V/C"
  #   else
  #     puts "MOON in #{self.lunar_instant}"
  #   end
  # end

  def print_lunar_instant
    if self.lunar_instant == "ERROR"
      puts "MOON instantaneous SIGN ERROR"
    elsif self.lunar_instant == "V/C"
      puts "V/C"
    else
      puts "#{self.lunar_instant}"
    end
  end


end
