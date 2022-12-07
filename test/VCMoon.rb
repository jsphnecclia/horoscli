require 'minitest/autorun'
require_relative '../lib/Horoscli.rb'
require 'time'

class HoroscliTest < Minitest::Test
  
  Rueph::set_ephe_path 'lib/ephe'

  ## Multitudinous V/C tests
  # test_void_YEAR_MONTH_DAY
  # (eg January 2 2021: test_void_2021_01_02)
  #
  # tests hour before, during, and hour after
  # as well as last aspect before void of course
  # (#TODO maybe make it 30 mins before and after)
  #
  # Tests are (for now) only in Eastern Time (-5)
  # (This is because of the void of course lists I've found)
  #
  #TODO take into account daylight savings time
  #TODO find a way of checking the last aspect

  # def teardown
  #   horos_before.close
  #   horos_mid.close
  #   horos_after.close
  # end

  def test_2020_12_17
    horos_before = Horoscli.new(Time.parse("2020-12-17 00:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2020-12-17 01:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2020-12-17 1:30 -0500"))

    #TODO Fails. Fixed with a very hacky line in last_aspect_before_void and daily_lunar_transit
    #
    #     When finding a final solution, remember that the code works 
    #     correctly for timezone offsets divisible by 3
    assert horos_before.print_last_aspect_before_void  == "MOON Conjunction JUPITER"
    assert horos_after.print_last_aspect_before_void  == "MOON Conjunction JUPITER"

    assert horos_before.lunar_instant == "CAPRICORN"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "AQUARIUS"
  end

  def test_2020_11_20
    horos_before = Horoscli.new(Time.parse("2020-11-20 19:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2020-11-21 12:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2020-11-21 23:30 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Sextile MARS"
    #TODO: Fails
    assert horos_after.print_last_aspect_before_void  == "MOON Sextile MARS"

    assert horos_before.lunar_instant == "AQUARIUS"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "PISCES"
  end

  def test_2021_08_20
    horos_before = Horoscli.new(Time.parse("2021-08-19 18:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-08-19 23:30 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-08-20 06:30 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Conjunction PLUTO"
    #TODO: Fails
    assert horos_after.print_last_aspect_before_void  == "MOON Conjunction PLUTO"

    assert horos_before.lunar_instant == "CAPRICORN"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "AQUARIUS"
  end
    

  def test_2021_01_02
    horos_before = Horoscli.new(Time.parse("2021-01-02 16:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-02 18:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-02 21:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Trine MARS"
    assert horos_after.print_last_aspect_before_void  == "MOON Trine MARS"

    assert horos_before.lunar_instant == "LEO"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "VIRGO"
  end
    
  def test_2021_01_04
    horos_before = Horoscli.new(Time.parse("2021-01-04 16:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-04 19:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-05 01:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Square VENUS"
    #TODO: Fails
    assert horos_after.print_last_aspect_before_void  == "MOON Square VENUS"

    assert horos_before.lunar_instant == "VIRGO"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "LIBRA"
  end


  def test_2021_01_07
    horos_before = Horoscli.new(Time.parse("2021-01-07 00:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-07 02:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-07 05:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Sextile VENUS"
    assert horos_after.print_last_aspect_before_void  == "MOON Sextile VENUS"

    assert horos_before.lunar_instant == "LIBRA"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "SCORPIO"
  end

  def test_2021_01_08
    horos_before = Horoscli.new(Time.parse("2021-01-08 19:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-08 23:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-09 07:30 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Sextile PLUTO"
    #TODO: Fails
    assert horos_after.print_last_aspect_before_void  == "MOON Sextile PLUTO"

    assert horos_before.lunar_instant == "SCORPIO"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "SAGITTARIUS"
  end

  def test_2021_01_10
    horos_before = Horoscli.new(Time.parse("2021-01-10 12:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-10 23:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-11 09:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Square NEPTUNE"
    assert horos_after.print_last_aspect_before_void  == "MOON Square NEPTUNE"

    assert horos_before.lunar_instant == "SAGITTARIUS"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "CAPRICORN"
  end

  def test_2021_01_13
    horos_before = Horoscli.new(Time.parse("2021-01-13 00:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-13 05:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-13 12:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Conjunction PLUTO"
    assert horos_after.print_last_aspect_before_void  == "MOON Conjunction PLUTO"

    assert horos_before.lunar_instant == "CAPRICORN"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "AQUARIUS"
  end

  def test_2021_01_14
    horos_before = Horoscli.new(Time.parse("2021-01-14 03:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-14 20:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-15 18:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Conjunction MERCURY"
    assert horos_after.print_last_aspect_before_void  == "MOON Conjunction MERCURY"

    assert horos_before.lunar_instant == "AQUARIUS"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "PISCES"
  end

  def test_2021_01_17
    horos_before = Horoscli.new(Time.parse("2021-01-17 20:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-17 23:30 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-18 03:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Sextile SUN"
    assert horos_after.print_last_aspect_before_void  == "MOON Sextile SUN"

    assert horos_before.lunar_instant == "PISCES"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "ARIES"
  end

  def test_2021_01_20
    horos_before = Horoscli.new(Time.parse("2021-01-20 00:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-20 10:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-20 14:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Square PLUTO"
    assert horos_after.print_last_aspect_before_void  == "MOON Square PLUTO"

    assert horos_before.lunar_instant == "ARIES"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "TAURUS"
  end

  def test_2021_01_22
    horos_before = Horoscli.new(Time.parse("2021-01-22 12:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-22 22:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-23 03:30 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Trine PLUTO"
    assert horos_after.print_last_aspect_before_void  == "MOON Trine PLUTO"

    assert horos_before.lunar_instant == "TAURUS"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "GEMINI"
  end

  def test_2021_01_25
    horos_before = Horoscli.new(Time.parse("2021-01-25 00:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-25 09:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-25 15:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Trine MERCURY"
    assert horos_after.print_last_aspect_before_void  == "MOON Trine MERCURY"

    assert horos_before.lunar_instant == "GEMINI"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "CANCER"
  end

  def test_2021_01_27
    horos_before = Horoscli.new(Time.parse("2021-01-27 10:00 -0500"))
    horos_mid = Horoscli.new(Time.parse("2021-01-27 19:00 -0500"))
    horos_after = Horoscli.new(Time.parse("2021-01-27 23:00 -0500"))

    assert horos_before.print_last_aspect_before_void  == "MOON Opposition PLUTO"
    assert horos_after.print_last_aspect_before_void  == "MOON Opposition PLUTO"

    assert horos_before.lunar_instant == "CANCER"
    assert horos_mid.lunar_instant    == "V/C"
    assert horos_after.lunar_instant  == "LEO"
  end
=begin
=end
end
