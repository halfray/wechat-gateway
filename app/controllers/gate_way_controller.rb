class GateWayController < ApplicationController
  before_action 'have_user', except: [:index, :get_qrcode, :check_qrcode]

  def index
    session[:user] = true
    render layout: "layouts/login"
  end

  def send_message
  end

  def get_qrcode
    resp = RestClient.get Project.settings.get_qrcode_url
    render json: {url: resp.body}
  end

  def check_qrcode
    qrcode = params['qrcode']
    begin
      resp = RestClient.get Project.settings.check_qrcode_url + qrcode
      if resp.code == 200
        result = JSON.parse(resp.body)
        session[:user] = qrcode
        session[:cookies]=result['cookies']
        render json: {result: true}
      end
    rescue Exception
      render json: {result: false}
    end
  end


  def contact_list
    puts Project.settings.contact_list_url + @user
    resp = RestClient.get Project.settings.contact_list_url + @user
    render json: resp.body
  end

  def sends
    users = params[:users]
    content = params[:message]

    users.each do |user|
      resp = nil
      begin
        resp = RestClient.post Project.settings.send_msg_url, {content: content, qrcode: @user, toUserName: user}.to_json, :content_type => :json, :accept => :json
        puts resp.body
      rescue Exception => e
        puts e
      end
    end

    render json: {}
  end


  private
  def have_user
    redirect_to "/" unless session[:user]
    @user = session[:user]
  end

end

