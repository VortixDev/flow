local nilAssertion = flow.assertionFactory.new(function(data)
	return data == nil, "TYPE_RESTRICTION_VIOLATION", "Nil expected, got " .. type(data);
end);

return nilAssertion;
