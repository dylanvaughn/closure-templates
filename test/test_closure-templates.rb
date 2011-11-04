require 'test/unit'
require 'closure-templates'

class TestClosureTemplates < Test::Unit::TestCase
  def test_simple_template
    ClosureTemplates.init("#{File.dirname(__FILE__)}/templates")
    assert_equal ClosureTemplates.render('examples.simple.helloSimple', { :name => 'Bob' }), 'Hiya Bob!'
  end
end
