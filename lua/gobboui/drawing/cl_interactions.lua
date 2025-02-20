
GOBBO.RegisterFont("UI.Interactions", "Sonny Vol 2", 25)

-- TODO: Convert to use pixel ui funcs
function GOBBO.DrawKeyInteraction(key, text)
	-- Key Box
	local scrW, scrH = ScrW(), ScrH()

	local textMarginLeftX = 8 -- Margin of the text from the box ( left )

	local boxWidth, boxHeight = 32, 32 -- Size of the main box

	local xOffset = scrW / 2

	if (text) then
		GOBBO.SetFont("UI.Interactions")
		local textWidth, _ = GOBBO.GetTextSize(text)

		xOffset = xOffset - (boxWidth + textWidth) / 2 - textMarginLeftX
	end

	local yOffset = scrH * 0.65
	GOBBO.DrawRoundedBox(6, xOffset, scrH * 0.65, boxWidth, boxHeight, Color(41, 41, 41, 200))

	local keyBoxWidth, keyBoxHeight = boxWidth - 4, boxHeight - 4
	local padding = (boxHeight - keyBoxHeight) / 2 -- x and y padding of the key box, 40 - 36 / 2 = 2 ( 2 from the left, top, right and bottom ) so its centered
	GOBBO.DrawRoundedBox(4, xOffset + padding, yOffset + padding, keyBoxWidth, keyBoxHeight, Color(60, 60, 60))

	-- Key Text
	GOBBO.SetFont("UI.Interactions")
	local textWidth, _ = GOBBO.GetTextSize(key)
	local yPosition = yOffset + (boxHeight / 2) - padding + 1 -- yOffset + (boxHeight / 2) - (boxHeight - keyBoxHeight) / 2
	GOBBO.DrawShadowText(key, "UI.Interactions", xOffset + (boxWidth / 2) - (textWidth / 2), yPosition, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3)

	if (text) then
		GOBBO.DrawShadowText(text, "UI.Interactions", xOffset + boxWidth + textMarginLeftX, yPosition, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3)
	end
end