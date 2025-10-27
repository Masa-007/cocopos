# frozen_string_literal: true

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!

  def mypage
    @user = current_user
    today = Time.zone.today

    # ==== 表示年月 ====
    @year  = (params[:year]  || today.year).to_i
    @month = (params[:month] || today.month).to_i

    # ==== 季節を決定 ====
    # URLにseasonパラメータがあればそれを優先
    @season = params[:season].presence || season_from_month(@month)

    # ==== カレンダーの日付処理 ====
    @first_day = Date.new(@year, @month, 1)
    @last_day  = @first_day.end_of_month
    @dates     = (@first_day..@last_day).to_a

    render :mypage
  end

  private

  # ==== 月から季節を判定 ====
  def season_from_month(month)
    case month
    when 3..5  then 'spring'
    when 6..8  then 'summer'
    when 9..11 then 'autumn'
    else 'winter'
    end
  end

  # ==== 次の季節を返す（ボタンで使用） ====
  def next_season(current)
    order = %w[spring summer autumn winter]
    order[(order.index(current) + 1) % order.size]
  end
  helper_method :next_season
end
