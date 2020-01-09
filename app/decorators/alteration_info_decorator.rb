class AlterationInfoDecorator < Draper::Decorator
  delegate_all

  def comment_section_any?
    @comment_section_any ||=
      [comment, lapel_flaring, shoulder_fix, 
        move_button, square_back_neck, armhole].any?(&:present?)
  end

  def comment_section
    [maybe_comment,
     maybe_lapel_flaring,
     maybe_shoulder_fix,
     maybe_move_button,
     maybe_square_back_neck,
     maybe_armhole].join(' ').html_safe
  end

  def maybe_comment
    handle_empty_field comment do
      h.content_tag(:span, 'Comment: ') +
      h.content_tag(:span, "#{comment};")
    end
  end

  def maybe_lapel_flaring
    handle_empty_field lapel_flaring do
      h.content_tag(:span, 'Lapel flaring: ') +
      h.content_tag(:span, "#{lapel_flaring};")
    end
  end

  def maybe_shoulder_fix
    handle_empty_field shoulder_fix do
      h.content_tag(:span, 'Shoulder fix: ') +
      h.content_tag(:span, "#{shoulder_fix};")
    end
  end

  def maybe_move_button
    handle_empty_field move_button do
      h.content_tag(:span, 'Move button: ') +
      h.content_tag(:span, "#{move_button};")
    end
  end

  def maybe_square_back_neck
    handle_empty_field square_back_neck do
      h.content_tag(:span, 'Square back neck: ') +
      h.content_tag(:span, "#{square_back_neck};")
    end
  end

  def maybe_armhole
    handle_empty_field armhole do
      h.content_tag(:span, 'Armhole: ') +
      h.content_tag(:span, "#{armhole};")
    end
  end

  private

  def handle_empty_field(value)
    if value.present?
      yield
    else
      ''
    end
  end
end
