# frozen_string_literal: true

class UsersController < ApplicationController
  helper PostsHelper

  before_action :authenticate_user!
  include MypageInsights

  def mypage
    @user = current_user
    today = Time.zone.today

    # ---- カレンダー（月切替） ----
    prepare_calendar_date(today)
    prepare_season_info
    load_month_posts_for_calendar

    # 🌈 ---- 気分グラフ（月ごと） ----
    mood_posts = current_user.posts
                             .organize
                             .where.not(mood: nil)
                             .where(created_at: @first_day.beginning_of_day..@last_day.end_of_day)
                             .order(:created_at)

    @mood_chart_data = mood_posts.map do |p|
      {
        date: p.created_at.strftime('%Y-%m-%d'),
        score: Post::MOODS[p.mood.to_sym][:score]
      }
    end

    @mood_insight = build_mood_insight(mood_posts)

    # 🌱 ---- 未来宣言箱（TODO/進捗/期限） ----
    @future_posts = current_user.posts
                                .future
                                .where(created_at: @first_day.beginning_of_day..@last_day.end_of_day)
                                .select(:id, :title, :progress, :deadline, :created_at)
                                .order(:created_at)

    @future_insight = build_future_insight(@future_posts)

    thanks_posts = current_user.posts
                               .thanks
                               .where(created_at: @first_day.beginning_of_day..@last_day.end_of_day)

    @thanks_points = thanks_posts.count
    @thanks_recipients_summary = build_thanks_recipients_summary(thanks_posts)
    @thanks_insight = build_thanks_insight(@thanks_recipients_summary)

    render :mypage
  end

  def mypage_posts
    @user = current_user
    @posts = filtered_posts.page(params[:page])
    prepare_season_info
    render :mypage_posts
  end

  private

  # ---- 投稿一覧フィルタ ----
  def filtered_posts
    posts = current_user.posts.includes(:user)
    posts = filter_posts(posts)

    if params[:q].present?
      query = "%#{params[:q]}%"
      posts = posts.where('title ILIKE :q OR body ILIKE :q', q: query)
    end

    posts = apply_sub_filter(posts)
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

  def apply_sub_filter(posts)
    case params[:filter]
    when 'future'
      case params[:sub_filter]
      when 'future_achieved'
        posts.where(progress: 100)
      when 'future_unachieved'
        posts.where(progress: nil).or(posts.where.not(progress: 100))
      else
        posts
      end
    when 'organize'
      return posts if params[:sub_filter].blank?

      posts.where(mood: params[:sub_filter])
    when 'thanks'
      return posts if params[:sub_filter].blank?

      posts.where(thanks_recipient: params[:sub_filter])
    else
      posts
    end
  end

  # ---- カレンダー（日付関連）----
  def prepare_calendar_date(today)
    @year  = (params[:year] || today.year).to_i
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

    @monthly_post_count = posts.size
    @monthly_post_streak = calculate_monthly_post_streak(@posts_by_date)
  end

  def calculate_monthly_post_streak(posts_by_date)
    streak_end = [Time.zone.today.to_date, @last_day].min
    streak = 0

    while streak_end >= @first_day
      break unless posts_by_date[streak_end]&.any?

      streak += 1
      streak_end -= 1
    end

    streak
  end

  # ---- 季節切替 ----
  def next_season(current)
    order = %w[spring summer autumn winter]
    order[(order.index(current) + 1) % order.size]
  end

  helper_method :next_season
end
