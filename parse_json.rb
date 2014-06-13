#-*- coding:utf-8 -*-

require 'net/https'
require 'json'
require 'kconv'
require 'mysql2'

#################################################
#
# データの解析クラス
#
#################################################
class Parse

  # ファイル取得処理
  def openfile file
    text = File.read file, :encoding => Encoding::UTF_8
    return text.toutf8
  end

  # データ取得処理
  def getJson
    year_s = Time.now.year - 1
    year_e = Time.now.year + 1

    response = ""
    https = Net::HTTP.new('www.google.com', 443)
    https.use_ssl = true
    #https.ca_file = './google.cer' # サーバーの公開鍵証明書を指定
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.verify_depth = 5
    https.start { |w|
      response = w.get(
        '/calendar/feeds/fvijvohm91uifvd9hratehf65k%40group.calendar.google.com/public/embed?ctz=Asia%2FTokyo&singleevents=true&' +
        'start-min=' + year_s.to_s + '-' + Time.now.strftime("%m") + '-01T00%3A00%3A00%2B09%3A00&' +
        'start-max=' + year_e.to_s + '-' + Time.now.strftime("%m") + '-01T00%3A00%3A00%2B09%3A00&max-results=1248&xsrftok=azRjUG5QdmNfTVRrWjJpUXJvNTBSeXluZGkwOjEzNDI0MTA2MDkwMjY&alt=json'
      )
      #puts response.body
    }
    return response.body.toutf8
  end

  # パース処理
  def getTopicsJson text
    data = JSON.parse(text)
    feed = Array.new
    data['feed']['entry'].each do |entry|
      location = ""
      title    = ""
      if data = /\[(.*?)\](.*?)$/.match(entry['title']['$t'])
        location = data[1] == nil ? "" : data[1]
        title    = data[2] == nil ? "" : data[2]
      elsif data = /^(.*?)$/.match(entry['title']['$t'])
        title    = data[1] == nil ? "" : data[1]
      end
      feed.push "title"=>title ,"location"=>location ,"content"=>entry['content']['$t'] ,"link"=>entry['link'][0]['href'] ,"startTime"=>entry['gd$when'][0]['startTime'] ,"endTime"=>entry['gd$when'][0]['endTime']
    end
    return feed
  end

end

#################################################
#
# データベースのヘルパークラス
#
#################################################
class DatabaseHelper
  @database = nil

  # コネクト処理
  def connect hostname ,username ,password ,database
    @database = Mysql2::Client.new(:host => hostname, :username => username, :password => password, :database => database)
    return false if isDatabase == false
    return true
  end

  # コネクト確認
  def isDatabase
    return false if @database == nil
    return true
  end

  # セレクト処理
  def select
    data_list = {}
    return false if isDatabase == false
    @database.query("SELECT url, title, start ,end FROM events").each do |link, title,startTime, endTime|
      p title
    end
    return data_list
  end

  # インサート処理
  def insert data_list
    return false if isDatabase == false
    data_list.each do |entry|
      content   = @database.escape(entry['content'])
      location  = @database.escape(entry['location'])
      title     = @database.escape(entry['title'])
      startTime = @database.escape(entry['startTime'])
      endTime   = @database.escape(entry['endTime'])

      #p entry
      @database.query(
          " INSERT INTO events " +
          "  (url,site_id,location,title,body,start,end,zip,bikou) " +
          " VALUES " +
          "  ('#{content}', 0,'#{location}','#{title}',' ','#{startTime}','#{endTime}',' ',' ')"
      )
    end
  end

  # 削除処理
  def delete
    data_list = {}
    return false if isDatabase == false
    @database.query("delete FROM events")
  end
end

parse = Parse.new
#json_text = parse.openfile 'index.html'
json_text = parse.getJson
#p json_text
feed = parse.getTopicsJson json_text

database_helper = DatabaseHelper.new
database_helper.connect 'localhost' ,'study_user' ,'study_user' ,'study_calendar'
database_helper.delete
database_helper.insert feed
#database_helper.select


