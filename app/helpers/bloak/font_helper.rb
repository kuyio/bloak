# frozen_string_literal: true

module Bloak
  module FontHelper
    FONT_FACES = [
      { family: "Font Awesome 5 Brands", weight: 400, file: "bloak/fa-brands-400.woff2" },
      { family: "Font Awesome 5 Free", weight: 400, file: "bloak/fa-regular-400.woff2" },
      { family: "Font Awesome 5 Free", weight: 900, file: "bloak/fa-solid-900.woff2" }
    ].freeze

    def bloak_font_faces
      css = FONT_FACES.map do |font|
        <<~CSS
          @font-face {
            font-family: '#{font[:family]}';
            font-style: normal;
            font-weight: #{font[:weight]};
            font-display: block;
            src: url("#{asset_path(font[:file])}") format("woff2");
          }
        CSS
      end.join

      tag.style(css.html_safe)
    end
  end
end
