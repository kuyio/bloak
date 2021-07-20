module Bloak
  module Nlp
    def self.paragraphs(text)
      text.split(/[\n\r]{2,}/)
    end

    def self.sentences(text)
      text.split(/((?<=[a-z0-9][.?!])|(?<=[a-z0-9][.?!]\"))(\s|\r\n)(?=\"?[A-Z])/)
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
          .map { |paragraph| sentences(paragraph) }
          .flatten
          .filter { |s| (s =~ /\A\s*\z/).nil? }

      @tokens =
        @sentences
          .map { |sentence| tokenize(sentence) }
          .flatten
          .map(&:upcase)
          .map(&method(:split_with_punctuation))
          .flatten
          .filter { |s| (s =~ /\A\s*\z/).nil? }

      @words = @tokens.filter(&method(:word?))

      (@words.count + speed / 2) / speed
    end
  end
end
