/*
Title:           AdminPlus_v4 Mutator for Killing Floor
Creator:         Rythmix@Gmail.com - 11/08/2004
                 ported to Killing Floor by    RED-FROG  Red_Frog@web.de   May 30th, 2009
WebSite:         http://rythmix.zclans.com
                 http://www.levels4you.com
Add'l Content:   Based off of the AdminCheats and AdminUtils
                 mutators by mkhaos7 and James M. Poore Jr.
Add'14 Content   mutator by MaxLykoS August 10th,2019 , version 4
Features:  		   TempAdmin, ChangeName, CustomLoaded1,2,3(disabled), Godon/off,
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
class UltraAdmin extends Admin;

var localized string MSG_LoadedOn;
var localized string MSG_GodOn;
var localized string MSG_GodOff;
var localized string MSG_Ghost;
var localized string MSG_Fly;
var localized string MSG_ChangeScore;
var localized string MSG_Spider;
var localized string MSG_Walk;
var localized string MSG_InvisOn;
var localized string MSG_InvisOff;
var localized string MSG_TempAdmin;
var localized string MSG_TempAdminOff;
var localized string MSG_ChangeName;
var localized string MSG_ChangeSize;
var localized string MSG_GiveItem;
var localized string MSG_Adrenaline;
var localized string MSG_Help1;
var localized string MSG_Help2;
var localized string MSG_Help3;
var localized string MSG_Help4;
var localized string MSG_Help5;
var localized string MSG_Help6;
var localized string MSG_Help7;
var localized string MSG_Help8;
var localized string MSG_Help9;
var localized string MSG_Help10;
var localized string MSG_Help11;
var localized string MSG_Help12;
var localized string MSG_Help13;
var localized string MSG_Help14;
var localized string MSG_Help15;
//var localized string MSG_Help16;
//var localized string MSG_Help17;
//var localized string MSG_Help18;
var localized string MSG_Help19;
//var localized string MSG_Help20;
var localized string MSG_Help21;
var localized string MSG_Help22;
var localized string MSG_Help23;
var localized string MSG_Help24;
var localized string MSG_Help25;
var localized string MSG_Help26;
var localized string MSG_Help27;
var localized string MSG_Help28;
var localized string MSG_Help29;
var localized string MSG_Help30;
var localized string MSG_Help31;
var localized string MSG_Help32;
var localized string MSG_Help33;
var localized string MSG_Help34;
var localized string MSG_Help35;
var localized string MSG_Help36;
var localized string MSG_Help37;
var localized string MSG_Help38;
var localized string MSG_Help39;
var localized string MSG_Help40;
var localized string MSG_Help41;
var localized string MSG_Help42;
var localized string MSG_Help43;
var localized string MSG_Help44;
var localized string MSG_Help45;
var localized string MSG_Help46;
var localized string MSG_Help47;
var localized string MSG_Help48;
var localized string MSG_Help49;
var localized string MSG_Help50;
var localized string MSG_ReSpawned;
var localized string MSG_CantRespawn;
var xEmitter LeftTrail, RightTrail, HeadTrail;
//var CrateActor Effect;
var int NumDoubles;
//var Bot Doubles[4];

//========================================================================================
// Really Crappy version of the admin.uc file to allow temp admins on single admin systems
//========================================================================================
function DoLogin( string Username, string Password )
{
	if (Level.Game.AccessControl.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
		Level.Game.AccessControl.AdminEntered(Outer, "");
    ClientMessage("Type Admin Help for more hints.");
	}
  if ( outer.PlayerReplicationInfo.bAdmin == true && !Level.Game.AccessControl.AdminLogin(Outer, Username, Password))
  {
    Level.Game.AccessControl.AdminLogout(Outer);
    Level.Game.AccessControl.AdminLogin(outer, "ut2004", Level.Game.AccessControl.Users.Get(0).Password);
	  Level.Game.AccessControl.AdminEntered(outer, "");
	  bAdmin = true;
    ClientMessage("Type Admin Help for more hints.");
	}
}

function DoLogout()
{
	if (Level.Game.AccessControl.AdminLogout(Outer))
	{
		bAdmin = false;
		Level.Game.AccessControl.AdminExited(Outer);
	}
}

//=======================================================
//finds the mutator of a given class starting from the given Mutator
//original text from admincheats
function Mutator findMut(Mutator M, class MC)
{
    if (M.Class ==  MC)
        return M;
    else if (M != None)
        return findMut(M.NextMutator,MC);
    else
        return None;
}

//Gives back the Pawn associated with a player name 
function Pawn findPlayerByName(string PName)
{ 
   	local Controller C; 
   	local int namematch; 
        
   	for( C = Level.ControllerList; C != None; C = C.nextController )
    { 
    	if( C.IsA('PlayerController') || C.IsA('xBot'))
        {
        	If (Len(C.PlayerReplicationInfo.PlayerName) >= 3 && Len(PName) < 3)
           	{
            	Log("Must be longer than 3 characters");
           	} 
            else
            {
           		namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(PName)); 
              	if (namematch >=0) 
              	{ 
                	return C.Pawn; 
           		}
        	}
     	} 
    } 
    return none;
}

//Gives back the Pawn associated with a full player name 
function Pawn findPlayerByFullName(string PName)
{
    local Controller C;  
        
    if(PName=="")
      	return none;

    for( C = Level.ControllerList; C != None; C = C.nextController )
    {
      	if( C.IsA('PlayerController') || C.IsA('xBot'))
      	{
        	if(C.PlayerReplicationInfo.PlayerName==PName)
          	return C.Pawn;
      	}
    }
    ClientMessage(PName $" is not currently in the game." );
    return none;
}

//Verify that the target of our functions exists
//If no target is specified, apply the function to ourselves
//original text from admincheats
function Pawn verifyTarget(string target) 
{
    local Pawn p;
	
	if (target == "")
        return Pawn;
    else
        p = findPlayerByName(target);
        if (p == None)
            ClientMessage(target $" is not currently in the game." );
        return p;
}

//Verify that the target of our functions exists
//If no target is specified, apply the function to ourselves
//original text from admincheats
function Controller verifyCont(string target) 
{
	local Controller C;
	local int namematch;
	
	if (target == "")
	{
       return c;
    }
    else
    {
    	for( C = Level.ControllerList; C != None; C = C.nextController ) 
    	{
       		if( C.IsA('PlayerController') || C.IsA('xBot')) 
       		{
       			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
        		if (namematch < 0) 
        		{ 
          			ClientMessage(target $" is not currently in the game." );
       				return C;
          		}
       		}
    	} 
	}
}

//================================================
//Make Target a Temp Admin
exec function TempAdmin(string target)
{
	local Mutator myMut;
    local Controller C; 
    local int namematch;
    local Pawn p;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    
    if (myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).TempAdminEnabled()) 
    	//{        	
          	if (target == "all") 
          	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  		  	if (C.playerreplicationinfo.bAdmin != TRUE)
          	  		  	{
          	  		  		PlayerController(C).ClientMessage(MSG_TempAdmin);
          	  		  		C.playerreplicationinfo.bAdmin = true;
          	  		  		if (pawn != none)
          	  		  		{
          	  		  			C.Pawn.PlayTeleportEffect(true, true);
          	  		  		}
                      	}
          	  	  	}
          	  	}
          	  	return;
          	} 
          	else if (target == "")
          	{
          		P = verifyTarget(target);
        		P.ClientMessage(MSG_TempAdmin);
        		P.PlayTeleportEffect(true, true);
                p.playerreplicationinfo.bAdmin = true;
        		return;
        	} 
        	else 
        	{      		
        		for( C = Level.ControllerList; C != None; C = C.nextController ) 
        		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					PlayerController(C).ClientMessage(MSG_TempAdmin);
          	  		  		C.playerreplicationinfo.bAdmin = true;
          	  		  		if (pawn != none)
          	  		  		{
          	  		  			C.Pawn.PlayTeleportEffect(true, true);
          	  		  		}
          				}
          			}
          		}
				return;
       		}
   		//}
	}
}

//================================================
//Remove Target Temp Admin abilities
exec function TempAdminOff(string target)
{
    local Mutator myMut;
    local Controller C;
    local string A;
    local int i;
  local int namematch;
  local int adminmatch;
  local Pawn p;
  
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
      //if (AdminPlus4Mut(myMut).TempAdminEnabled()) {
            if (target == "all") {
                for( C = Level.ControllerList; C != None; C = C.nextController ) {
                    if( C.IsA('PlayerController') || C.IsA('xBot')) {
                    for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.SuperAdmin.Length; i++) {
                      A = (class'AdminPlus_v4.AdminPlus4Mut'.default.SuperAdmin[i]);
                    adminmatch = InStr( Caps(A), Caps(C.PlayerReplicationInfo.PlayerName));
                    if (adminmatch >=0) { 
                        ClientMessage("~AdminPlus: Trying to Disable a SuperAdmin is not allowed");
                      } else {
                        PlayerController(C).ClientMessage(MSG_TempAdminOff);
                    C.playerreplicationinfo.bAdmin = false;
                    if (pawn != none){
                          C.Pawn.PlayTeleportEffect(true, true);
                          }
                  }
                }
                    }
                }
                return;
            } else if (target == ""){
              P = verifyTarget(target);
            P.ClientMessage("Use AdminLogout to exit Admin mode");
            //P.playerreplicationinfo.bAdmin = false;
            return;
          } else {
              for( C = Level.ControllerList; C != None; C = C.nextController ) {
                  if( C.IsA('PlayerController') || C.IsA('xBot')) {
                  namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
                  if (namematch >=0) { 
                    for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.SuperAdmin.Length; i++) {
                        A = (class'AdminPlus_v4.AdminPlus4Mut'.default.SuperAdmin[i]);
                      adminmatch = InStr( Caps(A), Caps(C.PlayerReplicationInfo.PlayerName));
                      if (adminmatch >=0) { 
                          ClientMessage("~AdminPlus: Trying to Disable a SuperAdmin is not allowed!");
                          //return;
                        }
                      }   
                      PlayerController(C).ClientMessage(MSG_TempAdminOff);
                  C.playerreplicationinfo.bAdmin = false;
                  if (pawn != none){
                          C.Pawn.PlayTeleportEffect(true, true);
                        }
                  }
                }
              }
          }
    //}
  }
}

//Slap that guys bothering you and do 1 point of damage from him
exec function Slap(string target)
{
	local Mutator myMut;
    local Pawn p;
    local Controller C;
    //local int i;
	local int namematch;
	local int iSlapDmg;
	//local int iMom;
	
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus_v4(myMut).SlapEnabled()) 
    	//{
    		iSlapDmg = 2*(class'AdminPlus_v4.AdminPlus4Mut'.default.iSlapDamage);
    		//iMom = (class'AdminPlus_v4.AdminPlus4Mut'.default.iMomentum);
    		if (target == "all") 
    		{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  		  	C.Pawn.ClientMessage("You've been Pimp slapped");
					  	ServerSay(Pawn.PlayerReplicationInfo.PlayerName$ " PimpSlaps " $ C.PlayerReplicationInfo.PlayerName $ " like a bitch!");
           				//Slap... but don't kill
           				if (C.Pawn.Health > 1)
           				{
           					C.Pawn.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
           					C.Pawn.PlayTeleportEffect(true, true);
           				}
          	  	  	}
          	  	}
          	  	return;
          	} 
          	else if (target == "")
          	{
        		P = verifyTarget(target);
        		P.ClientMessage("You've been Pimp slapped!");
				ServerSay(Pawn.PlayerReplicationInfo.PlayerName$ " PimpSlaps Himself like a bitch!");
           		//Slap... but don't kill
           		if (P.Health > 1)
           		{
           			P.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
           			P.PlayTeleportEffect(true, true);
           		}
        		return;
        	} 
        	else 
        	{
          		P = verifyTarget(target);
          		if (P == none)
          		{
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.ClientMessage("You've been Pimp slapped!");
					  		ServerSay(Pawn.PlayerReplicationInfo.PlayerName$ " PimpSlaps " $ C.Pawn.PlayerReplicationInfo.PlayerName $ " like a bitch!");
           					//Slap... but don't kill
           					if (C.Pawn.Health > 1)
           					{
           						C.Pawn.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
           						C.Pawn.PlayTeleportEffect(true, true);
           					}
          				}
          			}
          		}
       		}
        //}
    }
}

//================================================
//Change Player's Name
exec function ChangeName(string target, string NewName)
{
    local Mutator myMut;
	local Controller C;
	local int namematch;
	
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).ChangeNameEnabled()) 
    	//{
        	if (NewName != "")
        	{
        		for( C = Level.ControllerList; C != None; C = C.nextController ) 
        		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					PlayerController(C).ClientMessage(MSG_ChangeName);
							C.playerreplicationinfo.PlayerName = NewName;
          				}
          			}
          		}
          	} else 
          	{
          		ClientMessage("You must enter a new name for the player");
          	}
        //}
    }
}
//Change Player's Name
//================================================
function ReSpawnRoutine(PlayerController C)
{
	if (C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.bOutOfLives)
	{
		Level.Game.Disable('Timer');
		C.PlayerReplicationInfo.bOutOfLives = false;
		C.PlayerReplicationInfo.NumLives = 0;
		C.PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash, int(C.PlayerReplicationInfo.Score));
		C.GotoState('PlayerWaiting');
		C.SetViewTarget(C);
		C.ClientSetBehindView(false);
		C.bBehindView = False;
		C.ClientSetViewTarget(C.Pawn);
		Invasion(Level.Game).bWaveInProgress = false;
		C.ServerReStartPlayer();
		Invasion(Level.Game).bWaveInProgress = true;
		Level.Game.Enable('Timer');
		C.ClientMessage(MSG_ReSpawned);
	}
}
//================================================
exec function ReSpawn(string target)
{
    local Mutator myMut;
	local Controller C;
	local int namematch;
	
	log("ReSpawn"@target);
	
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none)
	{
		if (Invasion(Level.Game).bWaveInProgress==false) // Запретить респавн между волнами
		{
       		target = PlayerReplicationInfo.PlayerName;
          	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	{
          		namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          		if (namematch >=0)
				{
					PlayerController(C).ClientMessage(MSG_CantRespawn);
        			return;
    			}
			}
		}
		for( C = Level.ControllerList; C != None; C = C.nextController )
		{
			if( C.IsA('PlayerController') || C.IsA('xBot') )
			{
				if (Target=="all")
				{
					ReSpawnRoutine(PlayerController(C));
				}
				else
				{
					namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
					if (namematch >=0)
						ReSpawnRoutine(PlayerController(C));
				}
					/*
					if( PlayerController(C)!=None && (C.Pawn==None || C.Pawn.Health<=0) && !C.PlayerReplicationInfo.bOnlySpectator )
					{
						C.GotoState('PlayerWaiting');
						C.PlayerReplicationInfo.bOutOfLives = false;
						C.PlayerReplicationInfo.NumLives = 0;
						C.ServerReStartPlayer();
						PlayerController(C).ClientSetViewTarget(C.Pawn);
						PlayerController(C).SetViewTarget(C.Pawn);
					}
					*/
				/*	
					
					if ( !C.PlayerReplicationInfo.bOnlySpectator )
					{
						log("PlayerNotOnlySpectator");
						PlayerController(C).ClientMessage(MSG_ReSpawned);
						C.PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash,int(C.PlayerReplicationInfo.Score));

						if( PlayerController(C) != none )
						{
							log("PlayerController!=none");
							PlayerController(C).GotoState('PlayerWaiting');
							PlayerController(C).SetViewTarget(C);
							PlayerController(C).ClientSetBehindView(false);
							PlayerController(C).bBehindView = False;
							PlayerController(C).ClientSetViewTarget(C.Pawn);
						}
						log("ServerRestartPlayer");
						C.ServerReStartPlayer();
					}
					//C.playerreplicationinfo.PlayerName = NewName;
					*/
			}
		}
    }
}
//================================================
//Send a Private Message to a player
exec function PrivMessage(string target, string APMessage)
{
    local Mutator myMut;
	local Controller C;
	local int namematch;
	local int v;
	
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).PrivMessageEnabled()) 
    	//{
        	v = 0;
        	for( C = Level.ControllerList; C != None; C = C.nextController ) 
        	{
          	    if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    {
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
               		if (namematch >=0) 
               		{ 
          				v = v++;
          				PlayerController(C).ClientMessage("Private Message from Admin: "$APMessage);
           			}
          		}
          	}
          	if (v == 0)
          	{
          			ClientMessage(target$" is not in the game");
          	}
        //}
    }       
}

