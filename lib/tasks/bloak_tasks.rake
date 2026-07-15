# frozen_string_literal: true

namespace :bloak do
  desc "Migrate post content from legacy !-prefix tags to Liquid tags"
  task migrate_posts: :environment do
    dry_run = ENV["DRY_RUN"] == "1"
    posts = Bloak::Post.where(
      "content LIKE '%!toc%' OR content LIKE '%!media[%' OR " \
      "content LIKE '%!!%' OR content LIKE '%!w %' OR " \
      "content LIKE '%!i %' OR content LIKE '%!q %'"
    )

    if posts.empty?
      puts "No posts found with legacy tags."
      next
    end

    puts "Found #{posts.count} post(s) with legacy tags."
    puts "DRY RUN — no changes will be saved." if dry_run
    puts

    converted = 0
    posts.find_each do |post|
      original = post.content.dup
      migrated = migrate_content(original)

      next if migrated == original

      puts "=" * 60
      puts "Post: #{post.title} (#{post.slug})"
      puts "-" * 60

      show_diff(original, migrated)

      unless dry_run
        post.update!(content: migrated)
        puts "  -> Saved."
      end

      converted += 1
      puts
    end

    puts "=" * 60
    if dry_run
      puts "#{converted} post(s) would be converted. Run without DRY_RUN=1 to apply."
    else
      puts "#{converted} post(s) converted."
    end
  end
end

def migrate_content(content)
  lines = content.lines
  result = []
  in_code_block = false

  lines.each do |line|
    if line.strip.start_with?("```")
      in_code_block = !in_code_block
      result << line
      next
    end

    if in_code_block
      result << line
      next
    end

    result << convert_line(line)
  end

  result.join
end

def convert_line(line)
  stripped = line.strip

  case stripped
  when /\A!toc\[(.+)\]\z/
    line.sub(stripped, "{% toc \"#{Regexp.last_match(1)}\" %}")
  when /\A!toc\z/
    line.sub(stripped, "{% toc %}")
  when /\A!media\[(.+)\]\z/
    line.sub(stripped, "{% media \"#{Regexp.last_match(1)}\" %}")
  when /\A!! ?(.+)\z/
    line.sub(stripped, "{% danger %}#{Regexp.last_match(1).strip}{% enddanger %}")
  when /\A!w ?(.+)\z/
    line.sub(stripped, "{% warning %}#{Regexp.last_match(1).strip}{% endwarning %}")
  when /\A!i ?(.+)\z/
    line.sub(stripped, "{% info %}#{Regexp.last_match(1).strip}{% endinfo %}")
  when /\A!q ?(.+)\z/
    line.sub(stripped, "{% quote %}#{Regexp.last_match(1).strip}{% endquote %}")
  else
    line
  end
end

def show_diff(original, migrated)
  orig_lines = original.lines
  new_lines = migrated.lines

  max = [orig_lines.length, new_lines.length].max
  max.times do |i|
    old_line = orig_lines[i]&.chomp
    new_line = new_lines[i]&.chomp

    next if old_line == new_line

    puts "  - #{old_line}"
    puts "  + #{new_line}"
  end
end
