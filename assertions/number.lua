local numberAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);

	return dataType == "number", "TYPE_RESTRICTION_VIOLATION", "Number expected, got " .. dataType;
end);

return numberAssertion;
