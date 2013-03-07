require 'test/helper'

class SectionTest < Kss::Test

  def setup
    @comment_text = <<comment
# Form Button

Your standard form button.

:hover    - Highlights when hovering.
:disabled - Dims the button when disabled.
.primary  - Indicates button is the primary action.
.smaller  - A smaller button

Styleguide 2.1.1.
comment

    @section = Kss::Section.new(@comment_text, 'example.css')

    @multiline_without_modifiers = <<comment
# Form Button

Your standard form button.

```html
<button class="$modifier">Example button</button>
```

Styleguide 2.1.2.
comment

    @section_without_modifiers = Kss::Section.new(@multiline_without_modifiers, 'example.css')

    @multiline_with_modifiers = <<comment
# Form Button

Your standard form button.

:hover    - Highlights when hovering.
:disabled - Dims the button when disabled.
.primary  - Indicates button is the primary action.
.smaller  - A smaller button

# Usage

```html
<button class="$modifier">Example button</button>
```

Styleguide 2.1.3.
comment

    @section_with_modifiers = Kss::Section.new(@multiline_with_modifiers, 'example.css')
  end

  test "parses the description" do
    assert_equal "# Form Button\n\nYour standard form button.", @section.description
  end

  test "parses the modifiers" do
    assert_equal 4, @section.modifiers.size
  end

  test "parses a modifier's names" do
    assert_equal ':hover', @section.modifiers.first.name
  end

  test "parses a modifier's description" do
    assert_equal 'Highlights when hovering.', @section.modifiers.first.description
  end

  test "parses the styleguide reference" do
    assert_equal '2.1.1', @section.section
  end

  test "parses multiline comments" do
    assert_equal "# Form Button\n\nYour standard form button.\n\n```html\n<button class=\"$modifier\">Example button</button>\n```", @section_without_modifiers.description
  end

  test "parses modifiers as empty when missing" do
    assert_equal 0, @section_without_modifiers.modifiers.size
  end

  test "parses multiline styleguide reference" do
    assert_equal '2.1.2', @section_without_modifiers.section
  end

  test "parses multiline comments around modifiers" do
    assert_equal "# Form Button\n\nYour standard form button.\n\n# Usage\n\n```html\n<button class=\"$modifier\">Example button</button>\n```", @section_with_modifiers.description
  end

  test "parses modifiers with comments around modifiers" do
    assert_equal 4, @section_with_modifiers.modifiers.size
  end

  test "parses multiline with modifiers styleguide reference" do
    assert_equal '2.1.3', @section_with_modifiers.section
  end


end
