require 'fileutils'
require 'java'
require "#{File.dirname(__FILE__)}/soy-latest.jar"

require 'closure-templates/railtie' if defined?(Rails)

java_import "com.google.template.soy.SoyFileSet"
java_import "com.google.template.soy.data.SoyMapData"
java_import "com.google.template.soy.tofu.SoyTofu"
java_import "com.google.template.soy.jssrc.SoyJsSrcOptions"

class ClosureTemplates
  @@files = {}
  @@template_dir = nil
  @@output_dir = nil
  @@tofu = nil
  @@initialized = false
  @@soyJsSrcOptions = nil
  
  def self.config(opts)
    @@template_dir = opts[:template_directory]
    @@output_dir = opts[:output_directory]
    @@initialized = true
    @@soyJsSrcOptions = SoyJsSrcOptions.new
    @@soyJsSrcOptions.setShouldProvideRequireSoyNamespaces(true)
    FileUtils.mkdir(@@output_dir) unless File.directory?(@@output_dir)
    self.compile
  end

  def self.render(template, assigns = {})
    if !@@initialized
      raise "ERROR: Not initialized!\nInitialize by calling 'ClosureTemplates.init(path_to_templates)' before calling render.\n"
    end
    if @@tofu.nil?
      raise "ERROR: No templates found in #{@@template_dir}"
    end
    @@files.keys.each do |f|
      if File.mtime(f).to_i > @@files[f]
        self.compile
        break
      end
    end
    locals = assigns.dup
    locals.keys.each do |key|
      locals[key.to_s] = locals.delete(key)
    end
    @@tofu.render(template, locals, nil)
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
      @@tofu = sfs.compileToJavaObj

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
