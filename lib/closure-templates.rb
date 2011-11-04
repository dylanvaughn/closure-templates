require 'java'
require "#{File.dirname(__FILE__)}/soy-latest.jar"

java_import "com.google.template.soy.SoyFileSet"
java_import "com.google.template.soy.data.SoyMapData"
java_import "com.google.template.soy.tofu.SoyTofu"

class ClosureTemplates
  @@files = {}
  @@template_dir = nil
  @@tofu = nil
  
  def self.init(dir)
    @@template_dir = dir
    self.compile
  end

  def self.render(template, assigns = {})
    if @@tofu.nil?
      raise "ERROR: Not initialized!\nInitialize by calling 'ClosureTemplates.init(path_to_templates)' before calling render.\n"
    end
    @@files.keys.each do |f|
      if File.mtime(f).to_i > @@files[f]
        self.compile
        break
      end
    end
    puts "banana: rendering!"
    locals = assigns.dup
    locals.keys.each do |key|
      locals[key.to_s] = locals.delete(key)
    end
    @@tofu.render(template, locals, nil)
  end

  def self.compile
    puts "banana: compiling!"
    @@files = {}
    sfs_builder = SoyFileSet::Builder.new
    Dir.glob("#{@@template_dir}/**/*.soy") do |file|
      @@files[file] = File.mtime(file).to_i
      sfs_builder.add(java.io.File.new(file))
    end
    sfs = sfs_builder.build
    @@tofu = sfs.compileToJavaObj
  end

end
