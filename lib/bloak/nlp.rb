# frozen_string_literal: true

module Bloak
  module Nlp
    def self.paragraphs(text)
      text.split(/[\n\r]{2,}/)
    end

    def self.sentences(text)
      text.split(/((?<=[a-z0-9][.?!])|(?<=[a-z0-9][.?!]"))(\s|\r\n)(?="?[A-Z])/)
    end

    def self.tokenize(text)
      text.split(/\s+/)
    end

    def self.split_with_punctuation(text)
      return text if text.end_with?("'S")

      text.split(/((?<=\p{P})|(?=\p{P}))/).map(&:strip)
    end

    def self.punctuation?(token)
      (token =~ /\p{P}/) != nil
    end

    def self.word?(token)
      !punctuation?(token)
    end

    def self.reading_time(text, speed = 250)
      @text = text

      @paragraphs = paragraphs(text)

      @sentences =
        @paragraphs
          .flat_map { |paragraph| sentences(paragraph) }
          .filter { |s| (s =~ /\A\s*\z/).nil? }

      @tokens =
        @sentences
          .flat_map { |sentence| tokenize(sentence) }
          .map(&:upcase)
          .flat_map { |token| split_with_punctuation(token) }
          .filter { |s| (s =~ /\A\s*\z/).nil? }

      @words = @tokens.filter { |token| word?(token) }

      (@words.count + (speed / 2)) / speed
    end
  end
end