exec function PM (string target, String PMMessage)
{
	PrivMessage(target, PMMessage);
}
exec function GI (string item, String ItemName)
{
	GiveItem(item, ItemName);
}
exec function CN (string target, String NewName)
{
	ChangeName(target, NewName);
}
exec function SG ( float gr)
{
	SetGravity(gr);
}
/*exec function CL1 ( string target ){
	CustomLoaded1(target);
}
exec function CL2 ( string target ){
	CustomLoaded2(target);
}
exec function CL3 ( string target ){
	CustomLoaded3(target);
}*/

//================================================
//Change Player's Head Size
exec function HeadSize(string target,float newHeadSize)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;
	
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
       	//if (AdminPlus4Mut(myMut).ChangeSizeEnabled())
       	//{      
          	if (target == "all")
          	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  		  	if(pawn != none)
          	  		  	{
          	  		  		C.Pawn.ClientMessage(MSG_ChangeSize);
					  		C.Pawn.headscale = newHeadSize;
					  		C.Pawn.PlayTeleportEffect(true, true);
					  	}
          	  	  	}
          	  	}
          	  	return;
          	} 
          	else if (target == "")
          	{
        		P = verifyTarget(target);
        		P.ClientMessage(MSG_ChangeSize);
        		P.PlayTeleportEffect(true, true);
				P.headscale = newHeadSize;
        		return;
        	} 
        	else 
        	{
          		P = verifyTarget(target);
          		if (P == none)
          		{
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					if(pawn != none)
          					{
          						C.Pawn.ClientMessage(MSG_ChangeSize);
								C.Pawn.headscale = newHeadSize;
								C.Pawn.PlayTeleportEffect(true, true);
					  		}
          				}
          			}
          		}
       		}
   		//}
	}
}



//================================================
//Change Player's Size
exec function PlayerSize(string target,float newPlayerSize)
{
  local Mutator myMut;
  local Controller C;
  local int namematch;
  local Pawn p;
  local float oldsize;
	
  myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  if (myMut != none) 
  {
  //if (AdminPlus4Mut(myMut).ChangeSizeEnabled())
  //{         	
      oldsize = C.Pawn.DrawScale;
      if (newPlayerSize == 0 || newPlayerSize > 5)
      {
        ClientMessage("PlayerSize Cannot be 0 or greater than 5, causes game to crash");
        return;
      }
          	
      if (target == "all") 
      {
        for( C = Level.ControllerList; C != None; C = C.nextController ) 
        {
          if( C.IsA('PlayerController') || C.IsA('xBot')) 
          {
          	if ((newPlayerSize < oldsize) || (oldsize == 0))
          	{
         			C.Pawn.SetDrawScale((P.DrawScale * 0) + 1);
         		}
					  if (pawn != none)
					  {	
					  	C.Pawn.SetDrawScale(C.Pawn.DrawScale * newPlayerSize);
							C.Pawn.SetCollisionSize(C.Pawn.CollisionRadius * newPlayerSize, C.Pawn.CollisionHeight * newPlayerSize);
							C.Pawn.BaseEyeHeight *= newPlayerSize;
							C.Pawn.EyeHeight     *= newPlayerSize;
							C.Pawn.PlayTeleportEffect(true, true);
						//C.Pawn.bCanCrouch = False;
						//C.Pawn.CrouchHeight  *= newPlayerSize;
						//C.Pawn.CrouchRadius  *= newPlayerSize;
						}
          }
        }
        return;
      } 
      else if (target == "")
      {
        P = verifyTarget(target);
        P.ClientMessage(MSG_ChangeSize);
				if ((newPlayerSize < oldsize) || (oldsize == 0))
				{
         	P.SetDrawScale((P.DrawScale * 0) + 1);
        }
				P.SetDrawScale(P.DrawScale * newPlayerSize);
				P.SetCollisionSize(P.CollisionRadius * newPlayerSize, P.CollisionHeight * newPlayerSize);
				P.BaseEyeHeight *= newPlayerSize;
				P.EyeHeight     *= newPlayerSize;
			//P.bCanCrouch = False;
				P.PlayTeleportEffect(true, true);
			//P.CrouchHeight  *= newPlayerSize;
			//P.CrouchRadius  *= newPlayerSize;
				return;
      } 
      else 
      {
        P = verifyTarget(target);
        if (P == none)
        {
          return;
        }
        for( C = Level.ControllerList; C != None; C = C.nextController ) 
        {
          if( C.IsA('PlayerController') || C.IsA('xBot')) 
          {
          	namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          	if (namematch >=0) 
          	{ 
          		C.Pawn.ClientMessage(MSG_ChangeSize);
							if ((newPlayerSize < oldsize) || (oldsize == 0))
							{
         				C.Pawn.SetDrawScale((P.DrawScale * 0) + 1);
         			}
							if (pawn != none)
							{
								C.Pawn.SetDrawScale(C.Pawn.DrawScale * newPlayerSize);
								C.Pawn.SetCollisionSize(C.Pawn.CollisionRadius * newPlayerSize, C.Pawn.CollisionHeight * newPlayerSize);
								C.Pawn.BaseEyeHeight *= newPlayerSize;
								C.Pawn.EyeHeight     *= newPlayerSize;
						  //C.Pawn.bCanCrouch = False;
								C.Pawn.PlayTeleportEffect(true, true);
							//C.Pawn.CrouchHeight  *= newPlayerSize;
							//C.Pawn.CrouchRadius  *= newPlayerSize;
							}
          	}
          }
        }
      }
  //}
	}
}


