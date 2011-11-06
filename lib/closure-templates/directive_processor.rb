class ClosureDependenciesProcessor < Tilt::Template
  def prepare; end

  def evaluate(context, locals, &block)
    environment.logger.info("Requiring google base")
    context.require_asset 'goog/base'
    environment.logger.info("Requiring google base")
    context.require_asset 'soyutils_usegoog'

    data.lines.each do |line|

      if line =~ /goog\.require\s*\(\s*[\'\"]([^\)]+)[\'\"]\s*\)/
        goog, mod, sub = $1.split(".")
        next if mod =~ /^Test/
        sub = mod if sub.nil?

        dep = [goog, mod, sub].compact.join("/").downcase
        environment.logger.info("REQUIRING: #{dep}")
        context.require_asset(dep)
      end
    end

    data
  end
end
