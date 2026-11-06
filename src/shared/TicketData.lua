-- Todos los datos de los tickets. Lose y Win son el límite superior de una tirada del 1 al 100:
-- hasta Lose no hay premio, hasta Win hay premio normal y por encima hay jackpot.
local TicketData = {
	-- De menor a mayor. Auto Scratch usa primero el último que tenga.
	Order = { "Basic", "Silver", "Gold", "Pizza", "Space", "Zombie", "Final" },

	Basic = {
		Price = 10, UnlockLevel = 1,
		Lose = 35, Win = 90, Reward = 30, Jackpot = 100, JackpotText = "JACKPOT! +",
		AutoMin = 15, AutoMax = 30,
	},
	Silver = {
		Price = 750, UnlockLevel = 5,
		Lose = 25, Win = 85, Reward = 500, Jackpot = 1500, JackpotText = "JACKPOT PLATA! +",
		AutoMin = 500, AutoMax = 2500,
	},
	Gold = {
		Price = 10000, UnlockLevel = 15,
		Lose = 15, Win = 75, Reward = 25000, Jackpot = 50000, JackpotText = "JACKPOT ORO! +",
		AutoMin = 5000, AutoMax = 30000,
	},
	Pizza = {
		Price = 25000, UnlockLevel = 16,
		Lose = 30, Win = 85, Reward = 50000, Jackpot = 150000, JackpotText = "JACKPOT PIZZA! +",
		JackpotGift = { stat = "SilverTickets", amount = 3, text = "3 tickets Plata gratis" },
		AutoMin = 20000, AutoMax = 80000,
	},
	Space = {
		Price = 100000, UnlockLevel = 18,
		Lose = 30, Win = 85, Reward = 200000, Jackpot = 700000, JackpotText = "JACKPOT ESPACIO! +",
		JackpotGift = { stat = "GoldTickets", amount = 2, text = "2 tickets Oro gratis" },
		AutoMin = 80000, AutoMax = 320000,
	},
	Zombie = {
		Price = 500000, UnlockLevel = 20,
		Lose = 50, Win = 90, Reward = 1000000, Jackpot = 6000000, JackpotText = "JACKPOT ZOMBI! +",
		JackpotGift = { stat = "ZombieTickets", amount = 2, text = "2 tickets Zombi gratis" },
		AutoMin = 200000, AutoMax = 1500000,
	},
	-- El objetivo del juego: siempre se gana y solo se puede completar una vez.
	Final = {
		Price = 10000000, UnlockLevel = 20, UnlockPrestige = 1, IsFinal = true,
		Reward = 5000000,
	},
}

return TicketData