//================================================
//Put Target In God Mode
exec function GodOn(string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
       	//if (AdminPlus4Mut(myMut).GodEnabled())
       	//{        	
          	if (target == "all") 
          	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  		  	C.bGodMode = true;
                		PlayerController(C).ClientMessage(MSG_GodOn);
                		C.Pawn.PlayTeleportEffect(true, true);
          	  	  	}
          	  	}
          	  	ServerSay("Everyone is in God mode");
          	  	return;
          	} 
          	else if (target == "")
          	{
        		  target = PlayerReplicationInfo.PlayerName;
          		log(target);
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          			if (namematch >=0) 
          			{
		       			C.bGodMode = true;
                		PlayerController(C).ClientMessage(MSG_GodOn);
                		C.Pawn.PlayTeleportEffect(true, true);
                		return;
                	}
                }
                ServerSay(target$ " is in God mode");
        		return;
        	} 
        	else 
        	{
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.bGodMode = true;
                			PlayerController(C).ClientMessage(MSG_GodOn);
                			C.Pawn.PlayTeleportEffect(true, true);
                			ServerSay(C.PlayerReplicationInfo.PlayerName$ " is in God mode");
          				}
          			}
          		}
       		}
   		//}
	}
}

//Take Target Out Of God Mode
exec function GodOff(string target){
    local Mutator myMut;
    local Controller C;
    local int namematch;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
       	//if (AdminPlus4Mut(myMut).GodEnabled())
       	//{
          	
          	if (target == "all") 
          	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  			C.bGodMode = false;
                		PlayerController(C).ClientMessage(MSG_GodOff);
                		C.Pawn.PlayTeleportEffect(true, true);
          	  	  	}
          	  	}
          	  	ServerSay("All Players are out of God Mode");
          	  	return;
          	} 
          	else if (target == "")
          	{
           		target = PlayerReplicationInfo.PlayerName;
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          			if (namematch >=0) 
          			{
		       			C.bGodMode = false;
                		PlayerController(C).ClientMessage(MSG_GodOff);
                		C.Pawn.PlayTeleportEffect(true, true);
                	}
                }
                ServerSay(target$ " is out of God mode");
        		return;
        	} 
        	else 
        	{          
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					if ( C.bGodMode == false)
          					{
       							return;
          					}
          					C.bGodMode = false;
                			PlayerController(C).ClientMessage(MSG_GodOff);
                			ServerSay(C.PlayerReplicationInfo.PlayerName$ " is out of God Mode");
                			C.Pawn.PlayTeleportEffect(true, true);
          				}
          			}
          		}
       		}
   		//}
	}
}


//================================================
//Change a Player's Score
exec function ChangeScore(string target, float newScoreValue){
    local Mutator myMut;
    local Controller C;
    local int namematch;
	
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
       	//if (AdminPlus4Mut(myMut).ChangeScoreEnabled())
       	//{
          	if (newScoreValue < 0)
          	{
          		ClientMessage("You must enter a New Positive Score");
          		return;
          	}
          	if (target == "all") 
          	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	      	{
          	  		  	C.PlayerReplicationInfo.Score = newScoreValue;
          	  		  	PlayerController(C).ClientMessage(MSG_ChangeScore);
          	  	  	}
          	  	}
          	  	ServerSay("All Scores have been set to "$newScoreValue);
          	  	return;
          	} 
          	else if (target == "")
          	{
        		target = PlayerReplicationInfo.PlayerName;
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          			if (namematch >=0) 
          			{
		       			C.PlayerReplicationInfo.Score = newScoreValue;
                		PlayerController(C).ClientMessage(MSG_ChangeScore);
                		ServerSay(target$ "'s Score has been set to "$newScoreValue);
                	}
                }
        		return;
        	} 
        	else 
        	{
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.PlayerReplicationInfo.Score = newScoreValue;
                			PlayerController(C).ClientMessage(MSG_ChangeScore);
                			ServerSay(C.PlayerReplicationInfo.PlayerName$ "'s Score has been set to "$newScoreValue);
          				}
          			}
          		}
       		}
   		//}
	}
}

exec function ResetScore (string target)
{
	ChangeScore(target, 0.0);
}

//=================================================
exec function SloMo( float T )
{
    local Mutator myMut;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).SloMoEnabled())
    	//{
	    	ServerSay("Game Speed has been set to "$T);
	    	ClientMessage("Use 'Slomo 1' to return to normal");
	    	Level.Game.SetGameSpeed(T);    	
		//}
    }
}

//=================================================
exec function SetGravity( float F )
{
    local Mutator myMut;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).SetGravityEnabled()) 
    	//{
			ServerSay("Gravity has been set to "$F);
	    	ClientMessage("Use 'SetGrav -950' to return to normal");
			PhysicsVolume.Gravity.Z = F;
        //}
    }
}

//================================================  Zeds still see you.
//Make Target Invisible to other players
exec function InvisOn(string target, optional float invamount)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;
	
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).InvisEnabled()) 
    	//{
       		
       		if (target == "all") 
       		{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	       	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	       	{
          	  		  	C.Pawn.bHidden = true;
						C.Pawn.Visibility = invamount;
        				C.Pawn.ClientMessage(MSG_InvisOn);
          	  	  	}
          	  	}
          	  	return;
         	} 
         	else if (target == "")
         	{
        		P = verifyTarget(target);
        		P.bHidden = true;
				P.Visibility = invamount;
        		P.ClientMessage(MSG_InvisOn);
        		return;
        	} 
        	else 
        	{	
         		P = verifyTarget(target);
         		if (P == none)
         		{
             		return;
           		}
         		for( C = Level.ControllerList; C != None; C = C.nextController ) 
         		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.bHidden = true;
							C.Pawn.Visibility = invamount;
        					C.Pawn.ClientMessage(MSG_InvisOn);
          				}
          			}
          		}
    		}
    	//}
	}
}

//================================================
//Make Target Able To Be Seen (Undo Invisibility)
exec function InvisOff(string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).InvisEnabled()) 
    	//{		
			if (target == "all") 
			{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController') || C.IsA('xBot'))
          	      	{
          	  		  	C.Pawn.bHidden = false;
						C.Pawn.Visibility = C.Pawn.default.visibility;
        				C.Pawn.ClientMessage(MSG_InvisOff);
          	  	  	}
          	  	}
          	  	return;
        	} 
        	else if (target == "")
        	{
        		P = verifyTarget(target);
        		P.bHidden = false;
				P.Visibility = P.default.visibility;
        		P.ClientMessage(MSG_InvisOff);
        		return;
        	} 
        	else 
        	{
	       		P = verifyTarget(target);
	       		if (P == none)
	       		{
             		return;
           		}
	       		for( C = Level.ControllerList; C != None; C = C.nextController ) 
	       		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.bHidden = false;
							C.Pawn.Visibility = C.Pawn.default.visibility;
        					C.Pawn.ClientMessage(MSG_InvisOff);
          				}
          			}
          		}
    		}
  		//}
	}
}

//================================================
//Put Target In Ghost Mode
exec function Ghost(string target){
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none)
    {
    	//if (AdminPlus4Mut(myMut).GhostEnabled())
    	//{
        	
        	if (target == "all")
        	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController )
          	  	{
          	      	if( C.IsA('PlayerController')) 
          	      	{
          	  		  	C.Pawn.bAmbientCreature=true;
        				C.Pawn.UnderWaterTime = -1.0;
						C.Pawn.SetCollision(false, false, false);
						C.Pawn.bCollideWorld = false;
						C.Pawn.controller.GotoState('PlayerFlying');
        				C.Pawn.ClientMessage(MSG_Ghost);
        				C.Pawn.PlayTeleportEffect(true, true);
        				ClientMessage("Use 'Admin Walk' to return players to normal");
          	  	  	}
          	  	}
          	  	return;
         	} 
         	else if (target == "")
         	{
        		P = verifyTarget(target);
        		P.bAmbientCreature=true;
        		P.UnderWaterTime = -1.0;
				P.SetCollision(false, false, false);
				P.bCollideWorld = false;
				P.controller.GotoState('PlayerFlying');
        		P.ClientMessage(MSG_Ghost);
        		P.PlayTeleportEffect(true, true);
        		ClientMessage("Use 'Admin Walk' to return players to normal");
        		return;
        	} 
        	else 
        	{  
         		P = verifyTarget(target);
         		if (P == none)
         		{
             		return;
           		}
         		for( C = Level.ControllerList; C != None; C = C.nextController ) 
         		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0)
          				{ 
          					C.Pawn.bAmbientCreature=true;
        					C.Pawn.UnderWaterTime = -1.0;
							C.Pawn.SetCollision(false, false, false);
							C.Pawn.bCollideWorld = false;
							C.Pawn.controller.GotoState('PlayerFlying');
        					C.Pawn.ClientMessage(MSG_Ghost);
        					C.Pawn.PlayTeleportEffect(true, true);
        					ClientMessage("Use 'Admin Walk' to return players to normal");
          				}
          			}
          		}
    		}
  		//}
	}
}


//================================================
//Put Target In Fly Mode
exec function Fly(string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).FlyEnabled()) 
        //{    	
	    	if (target == "all") 
	    	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController')) 
          	      	{
          	  		  	C.Pawn.bAmbientCreature=false;
						C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
						C.Pawn.SetCollision(true, true , true);
						C.Pawn.bCollideWorld = true;
						C.Pawn.controller.GotoState('PlayerFlying');
        				C.Pawn.ClientMessage(MSG_Fly);
        				C.Pawn.PlayTeleportEffect(true, true);
        				ClientMessage("Use 'Admin Walk' to return players to normal");
          	  	  	}
          	  	}
          	  	return;
         	} 
         	else if (target == "")
         	{
        		P = verifyTarget(target);
        		P.bAmbientCreature=false;
				P.UnderWaterTime = P.Default.UnderWaterTime;
				P.SetCollision(true, true , true);
				P.bCollideWorld = true;
				P.controller.GotoState('PlayerFlying');
        		P.ClientMessage(MSG_Fly);
        		P.PlayTeleportEffect(true, true);
        		ClientMessage("Use 'Admin Walk' to return players to normal");
        		return;
        	} 
        	else 
        	{
         		P = verifyTarget(target);
         		if (P == none)
         		{
             		return;
           		}
         		for( C = Level.ControllerList; C != None; C = C.nextController ) 
         		{
          	    	if( C.IsA('PlayerController')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.bAmbientCreature=false;
							C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
							C.Pawn.SetCollision(true, true , true);
							C.Pawn.bCollideWorld = true;
							C.Pawn.controller.GotoState('PlayerFlying');
        					C.Pawn.ClientMessage(MSG_Fly);
        					C.Pawn.PlayTeleportEffect(true, true);
        					ClientMessage("Use 'Admin Walk' to return players to normal");
          				}
          			}
          		}
    		}
   		//}
  	}
}

