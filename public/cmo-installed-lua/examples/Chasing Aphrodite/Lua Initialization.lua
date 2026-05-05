function BugMessage(eventName,description)
	ScenEdit_MsgBox('An issue occured with '..eventName..'.\n\n'..description..'\n\nThis will not affect system stability but may affect scenario balance.\n\nPlease report this in the Tech Support subforum on the Matrix Games forum, including a screenshot of this message.\n\nhttps://www.matrixgames.com/forums/viewforum.php?f=10230', 0)
end

function ChangeScore(side,amt,reason)
	local newScore = ScenEdit_GetScore(side) + amt
	ScenEdit_SetScore(side,newScore,reason)
	print (side..' score changed to '..newScore)
	return newScore
end