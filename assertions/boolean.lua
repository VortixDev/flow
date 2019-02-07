local booleanAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);

	return dataType == "boolean", "TYPE_RESTRICTION_VIOLATION", "Boolean expected, got " .. dataType;
end);

return booleanAssertion;
