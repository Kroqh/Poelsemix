function SwapTeam( keys )
	local caster = keys.caster
	local target = keys.target

	AddFOWViewer(target:GetTeam(), target:GetAbsOrigin(), 5000, 5, false)

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
