state("FEAR2", "Steam") {
	int gameLoading: 0x32E2E8;
	int hasControl: 0x002ED454, 0xA4, 0x1C, 0x3EC;
	int cutsceneWatcher: 0x2EF5DC;
	string3 mapName: 0x2F5F98;
}

state("FEAR2", "GOG") {
	int gameLoading: 0x2F4454;
	string3 mapName: 0x2F5F98;
}
	
init {
  //yoinked this from Gelly, who yoinked it from someone else
  //thanks for that
	byte[] exeMD5HashBytes = new byte[0];
		using (var md5 = System.Security.Cryptography.MD5.Create())
		{
			using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				exeMD5HashBytes = md5.ComputeHash(s); 
			} 
		}
	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	//print("MD5Hash: " + MD5Hash.ToString()); //Lets DebugView show me the MD5Hash of the game executable, which is actually useful.
	
	if (MD5Hash == "B99447BA544DB7B7B235333740CF5427") {
		version = "GOG";
	}
	
	if (MD5Hash == "54E27BA4855ADCE4A42B241FB2BF20AE") { 
		version = "Steam";
	}
	
	vars.isGameLoading = false;
	vars.setGameTime = false;
	vars.timerOffset = 48.983;
}

update {
	if (version == "GOG") {
		if (current.gameLoading == 0) {
			vars.isGameLoading = true;
		}
		
		else {
			vars.isGameLoading = false;
		}
	}
	
	if (version == "Steam") {
		if (current.gameLoading != 0) {
			vars.isGameLoading = true;
		}
		
		else {
			vars.isGameLoading = false;
		}
	}

start {
	if (current.mapName == "M01" && vars.isGameLoading.Current == false && vars.isGameLoading.Old == true) {
		vars.setGameTime = true;
		return true;
	}
}
	
split {
	return (current.mapName != old.mapName && old.mapName != "");
}

gameTime {
	if (vars.setGameTime == true) {
		vars.setGameTime = false;
		return TimeSpan.FromSeconds(-vars.timerOffset);
	}
}

isLoading {
	return vars.isGameLoading;
}

exit {
    timer.IsGameTimePaused = true;
}
