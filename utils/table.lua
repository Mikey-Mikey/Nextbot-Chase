local function contains(list, value)
	for k, v in pairs(list) do
		if v == value then
			return true
		end
	end

	return false
end