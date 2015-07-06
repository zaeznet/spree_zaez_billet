# Verify if the input has the value
#
# @author Isabella Santos
#
# @param name [String]
# @param object [Object]
# @param value [String, Integer]
#
def verify_input_value(name, object, value, default = nil)
  expect(object[name]).to eq value
  expect(find_field(name).value).to eq value.to_s

  unless default.nil?
    object[name] = default
  end
end