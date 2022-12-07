require 'minitest/autorun'
require_relative '../lib/Horoscli.rb'
require 'time'

class HoroscliTest < Minitest::Test
  
  Rueph::set_ephe_path 'lib/ephe'

  #      for void times in Eastern (-5)
  #      https://cafeastrology.com/void-of-course-moon-times.html
  #      for aspect times in GMT (0)
  #      https://www.myastrology.net/ast-bin/view_todays_lunar_aspects.cgi?year=2020&month=11&day=20
  #TODO: Daylight Savings Time

  def test_initialize_time
    time = Time.now
    horos = Horoscli.new(time)

    assert horos.time == Rueph::time_to_array(time)
  end

  def test_initialize_offset
    time = Time.now
    offset = Time.now.utc_offset/(60*60)
    horos = Horoscli.new(time, tz_offset: offset)

    assert horos.time == Rueph::time_to_array(time)
    assert horos.tz_offset == offset
  end

  def test_automatic_timezone_offset
    time1 = Time.parse("2020-11-14 02:00 -0600")
    horos1 = Horoscli.new time1

    time2 = Time.parse("2019-10-01 10:00 -0500")
    horos2 = Horoscli.new time2

    time3 = Time.parse("2021-05-10 18:00 -0300")
    horos3 = Horoscli.new time3

    time4 = Time.parse("2020-11-14 10:00 +0600")
    horos4 = Horoscli.new time4

    time5 = Time.parse("2020-12-16 10:00 +0000")
    horos5 = Horoscli.new time5

    assert horos1.tz_offset == -6
    assert horos2.tz_offset == -5
    assert horos3.tz_offset == -3
    assert horos4.tz_offset == 6
    assert horos5.tz_offset == 0
  end
end
