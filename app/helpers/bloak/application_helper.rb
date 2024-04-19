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

    # Render the given date in a friendly format
    def friendly_date(datetime, format = :friendly)
      # Rails 7.1 deprecated `to_s(format)` in favor of `to_fs(format)`
      if datetime.respond_to?(:to_fs)
        datetime.to_fs(format)
      else
        datetime.to_s(format)
      end
    rescue StandardError
      datetime&.to_s
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
