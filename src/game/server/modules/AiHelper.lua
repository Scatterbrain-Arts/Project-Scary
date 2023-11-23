local AiHelper = {}

function AiHelper:GetValue(entity, attributeName, isDebug)
	local attribute = entity:GetAttribute(attributeName)

	if isDebug then
		if attribute ~= nil then
			print(string.upper(attributeName), "set to", attribute, "for", entity.name, "...")
		else
			warn("Create attribute \"", attributeName, "\"; Using Default value...")
		end
	end

	return attribute
end

function AiHelper:GetCondition(entity, attributeName)
	local isAttribute = entity:GetAttribute(attributeName)

	if isAttribute then
		warn(attributeName, "enabled for", entity.name, "...")
	elseif isAttribute == false then
		warn(attributeName, "disabled for", entity.name, "...")
	elseif isAttribute == nil then
		warn("Create attribute \"", attributeName , "\" for", entity.name, "; Using Default value...")
	end

	return isAttribute
end


function AiHelper:SetNetworkOwner(entity, owner)
	owner = owner or nil
	for _, part in pairs(entity:GetChildren()) do
		if part:IsA("BasePart") then
			part:SetNetworkOwner(owner)
		end
	end
end


return AiHelper