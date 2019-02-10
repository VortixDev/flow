local assertionFactory = {};
local assertionMeta = {};

function assertionFactory.new(callback)
	local assertion = {};
	local subAssertions = {};

	setmetatable(assertion, assertionMeta);

	local function getCallback()
		return callback;
	end;

	function assertion.compose(joiningAssertion)
		local composedAssertion = assertionFactory.new(function(...)
			local originalStatus, originalType, originalMessage = assertion.run(...);

			if (not originalStatus) then
				return originalStatus, originalType, originalMessage;
			end;

			return joiningAssertion.run(...);
		end);

		local originalSubAssertions = assertion.getSubAssertions();

		for index, callback in pairs(originalSubAssertions) do
			composedAssertion.addSubAssertion(index, callback);
		end;

		local joiningSubAssertions = joiningAssertion.getSubAssertions();

		for index, callback in pairs(joiningSubAssertions) do
			composedAssertion.addSubAssertion(index, callback);
		end;

		return composedAssertion;
	end;

	function assertion.run(...)
		local callback = getCallback();

		return callback(...);
	end;

	function assertion.addSubAssertion(index, subAssertion)
		if (type(subAssertion) == "function") then
			subAssertion = flow.assertionFactory.new(subAssertion);
		end;

		subAssertions[index] = subAssertion;
	end;

	function assertion.removeSubAssertion(index)
		subAssertions[index] = nil;
	end;

	function assertion.getSubAssertions()
		return subAssertions;
	end;

	return assertion;
end;

function assertionMeta:__index(index, key)
	local subAssertions = self.getSubAssertions();

	if (subAssertions[index]) then
		return self.compose(subAssertions[index]);
	end;
end;

function assertionMeta:__call(...)
	local status, exceptionType, message = self.run(...);
	
	if (not status) then
		flow.throw(exceptionType, message, 2);
	end;
end;

return assertionFactory;