//================================================
//Put Target In Spider Mode
exec function Spider(string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).SpiderEnabled()) 
    	//{   	
        	if (target == "all") 
        	{
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if ( C.IsA('PlayerController')) 
          	      	{
          	  		  	C.Pawn.bAmbientCreature=false;        
						C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
						C.Pawn.SetCollision(true, true , true);
						C.Pawn.bCollideWorld = true;
						C.Pawn.JumpZ = 0.0;
						xPawn(C.Pawn).bflaming = true;
						C.Pawn.controller.GotoState('PlayerSpidering');
        				C.Pawn.ClientMessage(MSG_Spider);
        				C.Pawn.PlayTeleportEffect(true, true);
        				ClientMessage("Use 'Admin Walk' to return players to normal");
          	  	  	}
          	  	}
          	  	return;
         	} 
         	else if (target == "")
         	{
        		P = verifyTarget(target);
        		P.bAmbientCreature=false;        
				P.UnderWaterTime = P.Default.UnderWaterTime;
				P.SetCollision(true, true , true);
				P.bCollideWorld = true;
				P.bCanJump = False;
				P.controller.GotoState('PlayerSpidering');
        		P.ClientMessage(MSG_Spider);
        		P.PlayTeleportEffect(true, true);
        		ClientMessage("Use 'Admin Walk' to return players to normal");
        		return;
        	} 
        	else
        	{
         		P = verifyTarget(target);
         		if (P == none)
         		{
             		return;
           		}
         		for( C = Level.ControllerList; C != None; C = C.nextController ) 
         		{
          			if( C.IsA('PlayerController')) 
          			{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.bAmbientCreature=false;        
							C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
							C.Pawn.SetCollision(true, true , true);
							C.Pawn.bCollideWorld = true;
							C.Pawn.bCanJump = False;
							C.Pawn.controller.GotoState('PlayerSpidering');
        					C.Pawn.ClientMessage(MSG_Spider);
        					C.Pawn.PlayTeleportEffect(true, true);
        					ClientMessage("Use 'Admin Walk' to return players to normal");
        				}
          			}
          		}
    		}
  		//}
	}
}
//================================================
//Put Target In Walk Mode
exec function Walk(string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;
			
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {		
		if (target == "all") 
		{
        	for( C = Level.ControllerList; C != None; C = C.nextController ) 
        	{
          		if( C.IsA('PlayerController')) 
          		{
          	  		C.Pawn.bAmbientCreature=false;
					C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
					C.Pawn.SetCollision(true, true , true);
					C.Pawn.SetPhysics(PHYS_Walking);
					C.Pawn.bCollideWorld = true;
					C.Pawn.bCanJump = true;
					C.Pawn.controller.GotoState('PlayerWalking');
        			C.Pawn.ClientMessage(MSG_Walk);
          	  	}
          	}
          	return;
        } 
        else if (target == "")
        {
        	P = verifyTarget(target);
        	P.bAmbientCreature=false;
			P.UnderWaterTime = P.Default.UnderWaterTime;
			P.SetCollision(true, true , true);
			P.SetPhysics(PHYS_Walking);
			P.bCollideWorld = true;
			P.bCanJump = true;
			P.controller.GotoState('PlayerWalking');
        	P.ClientMessage(MSG_Walk);
        	return;
        } 
        else 
        {
        	P = verifyTarget(target);
        	if (P == none)
        	{
             	return;
           	}
        	for( C = Level.ControllerList; C != None; C = C.nextController ) 
        	{
          	    if( C.IsA('PlayerController')) 
          	    {
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          			if (namematch >=0) 
          			{ 
          				C.Pawn.bAmbientCreature=false;
						C.Pawn.UnderWaterTime = C.Pawn.Default.UnderWaterTime;
						C.Pawn.SetCollision(true, true , true);
						C.Pawn.SetPhysics(PHYS_Walking);
						C.Pawn.bCollideWorld = true;
						C.Pawn.bCanJump = true;
						C.Pawn.controller.GotoState('PlayerWalking');
        				C.Pawn.ClientMessage(MSG_Walk);
          			}
          		}
          	}
    	}
  	}
}

exec function HelpZeds()
{
	ClientMessage("Here are a list of available default zed class names.");
	ClientMessage("There are 4 types of zed classes.");
	ClientMessage("Which are STANDARD,XMas,HALLOWEEN and CIRCUS.");
	ClientMessage("For example, KfChar.ZombieClot_HALLOWEEN.");
	ClientMessage("KfChar.ZombieClot_STANDARD");
	ClientMessage("KfChar.ZombieBloat_STANDARD");
	ClientMessage("KfChar.ZombieGorefast_STANDARD");
	ClientMessage("KfChar.ZombieCrawler_STANDARD");
	ClientMessage("KfChar.ZombieStalker_STANDARD");
	ClientMessage("KfChar.ZombieHusk_STANDARD");
	ClientMessage("KfChar.ZombieSiren_STANDARD");
	ClientMessage("KfChar.ZombieScrake_STANDARD");
	ClientMessage("KfChar.ZombieFleshpound_STANDARD");
	ClientMessage("KfChar.ZombieBoss_STANDARD");
}

exec function HelpWeapons()
{
	ClientMessage("Here are a list of available default weapon class names.");
	ClientMessage("KfMod.AA12AutoShotgun");
	ClientMessage("KfMod.AK47AssaultRifle");
	ClientMessage("KfMod.Axe");
	ClientMessage("KfMod.BenelliShotgun");
	ClientMessage("KfMod.BlowerThrower");
	ClientMessage("KfMod.BoomStick");
	ClientMessage("KfMod.Bullpup");
	ClientMessage("KfMod.CamoM4AssaultRifle");
	ClientMessage("KfMod.CamoM32GrenadeLauncher");
	ClientMessage("KfMod.CamoMP5MMedicGun");
	ClientMessage("KfMod.CamoShotgun");
	ClientMessage("KfMod.Chainsaw");
	ClientMessage("KfMod.ClaymoreSword");
	ClientMessage("KfMod.Crossbow");
	ClientMessage("KfMod.Crossbuzzsaw");
	ClientMessage("KfMod.Deagle");
	ClientMessage("KfMod.Dual44Magnum");
	ClientMessage("KfMod.DualDeagle");
	ClientMessage("KfMod.DualFlareRevolver");
	ClientMessage("KfMod.Dualies");
	ClientMessage("KfMod.DualMK23Pistol");
	ClientMessage("KfMod.DwarfAxe");
	ClientMessage("KfMod.FlameThrower");
	ClientMessage("KfMod.FlareRevolver");
	ClientMessage("KfMod.FNFAL_ACOG_AssaultRifle");
	ClientMessage("KfMod.GoldenAA12AutoShotgun");
	ClientMessage("KfMod.GoldenAK47AssaultRifle");
	ClientMessage("KfMod.GoldenBenelliShotgun");
	ClientMessage("KfMod.GoldenChainsaw");
	ClientMessage("KfMod.GoldenDeagle");
	ClientMessage("KfMod.GoldenDualDeagle");
	ClientMessage("KfMod.GoldenFlamethrower");
	ClientMessage("KfMod.GoldenKatana");
	ClientMessage("KfMod.GoldenM79GrenadeLauncher");
	ClientMessage("KfMod.HuskGun");
	ClientMessage("KfMod.Katana");
	ClientMessage("KfMod.Knife");
	ClientMessage("KfMod.KrissMMedicGun");
	ClientMessage("KfMod.KSGShotgun");
	ClientMessage("KfMod.LAW");
	ClientMessage("KfMod.M4AssaultRifle");
	ClientMessage("KfMod.M7A3MMedicGun");
	ClientMessage("KfMod.M14EBRBattleRifle");
	ClientMessage("KfMod.M32GrenadeLauncher");
	ClientMessage("KfMod.M79GrenadeLauncher");
	ClientMessage("KfMod.M99SniperRifle");
	ClientMessage("KfMod.M4203AssaultRifle");
	ClientMessage("KfMod.MAC10MP");
	ClientMessage("KfMod.Machete");
	ClientMessage("KfMod.Magnum44Pistol");
	ClientMessage("KfMod.MK23Pistol");
	ClientMessage("KfMod.MKb42AssaultRifle");
	ClientMessage("KfMod.MP5MMedicGun");
	ClientMessage("KfMod.MP7MMedicGun");
	ClientMessage("KfMod.NailGun");
	ClientMessage("KfMod.NeonAK47AssaultRifle");
	ClientMessage("KfMod.NeonKrissMMedicGun");
	ClientMessage("KfMod.NeonKSGShotgun");
	ClientMessage("KfMod.NeonSCARMK17AssaultRifle");
	ClientMessage("KfMod.PipeBombShrapnel");
	ClientMessage("KfMod.SCARMK17AssaultRifle");
	ClientMessage("KfMod.Scythe");
	ClientMessage("KfMod.SealSquealHarpoonBomber");
	ClientMessage("KfMod.SeekerSixRocketLauncher");
	ClientMessage("KfMod.Single");
	ClientMessage("KfMod.SPAutoShotgun");
	ClientMessage("KfMod.SPGrenadeLauncher");
	ClientMessage("KfMod.SPSniperRifle");
	ClientMessage("KfMod.SPThompsonSMG");
	ClientMessage("KfMod.Syringe");
	ClientMessage("KfMod.ThompsonDrumSMG");
	ClientMessage("KfMod.ThompsonSMG");
	ClientMessage("KfMod.Trenchgun");
	ClientMessage("KfMod.Welder");
	ClientMessage("KfMod.Winchester");
	ClientMessage("KfMod.ZEDGun");
	ClientMessage("KfMod.ZEDMKIIWeapon");
}

function InitSummonedActor(Actor a)
{
    local KFWeaponPickup KFWP;
    local KFMonster KFM;
    KFWP=KFWeaponPickup(a);
    KFM=KFMonster(a);
	if(KFWP!=none)
    {
        KFWP.bAlwaysRelevant = false;
		KFWP.bOnlyReplicateHidden = false;
		KFWP.bUpdateSimulatedPosition = true;
		KFWP.bDropped = true;
		KFWP.bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
		KFWP.NetUpdateFrequency = 8;
		KFWP.bNoRespawn = true;
		return;
    }
    if(KFM!=none)
    {
    	return;
    }
    else 
    	return;
}

//================================================
exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;
	local Mutator myMut;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).SummonEnabled()) 
        //{
        	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
        	if( NewClass!=None )
        	{
        		if ( Pawn != None )
        			SpawnLoc = Pawn.Location;
        		else
        			SpawnLoc = Location;
        		InitSummonedActor(Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 ));
        	}
    	//}
	}
}

//================================================
exec function AdvancedSummon( string ClassName, string target)
{
	local class<actor> NewClass;
	local vector SpawnLoc;
	local Mutator myMut;
	local Pawn p;

    p = verifyTarget(target);
    if (p == None)
    {
        ClientMessage(target $" is not on the game.");
        return;
    }
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).AdvancedSummonEnabled()) 
        //{
        	log( "Fabricate " $ ClassName );
        	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
        	if( NewClass!=None )
        	{
        		if ( P != None )
        			SpawnLoc = P.Location;
        		else
        			SpawnLoc = Location;
        		Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
        	}
    	//}
	}
}

//================================================
exec function Teleport()
{
    local Mutator myMut;
	local actor HitActor;
	local vector HitNormal, HitLocation;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).TeleportEnabled()) 
        //{
			HitActor = Trace(HitLocation, HitNormal, ViewTarget.Location + 10000 * vector(Rotation),ViewTarget.Location, true);
			if ( HitActor == None )
            {
			    HitLocation = ViewTarget.Location + 10000 * vector(Rotation);
			} 
            else
            {
				HitLocation = HitLocation + ViewTarget.CollisionRadius * HitNormal;
			}
			ViewTarget.SetLocation(HitLocation);
			ViewTarget.PlayTeleportEffect(false,true);
	    //}
	}
}

//================================================

