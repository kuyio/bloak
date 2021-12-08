module Bloak
  module ApplicationHelper
    include Pagy::Frontend

    def page_title
      if content_for?(:title)
        # allows the title to be set in the view by using t(".title")
        "#{Bloak.site_name} – #{content_for(:title)}".html_safe
      else
        Bloak.site_name
      end
    end

    def admin_page_title
      if content_for?(:title)
        # allows the title to be set in the view by using t(".title")
        "#{Bloak.site_name} Admin – #{content_for(:title)}"
      else
        "#{Bloak.site_name} Admin"
      end
    end

    def friendly_date(datetime)
      datetime.to_s(:friendly)
    end

    def short_date(datetime)
      datetime.strftime("%b %d, %Y")
    end

    def lni_checkmark(value)
      if value
        tag.i(class: 'fas fa-check-circle text-success')
      else
        tag.i(class: 'far fa-circle text-secondary')
      end
    end

    def lni_featured(value)
      if value
        tag.i(class: 'fas fa-star text-warning')
      else
        tag.i(class: 'far fa-star text-light')
      end
    end
  end
end
