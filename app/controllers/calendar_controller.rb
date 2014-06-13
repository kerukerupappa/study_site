#-*- coding:utf-8 -*-
class CalendarController < ApplicationController
  def index

    @year  = params[:year]  =~ /^[0-9]+$/           ? params[:year].to_i  : Time.now.year
    @month = params[:month] =~ /^(0?[1-9]|1[0-2])$/ ? params[:month].to_i : Time.now.month

    @calendar   = CalendarStuff::Calendar.new
    @month_list = @calendar.calendar_array @year, @month
    @month_year = @calendar.chenge_month(@month) + @year.to_s
    @today      = @calendar.today @year, @month

    date = Date.new(@year, @month, 1)
    @prev_url  = '/calendar/' + date.months_ago(1).year.to_s   + '/' + date.months_ago(1).month.to_s
    @next_url  = '/calendar/' + date.months_since(1).year.to_s + '/' + date.months_since(1).month.to_s
    @today_url = '/calendar/' + Time.now.year.to_s + '/' + Time.now.month.to_s


    @location_key = params[:location] == nil      ? "" : params[:location]
    @location_key = @location_key     == "全国" ? "" : @location_key
    @search_key   = params[:search]   == nil      ? "" : params[:search]

    @location = Event.find(
        :all,
        :select => "location",
        :conditions => [
            "start between ? and ? and title like ?",
            @year.to_s + "-" + @month.to_s + "-01",
            @year.to_s + "-" + Date.new(@year, @month, 1).months_since(1).month.to_s + "-01",
            "%" + @search_key   + "%"
        ],
        :order => 'location asc'
    ).group_by(&:location)

    #@event = Array.new
    @events = Event.find(
        :all,
        :select => "date_format(events.start,'%e') as day,events.title, events.start, events.url",
        :conditions => [
            "start between ? and ? and location like ? and  title like ?",
            @year.to_s + "-" + @month.to_s + "-01",
            Date.new(@year, @month, 1).months_since(1).year.to_s + "-" + Date.new(@year, @month, 1).months_since(1).month.to_s + "-01",
            "%" + @location_key + "%",
            "%" + @search_key   + "%"
        ],
        :order => 'start asc'
    ).group_by(&:day)

  end
end
