class AdminPlusGameRules extends GameRules;

var AdminPlus4Mut ParentMutator;

//kill callback
function ScoreKill(Controller Killer,Controller Killed)
{	
	//local Controller pc;

	if(KFMonsterController(Killed)!=none)
	{
		if(KFGameType(Level.Game).NumMonsters<=0&&KFGameType(Level.Game).TotalMaxMonsters<=0)
		{
            ParentMutator.BroadcastMessage("Wave ended.Type 'Mutate aprdy' to skip trader time.");
        }		
	}

    Super.ScoreKill(Killer, Killed);
}