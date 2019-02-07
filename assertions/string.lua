local stringAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);
	
	return dataType == "string", "TYPE_RESTRICTION_VIOLATION", "String expected, got " .. dataType;
end);

stringAssertion.addSubAssertion("upToLength", function(data, length)
	return #data <= length, "SIZE_MISMATCH", "Expected string length up to " .. length .. ", got length of " .. #data;
end);

stringAssertion.addSubAssertion("contains", function(data, text)
	return data:find(text) ~= nil, "VALUE_MISMATCH", "Expected string containing substring '" .. text .. "'";
end);

return stringAssertion;
