/*
Title:           AdminPlus_v4 Mutator for Killing Floor
Creator:         Rythmix@Gmail.com - 11/08/2004
                 ported to Killing Floor by    RED-FROG  Red_Frog@web.de   May 30th, 2009
WebSite:         http://rythmix.zclans.com
                 http://www.levels4you.com
Add'l Content:   Based off of the AdminCheats and AdminUtils
                 mutators by mkhaos7 and James M. Poore Jr.
Add'14 Content   mutator by MaxLykoS August 10th,2019 , version 4
Features:  		 TempAdmin, ChangeName, CustomLoaded1,2,3(disabled), Godon/off,
                 GiveItem, PlayerSize, HeadSize, SetGrav, PrivMessage,
                 Reset Score, Change Score, Ghost/Fly/Spider/Walk, Summon,
                 Advanced Summon, Loaded, DNO, SloMo, Teleport,Cause Event
                 ChangePerk,WaveNum,SavePeople,ViewOn/Off,TraderTime,KillAllZeds
                 ClearLevel,RemoveItem,MaxMonsters,SetFakedPlayers,Fatality
                 HPConfig,SpawnMod,MaxPlayersNum
				-----------------------------------------------------------
				 Partial Name Recognition, 'ALL' Names Recognition
				 Applicable functions Work with Spectators, SuperAdmin
*/
class AdminPlus4Mut extends Mutator;   

//var config array<string> WeaponBase1;
//var config array<string> WeaponBase2;
//var config array<string> WeaponBase3;
var config array<string> SuperAdmin;
var config int iSlapDamage,iMaxZedsNum,iTraderTime,iFakedPlayer,iMaxPlayers,iHealthConfig,iStartCash;
var config float fSpawnMod;  
var array<string> nameArray;
//var config int iMomentum;

static function FillPlayInfo(PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);

 	PlayInfo.AddSetting(default.RulesGroup, "iSlapDamage","Slap Damage",1,0, "Text", "4;1:100",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "iMaxZedsNum","Max exited zeds count",1,0, "Text", "4;6:600",,,True);
 	PlayInfo.AddSetting(default.RulesGroup, "iTraderTime","Trader time count down",1,0, "Text", "6;6:1000",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "iFakedPlayer","Faked Player Count",1,0, "Text", "4;0:5",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "iMaxPlayers","Max player capacity",1,0, "Text", "4;0:99",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "iHealthConfig","Set zeds health scale.Set 0 if not want to change",1,0, "Text", "4;0:99",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "fSpawnMod","Multiply default spawn intervel.",1,0, "Text", "4;0:10",,,True);
  PlayInfo.AddSetting(default.RulesGroup, "iStartCash","Starting cash.Set -1 is not want to change.",1,0, "Text", "6;-1:999999",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "iSlapDamage":	return "Slap Damage";
		case "iMaxZedsNum":	return "Max exited zeds count";
		case "iTraderTime":	return "Trader time count down";
		case "iFakedPlayer":	return "Faked Player Count";
		case "iMaxPlayers":	return "Max player capacity";
		case "iHealthConfig":	return "Set zeds health scale.";
		case "fSpawnMod":	return "Multiply default spawn intervel.";
		case "iStartCash":	return "Starting cash.";
	}
	return Super.GetDescriptionText(PropName);
}

function int GetTruePlayerNum()
{
  local Controller C;
  local PlayerReplicationInfo PRI;
  local int i;

  i=0;
  for( C=Level.ControllerList;C!=None;C=C.NextController )
  {
    PRI = C.PlayerReplicationInfo;
    if( (PRI != None) && !PRI.bBot && MessagingSpectator(C) == None )
    {
      i++;
    }
  }
  return i;
}

function OnFakedPlayerChanged(int newVal)
{
  local int truePlayerNum;
  local KFGameType KFGT;
  truePlayerNum = GetTruePlayerNum();
  KFGT=KFGameType(Level.Game);
  if(KFGT!=none)
  {
    KFGT.NumPlayers=truePlayerNum+newVal;
  }
}

function MaxZedsNum(int maxNum)
{
	local KFGameType KFGT;
	KFGT=KFGameType(Level.Game);
	if(KFGT!=none)
	{
		maxNum = clamp(maxNum, 5, 254);
		KFGT.MaxZombiesOnce=maxNum;
		KFGT.StandardMaxZombiesOnce =maxNum;
		KFGT.MaxMonsters = Clamp(KFGT.TotalMaxMonsters,5,maxNum);		
		BroadcastMessage("Current MaxZedsNum : " $ string(KFGT.MaxMonsters)); 		
	}
}

function ModifyPlayer(Pawn Other)
{
	// called by GameInfo.RestartPlayer()
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);

    if(Other.PlayerReplicationInfo.Score<iStartCash)
      Other.PlayerReplicationInfo.Score = iStartCash;
}

function MaxPlayersNum(int maxNum)
{
	if ( maxNum > 0  ) 
	{
        Level.Game.MaxPlayers = maxNum;
        Level.Game.Default.MaxPlayers = maxNum;
        BroadcastMessage("Server max players " $ string(Level.Game.MaxPlayers) );
    }
}

