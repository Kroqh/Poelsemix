local json = require("dkjson")

connection = connection or class({})

local url = "https://westeurope.azure.data.mongodb-api.com/app/data-mgxzs/endpoint/data/v1/action/"
local apiKey = "Hidden for upload"
local collection = "matches"
local database = "matchData"
local dataSource = "matchData"
local timeout_limit = 9999


function connection:FinishGame()
	print("Game finished, attempting api insert")
	local players = {}

	for id = 0, PlayerResource:GetPlayerCount() - 1 do
		if PlayerResource:IsValidPlayerID(id) then

			local heroEntity = PlayerResource:GetSelectedHeroEntity(id)
            if heroEntity ~= nil then
				hero = tostring(heroEntity:GetUnitName())
			end

			local player = {
				id = id,
				kills = tonumber(PlayerResource:GetKills(id)),
				hero = hero,
			}

			players[id] = player
		end
	end
    local document = {
        match_id = GameRules:Script_GetMatchID(),
		players = players,
    }

	local payload = {
		document = document
        database = database
        dataSource = dataSource
        collection = collection
	}

	self:CreateRequest("insertOne", "POST",  payload)
end


function connection:CreateRequest(urlPoint, crud, payload)

	local httpRequest = CreateHTTPRequest(crud, url + urlpoint)

	if httpRequest == nil then
		native_print("Http request failed")
	end

	httpRequest:SetHTTPRequestAbsoluteTimeoutMS(timeout)
	httpRequest:SetHTTPRequestHeaderValue("api-key", apiKey)
	httpRequest:SetHTTPRequestHeaderValue("Access-Control-Request-Headers", "*")

	if payload ~= nil then
		local payloadJSON = json.encode(payload)
		httpRequest:SetHTTPRequestRawPostBody("application/json", payloadJSON)
	end

	print("sending httpRequest")
	httpRequest:Send(function(result)
		
		local code = result.StatusCode;
        print(result)
		print("Request result:", code)

		if code == 0 then
			print("API Request failed Timeout")
		elseif code == 204 then 
			print("Match saved succesfully")
		else
			print("API Request failed Unknown error of code: " + tostring(code))
		end
	end)
end