exec function GiveItem(string ItemName,string target)
{
  local Inventory Inv;
  local Mutator myMut;
  local Controller C;
  local int namematch;
  local Pawn p;
  local string ItemOnly;
  local int PeriodLoc;
//local Weapon myWeapon;
  
   myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  if(myMut != none) 
  {
  //if (AdminPlus4Mut(myMut).GiveItemEnabled()) 
  //{
			PeriodLoc = Instr(ItemName, ".");
			ItemOnly = Right(ItemName, PeriodLoc);
			if (target == "all")
      {
        for( C = Level.ControllerList; C != None; C = C.nextController )
        {
          if( C.IsA('PlayerController'))
          {
          	if (ItemName == "adrenaline")
            {
						  C.Pawn.controller.adrenaline = 100;
							C.Pawn.ClientMessage("You Have been given Full Adrenaline!");
            } 
            else 
            {
              C.Pawn.GiveWeapon(ItemName);
              C.Pawn.PlayTeleportEffect(true, true);
              C.Pawn.ClientMessage("You Have been given the gift of: "$ItemOnly);
            //AllAmmo(Pawn P)(C.Pawn);
              For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
              {
                if ( Weapon(Inv) != None ) 
                {
       						Weapon(Inv).Loaded();
       	    		}
       	    	}
       	    }
          }
        }
        return;
      } 
      else if (target == "")
      {
        P = verifyTarget(target);
        if (ItemName == "adrenaline")
        {
					P.controller.adrenaline = 100;
					P.ClientMessage("You Have been given Full Adrenaline!");
        } 
        else
        {
          P.GiveWeapon(ItemName);
          P.PlayTeleportEffect(true, true);
          P.ClientMessage("You Have been given the gift of: "$ItemOnly);
        //AllAmmo(P);
          For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ) 
          {
            if ( Weapon(Inv) != None ) 
            {
     					Weapon(Inv).Loaded();
       	    }
       	  }
       	}
        return;
      } 
      else 
      {
        P = verifyTarget(target);
        if (P == none)
        {
          return;
        }
	      for( C = Level.ControllerList; C != None; C = C.nextController ) 
	      {
          if( C.IsA('PlayerController') || C.IsA('xBot')) 
          {
          	namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          	if (namematch >=0) 
          	{ 
          		if (ItemName == "adrenaline")
          		{
								C.Pawn.controller.adrenaline = 100;
								C.Pawn.ClientMessage("You Have been given Full Adrenaline!");
            	} 
            	else 
            	{
                C.Pawn.GiveWeapon(ItemName);
                C.Pawn.PlayTeleportEffect(true, true);
                C.Pawn.ClientMessage("You Have been given the gift of: "$ItemOnly);
              //AllAmmo(C.Pawn);
            		For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
            		{
                	if ( Weapon(Inv) != None ) 
                  {
     						    Weapon(Inv).Loaded();
       	    	    }
       	    		}
       	    	}
          	}
          }
        }
      }
  //}
  }
}
//=============================================
exec function Loaded(string target)
{
	local Inventory Inv;
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn P;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
    	//if (AdminPlus4Mut(myMut).LoadedEnabled()) 
    	//{           
            if (target == "all") 
            {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	  	{
          	      	if( C.IsA('PlayerController'))
          	      	{
          	  			AllWeapons(C.Pawn);
            			AllAmmo(C.Pawn);
            			C.Pawn.ClientMessage ("You have been given several the most powerful Weapons!");
            			C.Pawn.PlayTeleportEffect(true, true);
            			For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
            			{
                			if ( Weapon(Inv) != None ) 
                			{
        						Weapon(Inv).Loaded();
        					}
        				}	
          	  	  	}
          	  	}
          	  	ServerSay("Everyone has been Loaded!");
          	  	return;
        	} 
        	else if (target == "")
        	{
        		P = verifyTarget(target);
        		AllWeapons(P);
            	AllAmmo(P);
            	P.ClientMessage ("You have been given All Default Weapons!");
            	P.PlayTeleportEffect(true, true);
            	ServerSay(target$ " has been Loaded!");
            	For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ) 
            	{
                	if ( Weapon(Inv) != None ) 
                	{
        				Weapon(Inv).Loaded();
        			}
        		}
        		return;
        	} 
        	else 
        	{
            	P = verifyTarget(target);
            	if (P == none)
            	{
             		return;
           		}
            	for( C = Level.ControllerList; C != None; C = C.nextController ) 
            	{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >= 0) 
          				{
          					AllWeapons(C.Pawn);
            				AllAmmo(C.Pawn);
            				C.Pawn.ClientMessage ("You have been given All Default Weapons!");
            				C.Pawn.PlayTeleportEffect(true, true);
            				For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
            				{
                				if ( Weapon(Inv) != None ) 
                				{
        							Weapon(Inv).Loaded();
        						}
        					}	
          				}
          			}
            	}
            	ServerSay(C.PlayerReplicationInfo.PlayerName$ " has been Loaded!");
            	return;
       		}
   		//}
	}
}
/*
//=============================================
exec function CustomLoaded1(string target){
	local Inventory Inv;
    local Mutator myMut;
    local int i;
    local string M;
    local Controller C;
    local int namematch;
    local Pawn P;
            
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) {
    	if (AdminPlus4Mut(myMut).CustomLoadedEnabled()) {
			
			if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController')) {
          	  		  	for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1.Length; i++) {
  					  		M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1[i]);
  					  		C.Pawn.Giveweapon(M);
            		  	}
	    			  	AllAmmo(C.Pawn);
	    			  	C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 1!");
	    			  	C.Pawn.PlayTeleportEffect(true, true);
                	  	For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                			if ( Weapon(Inv) != None ){
        						Weapon(Inv).Loaded();
        					}
        			  	}	
          	  	  	}
          	  	}
          	  	return;
        	} else if (target == ""){
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
        		for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1.Length; i++) {
  					M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1[i]);
  					p.Giveweapon(M);
            	}
	    		AllAmmo(p);
	    		P.ClientMessage ("You have been given Custom Weapons Pack 1!");
	    		P.PlayTeleportEffect(true, true);
                For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ){
                	if ( Weapon(Inv) != None ){
        				Weapon(Inv).Loaded();
        			}
        		}
        		return;
        	} else {
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1.Length; i++) {
  					  			M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase1[i]);
  					  			C.Pawn.Giveweapon(M);
            		  		}
	    			  		AllAmmo(C.Pawn);
	    			  		C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 1!");
	    			  		C.Pawn.PlayTeleportEffect(true, true);
	    			  		For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                				if ( Weapon(Inv) != None ){
        							Weapon(Inv).Loaded();
        			 			}
          					}
          				}
            		}
       			}
   			}
		}
	}
}
//=============================================
exec function CustomLoaded2(string target){
	local Inventory Inv;
    local Mutator myMut;
    local int i;
    local string M;
    local Controller C;
    local int namematch;
    local Pawn P;
            
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) {
    	if (AdminPlus4Mut(myMut).CustomLoadedEnabled()) {
			
			if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController')) {
          	  		  	for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2.Length; i++) {
  					  		M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2[i]);
  					  		C.Pawn.Giveweapon(M);
            		  	}
	    			  	AllAmmo(C.Pawn);
	    			  	C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 2!");
	    			  	C.Pawn.PlayTeleportEffect(true, true);
	    			  	For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                			if ( Weapon(Inv) != None ){
        						Weapon(Inv).Loaded();
        					}
        			  	}	
          	  	  	}
          	  	}
          	  	return;
        	} else if (target == ""){
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
        		for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2.Length; i++) {
  					M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2[i]);
  					p.Giveweapon(M);
            	}
	    		AllAmmo(P);
	    		P.ClientMessage ("You have been given Custom Weapons Pack 2!");
	    		P.PlayTeleportEffect(true, true);
	    		For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ){
                	if ( Weapon(Inv) != None ){
        				Weapon(Inv).Loaded();
        			}
        		}
        		return;
        	} else {
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
	            for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2.Length; i++) {
  					  			M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase2[i]);
  					  			C.Pawn.Giveweapon(M);
            		  		}
	    			  		AllAmmo(C.Pawn);
	    			  		C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 2!");
	    			  		C.Pawn.PlayTeleportEffect(true, true);
	    			  		For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                				if ( Weapon(Inv) != None ){
        							Weapon(Inv).Loaded();
        			 			}
          					}
          				}
            		}
       			}
       		}
   		}
	}
}
//=============================================
exec function CustomLoaded3(string target){
	local Inventory Inv;
    local Mutator myMut;
    local int i;
    local string M;
    local Controller C;
    local int namematch;
    local Pawn P;
            
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) {
        if (AdminPlus4Mut(myMut).CustomLoadedEnabled()) {
			
			if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController')) {
          	  		  	for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3.Length; i++) {
  					  		M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3[i]);
  					  		C.Pawn.Giveweapon(M);
            		  	}
	    			  	AllAmmo(C.Pawn);
	    			  	C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 3!");
	    			  	C.Pawn.PlayTeleportEffect(true, true);
	    			  	For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                			if ( Weapon(Inv) != None ){
        						Weapon(Inv).Loaded();
        					}
        			  	}	
          	  	  	}
          	  	}
          	  	return;
        	} else if (target == ""){
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
        		for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3.Length; i++) {
  					M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3[i]);
  					p.Giveweapon(M);
            	}
	    		AllAmmo(P);
	    		P.ClientMessage ("You have been given Custom Weapons Pack 3!");
	    		P.PlayTeleportEffect(true, true);
	    		For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory ){
                	if ( Weapon(Inv) != None ){
        				Weapon(Inv).Loaded();
        			}
        		}
        		return;
        	} else {
        		P = verifyTarget(target);
        		if (P == none){
             		return;
           		}
            	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					for (i = 0; i < class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3.Length; i++) {
  					  			M = (class'AdminPlus_v4.AdminPlus4Mut'.default.WeaponBase3[i]);
  					  			C.Pawn.Giveweapon(M);
            		  		}
	    			  		AllAmmo(C.Pawn);
	    			  		C.Pawn.ClientMessage ("You have been given Custom Weapons Pack 3!");
	    			  		C.Pawn.PlayTeleportEffect(true, true);
                	  		For ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ){
                				if ( Weapon(Inv) != None ){
        							Weapon(Inv).Loaded();
        			 			}
          					}
          				}
            		}
       			}
       		}
   		}
	}
}
*/
function AllAmmo(Pawn P)
{
	local Inventory Inv;
	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Weapon(Inv)!=None )
			Weapon(Inv).SuperMaxOutAmmo();
    P.Controller.AwardAdrenaline( 999 );
}

function AllWeapons(pawn P)
{
	if ((P == None) || (Vehicle(P) != None) )
		return;	
	P.GiveWeapon("KFMod.Crossbuzzsaw");
	P.GiveWeapon("KFMod.ZEDMKIIWeapon");
	P.GiveWeapon("KFMod.DwarfAxe");
	P.GiveWeapon("KFMod.Crossbow");
	P.GiveWeapon("KFMod.DualDeagle");
	P.GiveWeapon("KFMod.Single");
	P.GiveWeapon("KFMod.katana");
	P.GiveWeapon("KFMod.DualFlareRevolver");
	P.GiveWeapon("KFMod.Nade");
	P.GiveWeapon("KFMod.BoomStick");
	P.GiveWeapon("KFMod.Syringe");
	P.GiveWeapon("KFMod.Welder");
	P.GiveWeapon("KFMod.KrissMMedicGun");
	P.GiveWeapon("KFMod.LAW");
	P.GiveWeapon("KFMod.Knife");
}

