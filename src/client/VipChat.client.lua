-- Pone [VIP] en dorado delante del nombre en el chat de quien tiene el pase VIP.
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	local source = message.TextSource
	local sender = source and Players:GetPlayerByUserId(source.UserId)
	if sender and sender:GetAttribute("PassVIP") == true then
		properties.PrefixText = '<font color="#FCD34D">[VIP]</font> ' .. message.PrefixText
	end
	return properties
end
