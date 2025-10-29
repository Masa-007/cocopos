# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def mypage
    @user = current_user
    today = Time.zone.today

    prepare_calendar_date(today)
    prepare_season_info

    render :mypage
  end

  private

  # カレンダー関連の日付を準備
  def prepare_calendar_date(today)
    @year  = (params[:year]  || today.year).to_i
    @month = (params[:month] || today.month).to_i
    @first_day = Date.new(@year, @month, 1)
    @last_day  = @first_day.end_of_month
    @dates     = (@first_day..@last_day).to_a
  end

  # 季節情報を準備
  def prepare_season_info
    @season = params[:season].presence || season_from_month(@month)
  end

  # 月から季節を判定
  def season_from_month(month)
    case month
    when 3..5  then 'spring'
    when 6..8  then 'summer'
    when 9..11 then 'autumn'
    else 'winter'
    end
  end

  # 次の季節を返す（ボタンで使用）
  def next_season(current)
    order = %w[spring summer autumn winter]
    order[(order.index(current) + 1) % order.size]
  end
  helper_method :next_season
end