//=========================================================================
exec function CauseEvent( name EventName )
{
    local Mutator myMut;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).CauseEventEnabled()) 
        //{
       		TriggerEvent( EventName, Pawn, Pawn);
        //}
    }
}

//=========================================================================
exec function DNO()
{
    local Mutator myMut;

    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).DNOEnabled()) 
        //{
			Level.Game.DisableNextObjective();
        //}
    }
}

function help_list(Controller C)
{
	PlayerController(C).ClientMessage(MSG_Help1);
	PlayerController(C).ClientMessage(MSG_Help2);
	PlayerController(C).ClientMessage(MSG_Help3);
	PlayerController(C).ClientMessage(MSG_Help4);
	PlayerController(C).ClientMessage(MSG_Help5);
	PlayerController(C).ClientMessage(MSG_Help6);
	PlayerController(C).ClientMessage(MSG_Help7);
	PlayerController(C).ClientMessage(MSG_Help8);
	PlayerController(C).ClientMessage(MSG_Help9);
	PlayerController(C).ClientMessage(MSG_Help10);
	PlayerController(C).ClientMessage(MSG_Help11);
	PlayerController(C).ClientMessage(MSG_Help12);
	PlayerController(C).ClientMessage(MSG_Help13);
	PlayerController(C).ClientMessage(MSG_Help14);
	PlayerController(C).ClientMessage(MSG_Help15);
	//PlayerController(C).ClientMessage(MSG_Help16);
	//PlayerController(C).ClientMessage(MSG_Help17);
	//PlayerController(C).ClientMessage(MSG_Help18);
	PlayerController(C).ClientMessage(MSG_Help19);
	//PlayerController(C).ClientMessage(MSG_Help20);
	PlayerController(C).ClientMessage(MSG_Help21);
	PlayerController(C).ClientMessage(MSG_Help22);
	PlayerController(C).ClientMessage(MSG_Help23);
	PlayerController(C).ClientMessage(MSG_Help24);
	PlayerController(C).ClientMessage(MSG_Help25);
	PlayerController(C).ClientMessage(MSG_Help26);
	PlayerController(C).ClientMessage(MSG_Help27);
	PlayerController(C).ClientMessage(MSG_Help28);
	PlayerController(C).ClientMessage(MSG_Help29);
	PlayerController(C).ClientMessage(MSG_Help30);
	PlayerController(C).ClientMessage(MSG_Help31);
	PlayerController(C).ClientMessage(MSG_Help32);
	PlayerController(C).ClientMessage(MSG_Help33);
	PlayerController(C).ClientMessage(MSG_Help34);
	PlayerController(C).ClientMessage(MSG_Help35);
  PlayerController(C).ClientMessage(MSG_Help36);
  PlayerController(C).ClientMessage(MSG_Help37);
  PlayerController(C).ClientMessage(MSG_Help38);
  PlayerController(C).ClientMessage(MSG_Help39);
  PlayerController(C).ClientMessage(MSG_Help40);
  PlayerController(C).ClientMessage(MSG_Help41);
  PlayerController(C).ClientMessage(MSG_Help42);
  PlayerController(C).ClientMessage(MSG_Help43);
  PlayerController(C).ClientMessage(MSG_Help44);
  PlayerController(C).ClientMessage(MSG_Help45);
  PlayerController(C).ClientMessage(MSG_Help46);
  PlayerController(C).ClientMessage(MSG_Help47);
  PlayerController(C).ClientMessage(MSG_Help48);
  PlayerController(C).ClientMessage(MSG_Help49);
  PlayerController(C).ClientMessage(MSG_Help50);
}
//=========================================================================
exec function Help(string target)
{
    local Mutator myMut;
	local Controller C;
	local int namematch;
	   
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) 
    {
       	
       	if (target == ""){
       		target = PlayerReplicationInfo.PlayerName;
          	for( C = Level.ControllerList; C != None; C = C.nextController ) 
          	{
          		namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          		if (namematch >=0) {
        			help_list(C);
        			return;
    			}
			}
		} 
		else 
		{
			for( C = Level.ControllerList; C != None; C = C.nextController ) 
			{
          		if( C.IsA('PlayerController') || C.IsA('xBot')) 
          		{
          			namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          			if (namematch >=0)
          			{
          				help_list(C);
          			}
          		}
          	}
        }
	}
}
//====================
//====================
//==Disabled at work==
//====================
//====================

//================================================
//Instantly do 10,000 points of damage to a given player.
exec function fatality(string target){
    local Mutator myMut;
    local Controller C;
	local int namematch;
	local Pawn p;
	
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut != none) 
    {
        //if (AdminPlus4Mut(myMut).fatalityEnabled()) 
        //{		   	
		   	if (target == "all") 
		   	{
        		for( C = Level.ControllerList; C != None; C = C.nextController ) 
        		{
          			if( C.IsA('PlayerController') || C.IsA('xBot')) 
          			{
          	  			C.Pawn.Controller.bGodMode = false;
    					Spawn( class<actor>( DynamicLoadObject( "KFMod.KFNadeLExplosion", class'Class' ) ),,,C.Pawn.location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
        				C.Pawn.TakeDamage(1000,Instigator,Vect(0,0,0),Vect(0,0,0),class'DamTypeFrag');
          	  	  	}
          	  	}
          	  	ServerSay("An Admin turned everyone into ashes!");
          	  	return;
        	} 
        	else if (target == "")
        	{
        		P = verifyTarget(target);
        		if (P == none)
        		{
             		return;
           		}
        		P.Controller.bGodMode = false;
    			Spawn( class<actor>( DynamicLoadObject( "KFMod.KFNadeLExplosion", class'Class' ) ),,,P.location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
        		ServerSay(P.PlayerReplicationInfo.PlayerName $" turned himself into ashes!");
        		P.TakeDamage(1000,Instigator,Vect(0,0,0),Vect(0,0,0),class'DamTypeFrag');
        		return;
        	} 
        	else 
        	{
          		P = verifyTarget(target);
          		if (P == none)
          		{
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) 
          		{
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) 
          	    	{
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) 
          				{ 
          					C.Pawn.Controller.bGodMode = false;
    						Spawn( class<actor>( DynamicLoadObject( "KFMod.KFNadeLExplosion", class'Class' ) ),,,C.Pawn.location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
        					ServerSay("An Admin turned " $ C.PlayerReplicationInfo.PlayerName $ " into ashes!");
        					C.Pawn.TakeDamage(1000,Instigator,Vect(0,0,0),Vect(0,0,0),class'DamTypeFrag');
          				}
          			}
          		}
     		}
  		//}
	}
}

exec function KillAllZeds()
{
  	local array <KFMonster> Monsters; 
  	local KFMonster M;
  	local Mutator myMut;
  	local int i;
  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut!=None)
  	{     
    	// fill the array first, because direct M killing may screw up DynamicActors() iteration
    	// -- PooSH
    	foreach DynamicActors(class 'KFMonster', M)
    	{
        	if(M.Health > 0 && !M.bDeleteMe)
        	{
            	Monsters[Monsters.length] = M;
        	}
        	for ( i=0; i<Monsters.length; ++i )
        	{
          		Monsters[i].Died(Monsters[i].Controller, class'DamageType', Monsters[i].Location);
        	}
    	}
    	ServerSay("Killed zeds count " $ string(Monsters.length));
  	}
}

exec function ClearLevel()
{
  	local Pickup w;
	local Mutator myMut;
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
	if(myMut!=None)
	{     
    	foreach AllActors(class'Pickup', w)
        {
            w.Destroy();
        }  
    	ServerSay("All weapon pickup have been removed");
  	}
}

exec function SavePeople(string saver,string saved)
{
  	local Mutator myMut;
  	local Pawn psaver;
  	local Pawn psaved;
  	local vector SpawnLoc;
  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut!=None)
  	{     
    	psaver = verifyTarget(saver);
		psaved = verifyTarget(saved);
		if(psaved!=none&&psaver!=none)
		{
			SpawnLoc=psaver.Location;
			PlayerController(psaved.Controller).ViewTarget.SetLocation(SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15);
			PlayerController(psaved.Controller).ViewTarget.PlayTeleportEffect(false,true);
		} 
    	PlayerController(psaved.Controller).ClientMessage("admin has moved you to " $ psaver.Controller.PlayerReplicationInfo.PlayerName $" aside");
  	}
}

exec function TraderTime(int secs)
{
  	local Mutator myMut;
  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut!=None)
  	{
    	if(KFGameType(Level.Game).bTradingDoorsOpen)
    	{
      		if(secs<=6)
        	secs=6;    // need to left at least 6 to execute kfgametype.timer() events
      		KFGameType(Level.Game).WaveCountDown = secs; 
      		ServerSay("Trader time set to " $ string(secs));
    	}
    	else
    	{
     		ClientMessage("Only functional in trader time.");
		}   
	}
}


exec function WaveNum(int num)
{
    local Mutator myMut;
  	if(num<1)
    	num=1;
  	num--;
  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut!=None)
  	{

    	if(KFGameType(Level.Game).bWaveBossInProgress)
    	{
      	if(num!=KFGameType(Level.Game).FinalWave)
      	{
        	ClientMessage("Can only be set to boss wave during boss wave.");
        	return;
      	}
    	}
    	if(KFGameType(Level.Game).bWaveInProgress)
   		{
        KillAllZeds();
   			KFGameType(Level.Game).NumMonsters=0;
      	KFGameType(Level.Game).WaveNum=num-1;
      	KFGameType(Level.Game).TotalMaxMonsters=0;
        KFGameType(Level.Game).MaxMonsters=0;
      	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters=0;
        //KFGameType(Level.Game).DoWaveEnd();

      	if(num>=KFGameType(Level.Game).FinalWave)
        	num=KFGameType(Level.Game).FinalWave;
      	ServerSay("Wave number set to "$ string(num+1));
    	}
    	else if(KFGameType(Level.Game).bTradingDoorsOpen)
    	{
      	if(num>=KFGameType(Level.Game).FinalWave)
        	num=KFGameType(Level.Game).FinalWave;
      	KFGameType(Level.Game).WaveNum=num;
      	ServerSay("Wave number set to "$ string(num+1));
    	}
  	}
}

exec function ReadyAll()
{
  local Mutator myMut;
  local Controller C;
  myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  if(myMut!=None)
  {
    for( C = Level.ControllerList; C != None; C = C.nextController )
    {
      if( C.IsA('PlayerController'))
      {
        C.PlayerReplicationInfo.bReadyToPlay=true;
      }
    }
  }
}

exec function ViewOn(string target)
{
    local Mutator myMut;
    local Pawn PTarget;
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut!=none)
    {
        PTarget = verifyTarget(target);
        if(PTarget!=none)
   		{
    		SetViewTarget(PTarget);
    		ClientSetViewTarget(PTarget);
    		bBehindView = True;
    		ClientSetBehindView(True);
    	}
  	}
}

exec function ViewOff()
{
    local Mutator myMut;
    local Pawn p;
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if(myMut!=none)
    {
        p=verifyTarget(PlayerReplicationInfo.PlayerName);
        SetViewTarget(p);
        ClientSetViewTarget(p);
        BehindView(false);
    }
}

