# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def mypage
    @user = current_user
    today = Time.zone.today
    prepare_calendar_date(today)
    prepare_season_info
    load_month_posts_for_calendar
    render :mypage
  end

  def mypage_posts
    @user  = current_user
    @posts = filtered_posts.page(params[:page])
    prepare_season_info
    render :mypage_posts
  end

  private

  def filtered_posts
    posts = current_user.posts
    posts = filter_posts(posts)
    sort_posts(posts)
  end

  def filter_posts(posts)
    case params[:filter]
    when 'future'   then posts.where(post_type: 'future')
    when 'organize' then posts.where(post_type: 'organize')
    when 'thanks'   then posts.where(post_type: 'thanks')
    when 'private'  then posts.where(is_public: false)
    else posts
    end
  end

  def sort_posts(posts)
    if params[:sort] == 'old'
      posts.order(created_at: :asc)
    else
      posts.order(created_at: :desc)
    end
  end

  def prepare_calendar_date(today)
    @year  = (params[:year]  || today.year).to_i
    @month = (params[:month] || today.month).to_i
    @first_day = Date.new(@year, @month, 1)
    @last_day  = @first_day.end_of_month
    @dates     = (@first_day..@last_day).to_a
  end

  def prepare_season_info
    @season = params[:season].presence || season_from_month(@month || Time.zone.today.month)
  end

  def season_from_month(month)
    case month
    when 3..5  then 'spring'
    when 6..8  then 'summer'
    when 9..11 then 'autumn'
    else 'winter'
    end
  end

  def load_month_posts_for_calendar
    range = @first_day.beginning_of_day..@last_day.end_of_day
    posts = current_user.posts
                        .where(created_at: range)
                        .select(:id, :title, :body, :post_type, :created_at, :is_public)
    @posts_by_date = posts.group_by { |p| p.created_at.to_date }
  end

  def next_season(current)
    order = %w[spring summer autumn winter]
    order[(order.index(current) + 1) % order.size]
  end
  helper_method :next_season
end
