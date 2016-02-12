Puppet::Functions.create_function('gitlab::cirunner::cmd_str') do
  dispatch :cmd_str do
    param 'String', :name
    param 'Array', :values
    # only avalible in puppet 4.7
    # return_type 'String'
  end
  def cmd_str(name, values)
    values.each do |value|
      if value.is_a?(String) && !value.empty?
        return "--#{name} #{value}"
      elsif value.is_a?(Integer)
        return "--#{name} #{value}"
      elsif value.is_a?(Array) && !value.empty?
        return "--#{name} #{value.join(',')}"
      elsif value.is_a?(TrueClass)
        return "--#{name}"
      elsif value.is_a?(FalseClass)
        return ''
      end
    end
    ''
  end
end
