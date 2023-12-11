module CommentsHelper

  def nested_comments(comments)
    comments.map do |comment, sub_comments|
      content_tag(:div, render(partial: 'comments/comment', locals: { comment: comment }), :class => "media")
    end.join.html_safe
  end

end