require 'tilt'
require 'fileutils'
require 'java'
require "#{File.dirname(__FILE__)}/jar/soy-latest.jar"

require 'closure-templates/version'

java_import "com.google.template.soy.SoyFileSet"
java_import "com.google.template.soy.data.SoyMapData"
java_import "com.google.template.soy.tofu.SoyTofu"
java_import "com.google.template.soy.jssrc.SoyJsSrcOptions"

class ClosureTemplates
  @@files           = {}
  @@template_dir    = nil
  @@output_dir      = nil
  @@tofu            = nil
  @@initialized     = false
  @@recompile       = nil
  @@soyJsSrcOptions = nil
  @@attr_method     = nil
  
  def self.config(opts)
    @@template_dir    = opts[:template_directory] || 'templates'
    @@output_dir      = opts[:output_directory] || 'closure_js'
    @@recompile       = !opts[:recompile].nil? ? opts[:recompile] : true
    @@attr_method     = opts[:attribute_method] || 'attributes'
    @@soyJsSrcOptions = SoyJsSrcOptions.new

    @@soyJsSrcOptions.setShouldProvideRequireSoyNamespaces(true)
    FileUtils.mkdir(@@output_dir) unless File.directory?(@@output_dir)
    self.compile

    @@initialized = true
  end

  def self.render(template, assigns = {})
    if !@@initialized
      raise "ERROR: Not configured!\nConfigure by calling 'ClosureTemplates.config(:template_directory => path_to_templates, :output_directory => path_to_where_js_should_go)' before calling render.\n"
    end
    if @@tofu.nil?
      raise "ERROR: No templates found in #{@@template_dir}"
    end
    if @@recompile
      @@files.keys.each do |f|
        if File.mtime(f).to_i > @@files[f]
          self.compile
          break
        end
      end
    end
    locals = assigns.dup
    locals.keys.each do |key|
      val = locals.delete(key)
      if val.is_a?(Array)
        locals[key.to_s] = val.map { |v| convert_for_closure(v) }
      else
        locals[key.to_s] = convert_for_closure(val)
      end
    end
    @@tofu.render(template, locals, nil)
  end

  def self.convert_for_closure(val)
    val = val.send(@@attr_method) if val.respond_to?(@@attr_method)
    if val.is_a?(Hash)
      val.keys.each do |k|
        v = val.delete(k)
        val[k.to_s] = v.is_a?(Integer) ? v.to_java(:int) : v
      end
    end
    val
  end

  def self.compile
    @@files = {}
    files_in_order = []
    sfs_builder = SoyFileSet::Builder.new
    Dir.glob("#{@@template_dir}/**/*.soy") do |file|
      files_in_order << file
      @@files[file] = File.mtime(file).to_i
      sfs_builder.add(java.io.File.new(file))
    end
    if @@files.keys.size == 0
      # no templates
      @@tofu = nil
    else
      sfs = sfs_builder.build

      # ruby
      @@tofu = sfs.compileToJavaObj(true)

      # javascript
      sfs.compileToJsSrc(@@soyJsSrcOptions, nil).each_with_index do |js_out, index|
        file_path = File.join(@@output_dir, files_in_order[index].gsub(/^#{@@template_dir}\//, '').gsub(/soy$/, 'js'))
        File.open(file_path, 'w') do |f|
          f.write(js_out)
        end
      end
    end
  end

end