exec function HelpPerk()
{
	ClientMessage("Here are a list of available perk class names.");
	ClientMessage("KFMod.KFVetFieldMedic");
	ClientMessage("KFMod.KFVetSupportSpec");
	ClientMessage("KFMod.KFVetSharpshooter");
	ClientMessage("KFMod.KFVetCommando");
	ClientMessage("KFMod.KFVetBerserker");
	ClientMessage("KFMod.KFVetFirebug");
	ClientMessage("KFMod.KFVetDemolitions");
}
exec function ChangePerk(string perkClassName,string target)
{
  	//local class<KFVeterancyTypes> NewPerkClass;
  	//local KFVeterancyTypes NewPerk;
  	local Mutator myMut;
  	local KFPlayerController KFPC;
    local Controller C;
    //local KFPlayerReplicationInfo KFPRI;

  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut!=none)
  	{
  		if(target=="") //self
  		{
  	 		KFPC=KFPlayerController(Pawn.Controller);
    		if(KFPC!=none)
     		{
          //KFPRI = KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo);
              
          KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=false;
          KFPC.SelectVeterancy(class<KFVeterancyTypes>(DynamicLoadObject(perkClassName, class'Class')),true);
          KFPC.SaveConfig();
          KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=true;
        }
  	 	}
  		else if(target=="all")
  		{
  	 		for( C = Level.ControllerList; C != None; C = C.nextController )
        {
          if( C.IsA('PlayerController'))
          {
            KFPC=KFPlayerController(C);
    				if(KFPC!=none)
     				{
              KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=false;
              KFPC.SelectVeterancy(class<KFVeterancyTypes>(DynamicLoadObject(perkClassName, class'Class')),true);
              KFPC.SendSelectedVeterancyToServer(true);
              KFPC.SaveConfig();
              KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=true;
          	}
          }
        }
        return;
  		}
  		else
  		{
  	 		KFPC=KFPlayerController(verifyTarget(target).Controller);
    		if(KFPC!=none)
     		{
          KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=false;
          KFPC.SelectVeterancy(class<KFVeterancyTypes>(DynamicLoadObject(perkClassName, class'Class')),true);
          KFPC.SendSelectedVeterancyToServer(true);
          KFPC.SaveConfig();
          KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress=true;
     		}
  		}
  	}
}

function bool RemoveaItemFromPawn(Pawn p,string itemClassName)
{
  	local class<Weapon> WeaponClass;
  	local Weapon delWeapon;
  	WeaponClass = class<Weapon>(DynamicLoadObject(itemClassName, class'Class'));
  	if(WeaponClass!=none)
    	delWeapon=Weapon(p.FindInventoryType(WeaponClass));
  	if(delWeapon!=none)
  	{
    	delWeapon.DetachFromPawn(p);
    	p.DeleteInventory( delWeapon );
    	delWeapon.Destroy();
    	return true;
  	}
  	else 
    	return false;
}

exec function RemoveItem(string ItemName,string target)
{
    local Mutator myMut;
    local Controller C;
    local int namematch;
    local Pawn p;
    local string ItemOnly;
  	local int PeriodLoc;
  
  	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
  	if(myMut != none) 
  {
  //if (AdminPlus4Mut(myMut).GiveItemEnabled())
  //{
      PeriodLoc = Instr(ItemName, ".");
      ItemOnly = Right(ItemName, PeriodLoc);
      if (target == "all")
      {
        for( C = Level.ControllerList; C != None; C = C.nextController )
        {
          if( C.IsA('PlayerController'))
          {
            if (ItemName == "adrenaline")
            {
              C.Pawn.controller.adrenaline = 0;
              C.Pawn.ClientMessage("Your Adrenaline effect has been removed.");
            } 
            else 
            {
              if(RemoveaItemFromPawn(C.Pawn,ItemName))
              {
                C.Pawn.ClientMessage("Your "$ItemOnly$" has been removed.");
              }              
              else 
                ClientMessage("Failure.Target(s) doesn't have the item.");  
            }
          }
        }
        return;
      } 
      else if (target == "")
      {
        P = verifyTarget(target);
        if (ItemName == "adrenaline")
        {
          P.controller.adrenaline = 0;
          P.ClientMessage("Your Adrenaline effect has been removed.");
        } 
        else 
        {
          if(RemoveaItemFromPawn(P,ItemName))
          {
            P.ClientMessage("Your "$ItemOnly$" has been removed.");
          }              
          else 
            ClientMessage("Failure.You don't have the item."); 
        }
      }
    	else 
    	{
        P = verifyTarget(target);
        if (P == none)
        {
          return;
        }
        for( C = Level.ControllerList; C != None; C = C.nextController ) 
        {
          if( C.IsA('PlayerController') || C.IsA('xBot')) 
          {
            ClientMessage(C.PlayerReplicationInfo.PlayerName); 
            namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
            if (namematch >=0) 
            { 
              if (ItemName == "adrenaline")
              {
                C.Pawn.controller.adrenaline = 0;
                C.Pawn.ClientMessage("Your Adrenaline effect has been removed.");
              }
              else 
              {
                if(RemoveaItemFromPawn(C.Pawn,ItemName))
                {
                  C.Pawn.ClientMessage("Your "$ItemOnly$" has been removed.");
                }              
                else 
                  ClientMessage("Failure.Target don't have the item."); 
              }
            }
          }
   		  }
      }
  //}
  } 
}

exec function MaxZedsNum(int maxNum)   //range [5,254]
{
	local Mutator myMut;
	local KFGameType KFGT;
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
	if(myMut!=none)
	{
		KFGT=KFGameType(Level.Game);
		if(KFGT!=none)
		{
			if(maxNum>=0)
			{
				maxNum = clamp(maxNum, 5, 254);
				ServerSay("Current MaxZedsNum set from " $ string(KFGT.MaxZombiesOnce) $ " to " $ string(Clamp(KFGT.TotalMaxMonsters,5,maxNum))); 
				KFGT.MaxZombiesOnce=maxNum;
				KFGT.StandardMaxZombiesOnce =maxNum;
				KFGT.MaxMonsters = Max(5,maxNum);				
			}
		}
	}
}

exec function FakedPlayers(int fakedCount)
{
	local AdminPlus4Mut myMut;
	local KFGameType KFGT;
	myMut = AdminPlus4Mut(findMut(Level.Game.BaseMutator,class'AdminPlus_v4.AdminPlus4Mut'));
	if(myMut!=none)
	{
		KFGT=KFGameType(Level.Game);
		if(KFGT!=none)
		{
			 myMut.OnFakedPlayerChanged(fakedCount);
       ServerSay("Faked players count set to " $ string(fakedCount));
		}
	}
}

exec function MaxPlayersNum(int maxNum)
{
	local Mutator myMut;
	myMut=findMut(Level.Game.BaseMutator,class'AdminPlus_v4.AdminPlus4Mut');
	if(myMut!=none)
	{
		if ( maxNum > 0) 
		{
      ServerSay("Forcing server max players from " $ string(Level.Game.MaxPlayers) $ " to " $ string(maxNum));
      Level.Game.MaxPlayers = maxNum;
    }
	}
}

exec function SpawnMod(float mod)
{
	local Mutator myMut;
  local KFGameType KFGT;
	myMut=findMut(Level.Game.BaseMutator,class'AdminPlus_v4.AdminPlus4Mut');
	if(myMut!=none)
	{
		KFGT=KFGameType(Level.Game);
    if(KFGT!=none)
    {
      KFGT.KFLRules.WaveSpawnPeriod=2*mod;
      ServerSay("Current spawn mod is " $ string(mod));
    }
	}
}