function InitAPMut()
{
  local KFGameType KFGT;
  local int numPlayerCount;

  Level.Game.AccessControl.AdminClass = class'AdminPlus_v4.UltraAdmin';
  Level.Game.bAllowMPGameSpeed = true;

  KFGT = KFGameType(Level.Game);
  if(KFGT!=none)
  {
    KFGT.bNoBots=false;
    KFGT.TimeBetweenWaves=iTraderTime;  //trader time
    MaxZedsNum(iMaxZedsNum);    //max zeds num     
    MaxPlayersNum(iMaxPlayers);//max players
    if(iFakedPlayer>0)    //faked players
    {
      numPlayerCount = GetTruePlayerNum();
      KFGT.NumPlayers=iFakedPlayer;
      BroadcastMessage("Server faked players " $ string(iFakedPlayer) );
    }
    if(iStartCash>=0)//starting cash
    {
    	KFGT.StartingCash=iStartCash;
    	KFGT.MinRespawnCash=iStartCash/2;
    }
    BroadcastMessage("Server hp scale " $ string(iHealthConfig) );
    KFGT.KFLRules.WaveSpawnPeriod=2*fSpawnMod;//spawn mod
    BroadcastMessage("Current spawn mod is " $ string(fSpawnMod));
  }

  Level.Game.bAllowBehindView=true;
}

event PreBeginPlay()
{
	local GameRules GR;
  	Super.PreBeginPlay();

  	InitAPMut();

	GR = spawn(class'AdminPlusGameRules');
	AdminPlusGameRules(GR).ParentMutator = Self;
	if (Level.Game.GameRulesModifiers == None)
		Level.Game.GameRulesModifiers = GR;
	else Level.Game.GameRulesModifiers.AddGameRules(GR);

	SetTimer(5,false);
}

function Timer()
{
	KFGameType(Level.Game).TimeBetweenWaves=iTraderTime;
	SetTimer(0,false);
}


function BroadcastMessage(string Msg)
{
  local Controller P;
  local PlayerController Player;

  for ( P = Level.ControllerList; P != none; P = P.nextController ) 
  {
    Player = PlayerController(P);
    if ( Player != none ) 
    {
       Player.ClientMessage(Msg);
      }
  }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) 
{
	//local ZombieClot_STANDARD zcs;    //Test sound modification

    local float newHp, newHeadHp;
    local KFMonster monster;
    /**
     *  This solution works for the monsters even though KFMonster.PostBeginPlay()
     *  is called after CheckReplacement().  Mathematically, the code divides by 
     *  the current HealthModifer, multiplies the dividend with the new scale if larger, 
     *  then multiplies the current HealthModifer once PostBeginPlay() is called.
     *
     *  tempHp= currHp / oldHealthModifer();
     *  tempHp*= newHealthModifer(); = (currHp / oldHealthModifer()) * newHealthModifer()
     *
     *  ### if (tempHp > currHp) ###
     *  currHp= tempHp
     *  ### else ###
     *  currHp= currHp
     *
     *  ### PostBeginPlay() called ###
     *  currHp*= oldHealthModifer() = currHp * newHealthModifer() (Modified behavior)
     *  ### or (if tempHp <= currHp) ###
     *  currHp*= oldHealthModifer() (Original behavior)
     */
    
    if(iHealthConfig>=1)  //Health config
    {
      if(KFMonster(Other) != none)
      {
        monster= KFMonster(Other);
        newHp= monster.Health / monster.NumPlayersHealthModifer() * hpScale(monster.PlayerCountHealthScale);
        newHeadHp= monster.HeadHealth / monster.NumPlayersHeadHealthModifer() * hpScale(monster.PlayerNumHeadHealthScale);
        if(newHp > monster.Health) 
        {
          monster.Health= newHp;
          monster.HealthMax= newHp;
          monster.HeadHealth= newHeadHp;
          if(Level.Game.NumPlayers == 1 && iHealthConfig > 1) 
          {
            monster.MeleeDamage/= 0.75;
          }
        }
      }
    }

    //Test sound modification
    //zcs=ZombieClot_STANDARD(Other);
    //if(zcs!=none)
    //{
      //zcs.MoanVoice=Sound'KF_EnemiesFinalSnd.FP_Talk';
    //}
    //Test section
    return true;
}

function float hpScale(float hpScale) 
{
    return 1.0+(iHealthConfig-1)*hpScale;
}

function SetHpConfig(int num)
{
    iHealthConfig=num;
}

function Mutate(string MutateString, PlayerController Sender)
{
	local string playerName;
	local KFGameType KFGT;
	local int i;
	local bool found;
	if(MutateString=="aprdy")
	{
		KFGT=KFGameType(Level.Game);
		found=false;
		playerName = Sender.PlayerReplicationInfo.PlayerName;
		for(i=0;i<nameArray.length;i++)
		{
			if(nameArray[i]==playerName)
			{
				found=true;
				Sender.ClientMessage("You are already ready up.");
				return;
			}
		}
		if(!found)
		{
			nameArray.Insert(0,1);
			nameArray[0]=playerName;
			Sender.ServerSay(playerName$" is ready up.");
		}
		if(nameArray.length==GetTruePlayerNum())
		{
			KFGT.WaveCountDown=6;
			nameArray.length=0;
		}
	}

	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
	  iStartCash=100
  	fSpawnMod=1
  	iHealthConfig=0
  	iMaxPlayers=6
  	iFakedPlayer=0
  	iTraderTime=60
  	iSlapDamage=1
  	iMaxZedsNum=32
  	GroupName="KF-AdminPlus_v4"
  	FriendlyName="AdminPlus_v4"
  	Description="Let admin fully control this game."
}
