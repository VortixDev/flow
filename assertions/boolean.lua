local booleanAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);

	return dataType == "boolean", "TYPE_RESTRICTION_VIOLATION", "Boolean expected, got " .. dataType;
end);

booleanAssertion.addSubAssertion("isTrue", function(data)
	return data == true, "VALUE_MISMATCH", "Expected true";
end);

booleanAssertion.addSubAssertion("isFalse", function(data)
	return data == false, "VALUE_MISMATCH", "Expected false";
end);

return booleanAssertion;
