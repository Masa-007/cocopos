# frozen_string_literal: true

class UsersController < ApplicationController
  helper PostsHelper

  before_action :authenticate_user!
  include MypageInsights

  def mypage
    @user = current_user
    today = Time.zone.today

    prepare_calendar(today)
  end

  def mypage_posts
    @user = current_user
    @posts = filtered_posts.page(params[:page]).per(posts_per_page)
    prepare_season_info
  end

  def mypage_records
    @user = current_user
    today = Time.zone.today

    prepare_calendar_date(today)
    prepare_future_section
    prepare_mood_section
    prepare_thanks_section
    load_month_posts_for_calendar
    prepare_season_info
  end

  private

  def prepare_calendar(today)
    prepare_calendar_date(today)
    prepare_season_info
    load_month_posts_for_calendar
  end

  def prepare_mood_section
    mood_posts = mood_posts_in_month
    @mood_chart_data = build_mood_chart_data(mood_posts)
    @mood_insight = build_mood_insight(mood_posts)
  end

  def mood_posts_in_month
    current_user.posts
                .organize
                .where.not(mood: nil)
                .where(created_at: month_range)
                .order(:created_at)
  end

  def build_mood_chart_data(posts)
    posts.map do |p|
      {
        date: p.created_at.strftime('%Y-%m-%d'),
        score: Post::MOODS[p.mood.to_sym][:score]
      }
    end
  end

  def prepare_future_section
    base_posts = future_posts_in_month
    @todo_filter = todo_filter_param # 初期は unachieved
    @future_posts = apply_todo_filter(base_posts)
    @achieved_future_count = base_posts.count { |post| post.progress.to_i == 100 }
    @future_insight = build_future_insight(
      @future_posts,
      all_future_posts: base_posts,
      todo_filter: @todo_filter
    )
  end

  def future_posts_in_month
    current_user.posts
                .future
                .where(created_at: month_range)
                .select(:id, :public_uuid, :title, :progress, :deadline, :created_at)
                .order(Arel.sql('deadline IS NULL ASC, deadline ASC, created_at ASC'))
  end

  def todo_filter_param
    allowed = %w[all achieved unachieved]
    value = params[:todo_filter].presence
    allowed.include?(value) ? value : 'unachieved'
  end

  def apply_todo_filter(posts)
    case @todo_filter
    when 'achieved'
      posts.where(progress: 100)
    when 'unachieved'
      posts.where(progress: nil).or(posts.where.not(progress: 100))
    else # 'all'
      posts
    end
  end

  def prepare_thanks_section
    thanks_posts = thanks_posts_in_month
    @thanks_points = thanks_posts.count
    @thanks_recipients_summary = build_thanks_recipients_summary(thanks_posts)
    @thanks_insight = build_thanks_insight(@thanks_recipients_summary)
  end

  def thanks_posts_in_month
    current_user.posts
                .thanks
                .where(created_at: month_range)
  end

  def month_range
    @first_day.beginning_of_day..@last_day.end_of_day
  end

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
    posts = current_user.posts
                        .where(created_at: month_range)
                        .select(:id, :public_uuid, :title, :body, :post_type, :created_at, :is_public)

    @posts_by_date = posts.group_by { |p| p.created_at.to_date }

    @monthly_post_count = posts.size
    @monthly_post_streak = calculate_monthly_post_streak(@posts_by_date)
  end

  def posts_per_page
    mobile_device? ? 10 : 9
  end

  def mobile_device?
    request.user_agent.to_s.match?(/Mobile|Android|iPhone/i)
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
