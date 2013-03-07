module Kss
  # Public: Represents a styleguide section. Each section describes one UI
  # element. A Section can be thought of as the collection of the description,
  # modifiers, and styleguide reference.
  class Section

    # Returns the raw comment text for the section, not including comment
    # syntax (such as // or /* */).
    attr_reader :raw

    # Public: Returns the filename where this section is found.
    attr_reader :filename

    # Public: Initialize a new Section
    #
    # comment_text - The raw comment String, minus any comment syntax.
    # filename     - The filename as a String.
    def initialize(comment_text=nil, filename=nil)
      @raw = comment_text
      @filename = filename
    end

    class CommentSection < Struct.new(:comment, :modifiers, :section)
    end

    # Splits up the raw comment text into comment sections that represent
    # description, modifiers, etc.
    #
    # Returns an Array of comment Strings.
    def comment_sections
      return @comment_sections if @comment_sections

      @comment_sections = raw ? raw.split("\n\n").collect { |s| CommentSection.new(s, [], false) } : []

      @comment_sections.each do |comment_section|
        comment_section.modifiers = parse_modifiers(comment_section.comment)
        comment_section.section = parse_section(comment_section.comment)
      end
    end

    # Public: The styleguide section for which this comment block references.
    #
    # Returns the section reference String (ex: "2.1.8").
    def section
      comment_sections.map(&:section).select { |section| section }.last
    end

    # Public: The description section of a styleguide comment block.
    #
    # Returns the description String.
    def description
      comment_sections.reject do |section|
        section.modifiers.any? or section.section
      end.map(&:comment).join("\n\n")
    end

    # Public: The modifiers section of a styleguide comment block.
    #
    # Returns an Array of Modifiers.
    def modifiers
      comment_sections.collect do |section|
        section.modifiers
      end.flatten
    end

  private

    def section_comment
      comment_sections.find do |text|
        text =~ /Styleguide \d/i
      end.to_s
    end

    # Private: Given a comment section, detects if is describes the Styleguide section
    # and returns the section when foudn
    def parse_section(comment_section)
      cleaned  = comment_section.strip.sub(/\.$/, '') # Kill trailing period
      if cleaned.match(/Styleguide (.+)/)
        $1
      else
        false
      end
    end

    def parse_modifiers(comment_section)
      last_indent = nil
      modifiers = []

      comment_section.split("\n").each do |line|
        next if line.strip.empty?
        indent = line.scan(/^\s*/)[0].to_s.size

        if modifiers.any? && last_indent && indent > last_indent
          modifiers.last.description += line.squeeze(" ")
        else
          modifier, desc = line.split(" - ")
          modifiers << Modifier.new(modifier.strip, desc.strip) if modifier && desc
        end

        last_indent = indent
      end

      modifiers
    end
  end
end
