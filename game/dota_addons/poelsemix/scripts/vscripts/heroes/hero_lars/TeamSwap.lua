function SwapTeam( keys )
	local caster = keys.caster
	local target = keys.target	
	LarsTeamNumb = caster:GetTeamNumber()
	TargetTeamNumb = target:GetTeamNumber()

	target:SetTeam(LarsTeamNumb)
	target:SetFriction(0)

end

function SwapBack( keys )
	local caster = keys.caster
	local target = keys.target

	target:SetTeam(TargetTeamNumb)

	
end
