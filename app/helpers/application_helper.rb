module ApplicationHelper

  def flash_messages
    flash.map do |key, message|
      alert_type = case key
        when 'notice' then 'alert-success'
        when 'alert'  then 'alert-error'
        else nil
      end
      content_tag :p, message, id: 'flash', class: ['alert', alert_type].join(' ')
    end.join.html_safe
  end

  def title_placeholder
    return 'Title Your Note' if current_user.notes.any?
    'Title Your First Note'
  end

  def title_autofocus?(note)
    !note.persisted?
  end

end
