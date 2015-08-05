class Time
  def long_format
    I18n.l self, :format => :long
  end
end

class ActiveSupport::HashWithIndifferentAccess
  def has_keys?(*check_keys)
    check_keys.to_a.any? {|key| has_key?(key)}
  end
end