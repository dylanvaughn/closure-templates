require 'test/unit'
require 'closure-templates'
require 'person'

class TestClosureTemplates < Test::Unit::TestCase

  def setup
    ClosureTemplates.config(:template_directory => "#{File.dirname(__FILE__)}/templates", :output_directory => "test/js")
  end

  def test_simple_template
    assert_equal ClosureTemplates.render('examples.simple.helloSimple', { :name => 'Bob' }), 'Hiya Bob!'
  end

  def test_more_complicated_template
    assert_equal ClosureTemplates.render('examples.nested.hello', { :name => 'Jane', :additionalNames => ['Sue', 'Frank'] }), 'Hello Jane!<br>Hello Sue!<br>Hello Frank!'
  end

  def test_simple_template_without_locals
    assert_raise NativeException do
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
      ClosureTemplates.render('examples.simple.notSoSimple', { :name => 'Bob' })
    end
  end

  def test_calling_with_ruby_object
    dylan = Person.new('Dylan', 'Vaughn')
    assert_equal ClosureTemplates.render('examples.simple.helloObject', :object => dylan), 'First name is: Dylan and last name is: Vaughn and full name is: Dylan Vaughn'
  end

  def test_calling_with_ruby_object_with_int
    dylan = Person.new('Dylan', 'Vaughn')
    assert_equal ClosureTemplates.render('examples.simple.helloObjectInt', :object => dylan), "Dylan's age is 35"
  end

  def test_calling_with_array_of_ruby_objects
    dylan = Person.new('Dylan', 'Vaughn')
    dana = Person.new('Dana', 'Vaughn')
    assert_equal ClosureTemplates.render('examples.simple.helloObjects', :objects => [dylan, dana]), 'First name is: Dylan and last name is: Vaughn and full name is: Dylan Vaughn<br />First name is: Dana and last name is: Vaughn and full name is: Dana Vaughn<br />'
  end

  def test_data_types
    data = { :string => 'string', :int => 2, :float => 3.4, :null => nil, :bool_true => true, :bool_false => false }
    assert_equal ClosureTemplates.render('examples.simple.dataObjects', :data => data), 'String is string, int is 2, float is 3.4, null is null, bool_true is true, bool_false is false'
  end

  def test_booleans
    data = { :bool_true => true, :bool_false => false }
    assert_equal ClosureTemplates.render('examples.simple.booleans', :data => data), 'True is true. False is false.'
  end

end
