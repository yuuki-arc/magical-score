# coding: utf-8
require 'mechanize'

class InfosController < ApplicationController
  before_action :set_info, only: [:show, :edit, :update, :destroy]

  BASE_URL = 'http://project-diva-ac.net'

  # GET /infos
  # GET /infos.json
  def index
    @agent = Mechanize.new
    # @agent.user_agent = 'Mozilla/5.0 (Linux; U; Android 2.3.2; ja-jp; SonyEricssonSO-01C Build/3.0.D.2.79) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
    @agent.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
    submit_login
    extract_link
  end

  # GET /infos/1
  # GET /infos/1.json
  def show
  end

  # GET /infos/new
  def new
    @info = Info.new
  end

  # GET /infos/1/edit
  def edit
  end

  # POST /infos
  # POST /infos.json
  def create
    @info = Info.new(info_params)

    respond_to do |format|
      if @info.save
        format.html { redirect_to @info, notice: 'Info was successfully created.' }
        format.json { render action: 'show', status: :created, location: @info }
      else
        format.html { render action: 'new' }
        format.json { render json: @info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /infos/1
  # PATCH/PUT /infos/1.json
  def update
    respond_to do |format|
      if @info.update(info_params)
        format.html { redirect_to @info, notice: 'Info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /infos/1
  # DELETE /infos/1.json
  def destroy
    @info.destroy
    respond_to do |format|
      format.html { redirect_to infos_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_info
      @info = Info.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def info_params
      params[:info]
    end

    def submit_login
 
      @agent.get "#{BASE_URL}/divanet/"
      @agent.page.form_with(name: 'loginActionForm') do |form|
        form.field_with(name: 'accessCode').value = Setting.login_id
        form.field_with(name: 'password').value = Setting.login_password
    #    @agent.page.body =~ /\("\.albatross"\)\[0\]\.value = "(.*)"/
    #    form.field_with(name: '.albatross').value = $1
        form.click_button
      end

      # page = @agent.get 'http://project-diva-ac.net/divanet/menu/'
      # # ログインに成功してたらログアウトが存在するはず
      # puts true if @agent.page.body =~ /niconico/
    end

    def extract_link
      list = @agent.get "#{BASE_URL}/divanet/pv/sort/1/false/0"

      # href 属性の値が .jpg で終わるリンクをすべて抽出
      title_infos = []
      music_infos = []
      list.links_with(:href => /\/divanet\/pv\/info/n).each do |link|
        title_infos << link.text
        music_infos << @agent.get("#{BASE_URL}#{link.href}") # リンクにアクセスした結果をカレントディレクトリに保存
      end

      mode_text = ['EASY', 'NORMAL', 'HARD', 'EXTREME']
      @infos = []
      music_infos.each_with_index do |music_info, i|
        tables = music_info.search('table')
        trs = tables.search('tr')

        @infos << '<hr/>'
        @infos << title_infos[i]
        0.step(12, 4) do |pos|
          break if trs[pos].search('td')[1].text != 'クリア状況'
          @infos << get_mode_score(trs, pos, pos+1, pos+3)
        end
      end

    end

    def get_mode_score(trs, title_idx, clear_idx, score_idx)
      tr_title = trs[title_idx].search('td')
      tr_clear = trs[clear_idx].search('td img')
      tr_score = trs[score_idx].search('td')
      info = \
        "#{tr_title[0].text}　　" +
        "#{get_clear_image(tr_clear)}　　" +
        "#{tr_score[0].text}　　" +
        "#{tr_score[1].text}　　"
    end

    def get_clear_image(elements)
      image = ''
      elements.reverse_each do |element|
        if !element.blank?
          image = "<img src='#{BASE_URL}#{element['src']}' width='25' height='26' border='0'>"
          break
        end
      end
      image
    end
end
