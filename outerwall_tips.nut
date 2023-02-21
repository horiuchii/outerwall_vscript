::DispenseTip <- function(client)
{
	local chance = RandomInt(1, 100);
	local message = "\x07" + "FF0000";
	
	local player_index = client.GetEntityIndex();
	
	message += TranslateString(OUTERWALL_TIP_PREFIX[RandomInt(0, OUTERWALL_TIP_PREFIX.len() - 1)], player_index) + "\x01" + " ";
	
	if(chance <= 1) //Crude Text 1%
		message += TranslateString(OUTERWALL_TIP_CRUDE[RandomInt(0, OUTERWALL_TIP_CRUDE.len() - 1)], player_index);
	else if(chance <= 11) //ParkourText 10%
		message += TranslateString(OUTERWALL_TIP_PARKOUR[RandomInt(0, OUTERWALL_TIP_PARKOUR.len() - 1)], player_index);
	else if(chance <= 21) //CrapText 10%
		message += TranslateString(OUTERWALL_TIP_CRAP[RandomInt(0, OUTERWALL_TIP_CRAP.len() - 1)], player_index);
	else
		message += TranslateString(OUTERWALL_TIP_REGULAR[RandomInt(0, OUTERWALL_TIP_REGULAR.len() - 1)], player_index);
		
	ClientPrint(client, HUD_PRINTTALK, message);
}