exec function HPConfig(int num)
{
  local AdminPlus4Mut myMut;
  myMut = AdminPlus4Mut(findMut(Level.Game.BaseMutator,class'AdminPlus_v4.AdminPlus4Mut'));
  if(myMut!=none&&num<100&&num>=0)
  {
    myMut.SetHpConfig(num);
    ServerSay("Zeds hp set to "$ string(num));
  }
}
//================================================
//xPawn Commands for combos, invisibility, more
/*exec function CrateComboOn(string target){
	
	local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          	  		  	if (C.Pawn.Role == ROLE_Authority){
        					Effect = Spawn(class'CrateActor', C.Pawn,, C.Pawn.Location + C.Pawn.CollisionHeight * vect(0,0,0.55), C.Pawn.Rotation);
        					C.Pawn.ClientMessage("Camouflage");
          	  		  	}
          	  	  	}
          	  	}
          	  	return;
          	} else if (target == ""){
        		P = verifyTarget(target);
				if (P.Role == ROLE_Authority){
        			Effect = Spawn(class'CrateActor', C.Pawn,, C.Pawn.Location + C.Pawn.CollisionHeight * vect(0,0,0.55), C.Pawn.Rotation);
          	  		P.ClientMessage("Camouflage");
          	  	}
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					if (C.Pawn.Role == ROLE_Authority){
        						Effect = Spawn(class'CrateActor', C.Pawn,, C.Pawn.Location + C.Pawn.CollisionHeight * vect(0,0,0.55), C.Pawn.Rotation);
          	  		  			C.Pawn.ClientMessage("Camouflage");
          	  		  		}
          				}
          			}
          		}
       		}
		}
	}
}

exec function CrateComboOff(string target){

	local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          	  		  	if (C.Pawn.Role == ROLE_Authority){
        					if (Effect != None){
        						Effect.Destroy();
        					}
          	  		  		C.Pawn.ClientMessage("Camouflage Removed");
          	  		  	}
          	  	  	}
          	  	}
          	  	ClientMessage("use 'Admin KillAll Crateactor' to get rid of all crates (its bugged)");
          	  	return;
          	} else if (target == ""){
        		P = verifyTarget(target);
        		P.ClientMessage(MSG_ChangeSize);
				if (P.Role == ROLE_Authority){
        			if (Effect != None)
        				Effect.Destroy();
          	  		P.ClientMessage("Camouflage Removed");
          	  	}
          	  	ClientMessage("use 'Admin KillAll Crateactor' to get rid of all crates (its bugged)");
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					if (C.Pawn.Role == ROLE_Authority){
        						if (Effect != None)
        							Effect.Destroy();
          	  		  			C.Pawn.ClientMessage("Camouflage Removed");
          	  		  			ClientMessage("use 'Admin KillAll Crateactor' to get rid of all crates (its bugged)");
          	  		  		}
          				}
          			}
          		}
       		}
		}
	}
}

exec function SpeedComboOn(string target){

	local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;

	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         	
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          	  		  	if (C.Pawn.GroundSpeed > 500){
          						return;	
          				}
          	   		  	LeftTrail = Spawn(class'SpeedTrail', C.Pawn,, C.Pawn.Location, C.Pawn.Rotation);
    					C.Pawn.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    					C.Pawn.AttachToBone(LeftTrail, 'lfoot');
    					RightTrail = Spawn(class'SpeedTrail', C.Pawn,, C.Pawn.Location, C.Pawn.Rotation);
    					C.Pawn.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    					C.Pawn.AttachToBone(RightTrail, 'rfoot');
      					C.Pawn.AirControl *= 1.4;
    					C.Pawn.GroundSpeed *= 1.4;
    					C.Pawn.WaterSpeed *= 1.4;
    					C.Pawn.AirSpeed *= 1.4;
    					C.Pawn.JumpZ *= 1.5;
          	  			C.Pawn.ClientMessage("Speed Boost Combo");
          	  	  	}
          	  	}
          	  	return;
          	} else if (target == ""){
        		P = verifyTarget(target);
        		if (P.GroundSpeed > 500){
          			return;	
          		}
        		LeftTrail = Spawn(class'SpeedTrail', P,, P.Location, P.Rotation);
    			P.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    			P.AttachToBone(LeftTrail, 'lfoot');
    			RightTrail = Spawn(class'IonCore', P,, P.Location, P.Rotation);
    			P.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    			P.AttachToBone(RightTrail, 'rfoot');
    			P.AirControl *= 1.4;
       			P.GroundSpeed *= 1.4;
    			P.WaterSpeed *= 1.4;
    			P.AirSpeed *= 1.4;
    			P.JumpZ *= 1.5;
          	  	P.ClientMessage("Speed Boost Combo");
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					if (C.Pawn.GroundSpeed > 500){
          						return;	
          					}
          					LeftTrail = Spawn(class'SpeedTrail', C.Pawn,, C.Pawn.Location, C.Pawn.Rotation);
    						C.Pawn.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    						C.Pawn.AttachToBone(LeftTrail, 'lfoot');
    						RightTrail = Spawn(class'SpeedTrail', C.Pawn,, C.Pawn.Location, C.Pawn.Rotation);
    						C.Pawn.controller.PlaySound(sound'GameSounds.Combo.ComboActivated',,255);
    						C.Pawn.AttachToBone(RightTrail, 'rfoot');
    						C.Pawn.AirControl *= 1.4;
    						C.Pawn.GroundSpeed *= 1.4;
    						C.Pawn.WaterSpeed *= 1.4;
    						C.Pawn.AirSpeed *= 1.4;
    						C.Pawn.JumpZ *= 1.5;
          	  				C.Pawn.ClientMessage("Speed Boost Combo");
          				}
          			}
          		}
       		}
		}
    }
}

exec function SpeedComboOff(string target){
    
    local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;
    
    myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
    					//Level.Game.SetPlayerDefaults(C.Pawn);
    					If (C.Pawn.GroundSpeed > 500) {
    						C.Pawn.AirControl /= 1.4;
    						C.Pawn.GroundSpeed /= 1.4;
    						C.Pawn.WaterSpeed /= 1.4;
    						C.Pawn.AirSpeed /= 1.4;
    						C.Pawn.JumpZ /= 1.5;
    						C.Pawn.ClientMessage("Bye Bye Speedy");
    					}
					}
				}
				return;
          	} else if (target == ""){
        		P = verifyTarget(target);
         		If (P.GroundSpeed > 500) {
    				P.AirControl /= 1.4;
    				P.GroundSpeed /= 1.4;
    				P.WaterSpeed /= 1.4;
    				P.AirSpeed /= 1.4;
    				P.JumpZ /= 1.5;
    				P.ClientMessage("Bye Bye Speedy");
    			}
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					//Level.Game.SetPlayerDefaults(C.Pawn);
          					If (C.Pawn.GroundSpeed > 500) {
    							C.Pawn.AirControl /= 1.4;
    							C.Pawn.GroundSpeed /= 1.4;
    							C.Pawn.WaterSpeed /= 1.4;
    							C.Pawn.AirSpeed /= 1.4;
    							C.Pawn.JumpZ /= 1.5;
    							C.Pawn.ClientMessage("Bye Bye Speedy");
    						}
          				}
          			}
          		}
       		}
       		//if (LeftTrail != None){
        		log("lefttraildestroy");
        		LeftTrail.Destroy();
        	//}
	    	//if (RightTrail != None){
        		RightTrail.Destroy();
        	//}
		}
	}
}

exec function InvisComboOn(string target){

	local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;
	//local xPawn XP;
	
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          	  		  	C.Pawn.ClientMessage("Invisibility Combo");
				  		xPawn(C.Pawn).SetInvisibility(80.0);
          	  	  	}
          	  	}
          	  	return;
          	} else if (target == ""){
         		P = verifyTarget(target);
         		xPawn(P).SetInvisibility(80.0);
         		P.ClientMessage("Invisibility Combo");
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					C.Pawn.ClientMessage("Invisibility Combo");
							xPawn(C.Pawn).SetInvisibility(80.0);
          				}
          			}
          		}
       		}
   		}
	}
}

exec function InvisComboOff(string target){

	local Mutator myMut;
	local Pawn P;
	local Controller C;
	local int namematch;
	//local xPawn XP;
	
	myMut = findMut(Level.Game.BaseMutator, class'AdminPlus_v4.AdminPlus4Mut');
    if (myMut != none) {
       	if (AdminPlus4Mut(myMut).CombosEnabled()){
         
          	if (target == "all") {
          	  	for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	      	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          	  		  	C.Pawn.ClientMessage("Visible");
					  	xPawn(C.Pawn).SetInvisibility (0.0);
          	  	  	}
          	  	}
          	  	return;
          	} else if (target == ""){
        		P = verifyTarget(target);
         		xPawn(P).SetInvisibility(0.0);
         		P.ClientMessage("Visible");
        		return;
        	} else {
          		P = verifyTarget(target);
          		if (P == none){
             		return;
           		}
          		for( C = Level.ControllerList; C != None; C = C.nextController ) {
          	    	if( C.IsA('PlayerController') || C.IsA('xBot')) {
          				namematch = InStr( Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 
          				if (namematch >=0) { 
          					C.Pawn.ClientMessage("Invisible");
							xPawn(C.Pawn).SetInvisibility (0.0);
          				}
          			}
          		}
       		}
   		}
	}
}*/


//=========================================================================

defaultproperties
{
	MSG_LoadedOn="You Have Been Loaded with KF Weapons"
	MSG_GodOn="You are in God mode."
	MSG_GodOff="You are no longer in God Mode."
	MSG_Ghost="You can move through walls."
	MSG_Fly="You can fly."
	MSG_ChangeScore="Admin changed your money ammount;"
	MSG_Spider="You can walk on walls, but try not to jump."
	MSG_Walk="You are in normal walking mode."
	MSG_InvisOn="You became invisible to other players, not zeds."
	MSG_InvisOff="You are no longer invisible, we can see you"
	MSG_TempAdmin="You can now Log in as a Temporary Admin. Just type: adminlogin in the console."
	MSG_TempAdminOff="You are no longer Logged In as an Admin."
	MSG_ChangeName="Your name has been changed."
	MSG_ReSpawned="You are back in the game."
	MSG_CantRespawn="Can't spawn players between the waves."
	MSG_ChangeSize="Your head size is resized."
	MSG_GiveItem="You have a gift from the admin!"
	MSG_Adrenaline="You got Full Adrenaline!"
	MSG_Help1="This is a complete list of commands.(Some may be disabled)"
	MSG_Help2="Always put the word admin before the command. For example: admin ghost"
	MSG_Help3="Ghost/Walk/Spider/Fly disabled for bots"
	MSG_Help4="Most teams can be executed by other players by name, partial name or, 'ALL'"
	MSG_Help5="Examples: Admin Loaded Body, Admin Ghost Senator, Admin Godon All"
	MSG_Help6="--------------------------------------------------------------------------------"
	MSG_Help7="GodOn / Godoff - Invulnerability                  | Ex:  'admin GodOn all'"
	MSG_Help8="InvisOn / InvisOff - Invisibility                 | Ex:  'admin InvisOn Brock'"
	MSG_Help9="Loaded - Give all weapons                         | Ex:  'admin Loaded all'"
	MSG_Help10="Help - Display Help                              | Ex:  'admin help'"
	MSG_Help12="Fly - flight mode                                | Ex:  'admin fly Jak'"
	MSG_Help14="Walk - Return to Walk Mode                       | Ex:  'admin walk all'"
	MSG_Help11="Ghost - Ghost Mode                               | Ex:  'admin ghost Jakob'"
	MSG_Help13="Spider - Spider Mode (Wall Climbing)             | Ex:  'admin spider Luna'"
	MSG_Help15="Fatality - Take Revenge On a Player              | CauseEvent - Trigger an In-Game Event"
	//MSG_Help16="InvisComboOn/InvisComboOff - Toggle Invisi Combo"
	//MSG_Help17="CrateComboOn/CrateComboOff - Toggle Crate Combo"
	//MSG_Help18="SpeedComboOn/SpeedComboOff - Toggle Speed Combo"
	MSG_Help19="Slap <target_nick> - Spank player"
	//MSG_Help20="CustomLoaded1,2,3 - Loads Custom Weapons that you set in the server ini file"
	MSG_Help21="TempAdmin - Grants Temporary Admin Status (Only Works on Single Admin Systems"
	MSG_Help22="TempAdminOff - Removes Temporary Admin Status (Only Works on Single Admin Systems"
	MSG_Help23="ChangeName/CN <old_name> <new_name> - Change player name"
	MSG_Help24="HeadSize <target_name> <size> - Change player head size (1 = default)"
	MSG_Help25="PlayerSize <target_name> <size> - Change player size (1 = default)"
	MSG_Help26="GiveItem/GI [weaponclass] - Give weapons or full adrenaline to a player.Type Admin HelpWeapon."
	MSG_Help27="Summon <class> - Summon before you.Type Admin HelpZeds or check workshop's readme for more zeds/pickup."
	MSG_Help28="AdvancedSummon <class> <target_name> - Summon a monster near the target player"
	MSG_Help29="ChangeScore	<target_nick> <new_score_value> ,ResetScore <target>"
	MSG_Help30="ResetScore - Reset Player's Money Amount"
	MSG_Help31="Respawn <target> - Respawn single player or all"
	MSG_Help32="SetGravity/SG <gravity> - Gravity Change (-950 = default)"
	MSG_Help33="Teleport - Teleport to the surface you are looking at"
	MSG_Help34="PrivMessage/PM - Allows you to send a message to individual players"
	MSG_Help35="DNO - Disable Next Objective In Assault Games"
 	MSG_Help36="Slomo <int> - Change game speed"
  MSG_Help37="KillAllZeds - Kill all spawned zeds"
  MSG_Help38="ClearLevel - Destroy all weapon pickup on the ground"
  MSG_Help39="SavePeople <saver fullname> <saved fullname> - Move someone to saver aside."
  MSG_Help40="TraderTime <int> - Set trader time."
  MSG_Help41="WaveNum <int> - Set wave number."
  MSG_Help42="ViewOn <target> / ViewOff - Spectate somebody."
  MSG_Help43="ChangePerk <perkClassName> <target> - Change perk Instantly.Type Admin HelpPerk for more details."
  MSG_Help44="RemoveItem <ItemName> <target> - Allow you to remove somebody's specific item.Type Admin HelpWeapon."
  MSG_Help45="MaxZedsNum <number> - Set max existed zeds num."
  MSG_Help46="MaxPlayersNum <number> - Set Max　players count."
  MSG_Help47="SpawnMod <float> - Multiply default spawn intervel."
  MSG_Help48="HpConfig <num> - Set zeds health scale."
  MSG_Help49="FakedPlayers <num> - Set faked players count."
  MSG_Help50="ReadyAll - Set all players ready to play."
}
