Puppet::Functions.create_function('gitlab::cirunner::cmd_str') do
  dispatch :cmd_str do
    param 'String', :name
    param 'Array', :values
    return_type 'String'
  end
  def cmd_str(name, values)
    values.each do |value|
      return "--#{name} #{value}" if value.is_a?(String) && !value.empty?
      return "--#{name} #{value}" if value.is_a?(Integer)
      return "--#{name} #{value.join(',')}" if value.is_a?(Array) && !value.empty?
      return "--#{name}" if value.is_a?(TrueClass)
      return '' if value.is_a?(FalseClass)
    end
    ''
  end
end
