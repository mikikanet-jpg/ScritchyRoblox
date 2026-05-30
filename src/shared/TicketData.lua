local TicketData = {

	Basic = {
		Price = 10,

		LoseChance = 50,
		WinChance = 35,
		JackpotChance = 5,

		MinReward = 15,
		MaxReward = 30,

		JackpotReward = 100
	},

	Silver = {
		Price = 750,

		LoseChance = 50,
		WinChance = 40,
		JackpotChance = 10,

		MinReward = 500,
		MaxReward = 2500,

		JackpotReward = 10000
	},

	Gold = {
		Price = 10000,

		LoseChance = 40,
		WinChance = 45,
		JackpotChance = 15,

		MinReward = 5000,
		MaxReward = 30000,

		JackpotReward = 100000
	}

}

return TicketData