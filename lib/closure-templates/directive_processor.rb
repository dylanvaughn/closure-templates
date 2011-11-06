class ClosureDependenciesProcessor < Tilt::Template
  def prepare; end

  def evaluate(context, locals, &block)
    Rails.logger.debug("Requiring google base")
    context.require_asset 'goog/base'
    Rails.logger.debug("Requiring google base")
    context.require_asset 'soyutils_usegoog'

    data.lines.each do |line|

      if line =~ /goog\.require\s*\(\s*[\'\"]([^\)]+)[\'\"]\s*\)/
        goog, mod, sub = $1.split(".")
        next if mod =~ /^Test/
        sub = mod if sub.nil?

        dep = [goog, mod, sub].compact.join("/").downcase
        Rails.logger.debug("REQUIRING: #{dep}")
        context.require_asset(dep)
      end
    end

    data
  end
end
