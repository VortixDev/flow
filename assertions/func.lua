local funcAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);

	return dataType == "function", "TYPE_RESTRICTION_VIOLATION", "Function expected, got " .. dataType;
end);

return funcAssertion;
