# frozen_string_literal: true

require "test_helper"

module Bloak
  class NlpTest < ActiveSupport::TestCase
    test "paragraphs splits on double newlines" do
      text = "First paragraph.\n\nSecond paragraph.\n\nThird."
      result = Nlp.paragraphs(text)
      assert_equal 3, result.length
      assert_equal "First paragraph.", result.first
    end

    test "paragraphs returns single element for text without double newlines" do
      result = Nlp.paragraphs("Just one paragraph.")
      assert_equal 1, result.length
    end

    test "sentences splits on sentence boundaries" do
      text = "Hello world. How are you? I am fine."
      result = Nlp.sentences(text)
      sentences = result.grep_v(/\A\s*\z/)
      assert_equal 3, sentences.length
    end

    test "sentences returns full text when no sentence boundaries" do
      result = Nlp.sentences("hello world")
      non_blank = result.grep_v(/\A\s*\z/)
      assert_equal 1, non_blank.length
    end

    test "tokenize splits on whitespace" do
      assert_equal %w[hello world], Nlp.tokenize("hello world")
    end

    test "split_with_punctuation preserves possessives" do
      result = Nlp.split_with_punctuation("IT'S")
      assert_equal "IT'S", result
    end

    test "split_with_punctuation splits around punctuation" do
      result = Nlp.split_with_punctuation("hello,world")
      assert_includes result, "hello"
      assert_includes result, ","
      assert_includes result, "world"
    end

    test "punctuation? returns true for punctuation" do
      assert Nlp.punctuation?(",")
      assert Nlp.punctuation?(".")
    end

    test "punctuation? returns false for words" do
      assert_not Nlp.punctuation?("hello")
    end

    test "word? returns true for words" do
      assert Nlp.word?("hello")
    end

    test "word? returns false for punctuation" do
      assert_not Nlp.word?(",")
    end

    test "reading_time computes correct value for known word count" do
      text = ("word " * 500).strip
      result = Nlp.reading_time(text, 250)
      assert_equal 2, result
    end

    test "reading_time rounds up with remainder" do
      text = ("word " * 375).strip
      result = Nlp.reading_time(text, 250)
      assert_equal 2, result
    end

    test "reading_time returns 0 for empty text" do
      result = Nlp.reading_time("", 250)
      assert_equal 0, result
    end

    test "reading_time returns 0 for very short text" do
      result = Nlp.reading_time("Hi.", 250)
      assert_equal 0, result
    end
  end
end
