RSpec::Matchers.define :have_styling do |rules|
  @selector = 'body > *:first'
  normalized_rules = StylingExpectation.new(rules)

  chain(:at_selector) { |selector| @selector = selector }
  match { |document| normalized_rules == styles_at_selector(document) }

  description {
    "have styles #{normalized_rules.inspect} at selector #{@selector.inspect}"
  }

  failure_message_for_should { |document|
    "expected styles at #{@selector.inspect} to be:\n#{normalized_rules}\nbut was:\n#{styles_at_selector(document)}"
  }

  failure_message_for_should_not {
    "expected styles at #{@selector.inspect} to not be:\n#{normalized_rules}"
  }

  def styles_at_selector(document)
    document.should have_selector(@selector)
    StylingExpectation.new document.at_css(@selector)
  end
end

class StylingExpectation
  def initialize(styling)
    case styling
    when Nokogiri::XML::Node then @rules = parse_rules(styling['style'] || "")
    when String then @rules = parse_rules(styling)
    when Array then @rules = styling
    when Hash then @rules = styling.to_a
    else fail "I don't understand #{styling.inspect}!"
    end
  end

  def ==(other)
    rules == other.rules
  end

  def to_s() rules.to_s end

  protected
  attr_reader :rules

  private
  def parse_rules(css)
    SpecHelpers.parse_styling(css)
  end
end
