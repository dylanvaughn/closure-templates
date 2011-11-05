require 'test/unit'
require 'closure-templates'

class TestClosureTemplates < Test::Unit::TestCase

  def test_simple_template
    ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/templates", :output_directory => "test/js")
    assert_equal ClosureTemplates.render('examples.simple.helloSimple', { :name => 'Bob' }), 'Hiya Bob!'
  end

  def test_more_complicated_template
    ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/templates", :output_directory => "test/js")
    assert_equal ClosureTemplates.render('examples.nested.hello', { :name => 'Jane', :additionalNames => ['Sue', 'Frank'] }), 'Hello Jane!<br>Hello Sue!<br>Hello Frank!'
  end

  def test_simple_template_without_locals
    assert_raise NativeException do
      ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/templates", :output_directory => "test/js")
      ClosureTemplates.render('examples.simple.helloSimple')
    end
  end

  def test_empty_template_dir
    assert_nothing_raised do
      ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/no_templates", :output_directory => "test/js")
    end
  end

  def test_calling_render_with_no_templates
    assert_raise RuntimeError do
      ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/no_templates", :output_directory => "test/js")
      ClosureTemplates.render('examples.simple.helloSimple')
    end
  end

  def test_calling_render_with_incorrect_template_name
    assert_raise NativeException do
      ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/templates", :output_directory => "test/js")
      ClosureTemplates.render('examples.simple.notSoSimple', { :name => 'Bob' })
    end
  end

end
