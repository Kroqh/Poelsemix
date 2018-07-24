function FindDistance(unit1, unit2)
	local pos1 = unit1
	local pos2 = unit2

	local distanceDifference = (pos1 - pos2):Length2D()
	return distanceDifference
end