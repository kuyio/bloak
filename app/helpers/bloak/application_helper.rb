module Bloak
  module ApplicationHelper
    def page_title
      if content_for?(:title)
        # allows the title to be set in the view by using t(".title")
        "#{Bloak.site_name} • #{content_for(:title)}"
      else
        Bloak.site_name
      end
    end

    def friendly_date(datetime)
      datetime.to_s(:friendly)
    end

    def lni_checkmark(value)
      if value
        tag.i(class: 'fas fa-check-circle text-success')
      else
        tag.i(class: 'far fa-circle text-secondary')
      end
    end
  end
end
