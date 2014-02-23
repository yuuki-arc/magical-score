# coding: utf-8
require 'mechanize'
require 'thread'

class InfosController < ApplicationController

  BASE_URL = 'http://project-diva-ac.net'
  @@agent = nil

  # GET /infos
  # GET /infos.json
  def index
    @@agent = Mechanize.new
    # @@agent.user_agent = 'Mozilla/5.0 (Linux; U; Android 2.3.2; ja-jp; SonyEricssonSO-01C Build/3.0.D.2.79) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
    @@agent.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
    submit_login
    @loading_que = load_page
    Rails.cache.write 'loading_que', @loading_que
    @loading_que
  end

  def call_add_info
    loading_que = Rails.cache.read 'loading_que'
    if (!loading_que.nil?)
      q = Queue.new
      q.push(loading_que.pop)
      q.push nil
      extract_link(q)
      Rails.cache.write 'loading_que', loading_que
      @loading = loading_que
    end

    respond_to do |format|
      format.html {render :layout => false}
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def submit_login
 
      @@agent.get "#{BASE_URL}/divanet/"
      @@agent.page.form_with(name: 'loginActionForm') do |form|
        form.field_with(name: 'accessCode').value = Setting.login_id
        form.field_with(name: 'password').value = Setting.login_password
        form.click_button
      end

      # page = @@agent.get 'http://project-diva-ac.net/divanet/menu/'
      # # ログインに成功してたらログアウトが存在するはず
      # puts true if @@agent.page.body =~ /niconico/
    end

    def load_page
      top = @@agent.get "#{BASE_URL}/divanet/pv/sort/1/false/0"
      pages = top.search("form.selectPage select[@name='page'] option")

      # ページ内のリンクを抽出
      q = []
      # pages.each { |page| q.push(page) }
      pages.each do |page|
        q << page['value']
      end
      return q
    end

    def extract_link(q)

      lists = []
      max_thread = 8 # 最大スレッド数
      # max_threadで指定した数だけスレッドを開始
      Array.new(max_thread) do |i|
        Thread.new { # スレッドを作成
          begin
            # 最後のnilになったらfalseになって終了
            while link = q.pop(true)
              puts "start: #{Time.now} #{link}"
              list = @@agent.get "#{BASE_URL}#{link}"
              lists += list.links_with(:href => /\/divanet\/pv\/info/n)
              puts "end  : #{Time.now} #{link}"
            end
            q.push nil # 最後を表すnilを別スレッドのために残しておく
          end
        }
      end.each(&:join)

      # 曲別ページ内を抽出
      music_infos = []
      q = Queue.new
      lists.each { |list| q.push(list) }
      q.push nil

      max_thread = 8 # 最大スレッド数
      # max_threadで指定した数だけスレッドを開始
      Array.new(max_thread) do |i|
        Thread.new { # スレッドを作成
          begin
            # 最後のnilになったらfalseになって終了
            while link = q.pop(true)
              puts "start: #{Time.now} #{link.text}"
              music_infos << {title: link.text, body: @@agent.get("#{BASE_URL}#{link.href}")}
              puts "end  : #{Time.now} #{link.text}"
            end
            q.push nil # 最後を表すnilを別スレッドのために残しておく
          end
        }
      end.each(&:join)

      # 曲別スクレイピング
      @infos = []
      music_infos.each do |music_info|
        puts music_info[:title]
        tables = music_info[:body].search('table')
        trs = tables.search('tr')

        info = {}
        info[:title] = music_info[:title]
        mode = []
        0.step(12, 4) do |pos|
          break if trs[pos].search('td')[1].text != 'クリア状況'
          tr_title = trs[pos].search('td')
          rank_str = tr_title[0].text.split("\n") {|rank| rank.strip!}
          puts "'#{rank_str[0]}', '#{rank_str[1]}'"
          info[rank_str[0].strip] = {
            star:   rank_str[1],
            detail: get_mode_score(trs, pos, pos+1, pos+3),
          }
          mode << rank_str[0].strip
        end
        info[:mode] = mode
        @infos << info
      end

      return @infos
    end

    def get_mode_score(trs, title_idx, clear_idx, score_idx)
      tr_title = trs[title_idx].search('td')
      tr_clear = trs[clear_idx].search('td img')
      tr_score = trs[score_idx].search('td')
      info = {
        title: tr_title[0].text,
        image: get_clear_image(tr_clear),
        rate:  tr_score[0].text,
        point: tr_score[1].text,
      }
    end

    def get_clear_image(elements)
      image = ''
      elements.reverse_each do |element|
        if !element.blank?
          image = "#{BASE_URL}#{element['src']}"
          break
        end
      end
      image
    end

end
