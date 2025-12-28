module PostsHelper
  def selected_filter?(current, value)
    current = current.presence
    value = value.presence

    if value.blank?
      current.blank?
    elsif value == "all"
      current.blank? || current == "all"
    else
      current == value
    end
  end

  def show_post_actions?(post, from:)
    return true if from == "mypage"
    post.is_public?
  end

  def show_comment_button?(post)
    post.comment_allowed?
  end

  def show_private_badge?(post)
    user_signed_in? && post.user == current_user && !post.is_public?
  end

  def comment_status_badge(post)
    if post.comment_allowed?
      content_tag(
        :span,
        "💬 意見募集中",
        class: "px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-bold"
      )
    else
      content_tag(
        :span,
        "💭 コメント不要",
        class: "px-2 py-1 bg-gray-200 text-xs rounded-full"
      )
    end
  end
end
