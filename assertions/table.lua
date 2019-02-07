local tableAssertion = flow.assertionFactory.new(function(data)
	local dataType = type(data);

	return dataType == "table", "TYPE_RESTRICTION_VIOLATION", "Table expected, got " .. dataType;
end);

tableAssertion.addSubAssertion("hasValueCount", function(data, count)
	local valueCount = 0;

	for k, v in pairs(data) do
		valueCount = valueCount + 1;
	end;

	return valueCount == count, "SIZE_MISMATCH", "Expected table of size " .. count .. ", got size of " .. valueCount;
end);

tableAssertion.addSubAssertion("isEmpty", function(data)
	local valueCount = 0;

	for k, v in pairs(data) do
		valueCount = valueCount + 1;
	end;

	return valueCount == 0, "SIZE_MISMATCH", "Expected table of size " .. count .. ", got size of " .. valueCount;
end);

return tableAssertion;
