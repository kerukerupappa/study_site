#-*- coding:utf-8 -*-

#
# カレンダー表示クラス
#
module CalendarStuff
  class Calendar

    require "date"

    #
    # 配列で一ヶ月のデータ作成
    #
    def calendar_array yyyy, mm

      start_wday = Date.new(yyyy, mm, 1).wday
      end_month  = Date.new(yyyy, mm, -1).day
      day = 1;

      month = Array.new
      while day <= end_month
        week = Array.new
        for i in 1 .. 7
          if start_wday > 0 or day > end_month
            week.push(nil)
            start_wday -= 1
          else
            week.push(day)
            day += 1
          end
        end
        month.push(week)
      end

      return month

    end

    #
    # 月名を返却
    #
    def chenge_month month
      month_name = ['January ','February ','March ','April ','May ','June ','July ','August ','September ','October ','November ','December ']
      month = month.to_s =~ /^(0?[1-9]|1[0-2])$/? month.to_i : Time.now.month
      return month_name[month -1]
    end

    #
    # 日付の確認
    #
    def today year, month
      day = 0;
      if year == Time.now.year && month == Time.now.month
          day = Time.now.day
      end
      return day
    end

  end
end
