//-----------------------------------------------------------
//	Class:	MCM_UIButton
//	Author: Mr. Nice
//	
//-----------------------------------------------------------


class MCM_UIButton extends UIButton;

var int iButton;
var XComInputBase PlayerInput;
var float prevfTime;
var bool bControllerActive;

simulated function UIButton InitButton(optional name InitName, optional string InitLabel, optional delegate<OnClickedDelegate> InitOnClicked, optional EUIButtonStyle InitStyle = -1, optional name InitLibID = '')
{
	PlayerInput = XComInputBase(`LOCALPLAYERCONTROLLER.PlayerInput);
	bControllerActive = `ISCONTROLLERACTIVE;
	return Super.InitButton(InitName, InitLabel, InitOnClicked, InitStyle, InitLibID);
}

function StartInputListener(optional int kButton)
{
	if (kButton != 0)
	{
		iButton = kButton;
	}
	PlayerInput.Subscribe(iButton, 7*24*60*60, ResetPrevfTime);
	prevfTime = 0;
	SetTickIsDisabled(false);
}

function StopInputListener()
{
	PlayerInput.Unsubscribe(ResetPrevfTime);
	prevfTime = -1;
	SetTickIsDisabled(true);
}

function ResetPrevfTime()
{
	prevfTime = 0; // Somehow the button has been waiting 7 days?! Anyhow, guess we'll miss a a tick of monitoring then soldier on...
}

simulated event Tick(float DeltaTime)
{
	local float newfTime;

	if(prevfTime != -1)
	{
		newfTime = PlayerInput.GetIdler(iButton).fTime;
		if(NewfTime < prevfTime)
		{
			OnClickedDelegate(self);
		}
		prevfTime = newfTime;
	}

	// Mr. Nice: "Blinks" when controller/mouse swapped to fit in with other buttons
	if(!bIsVisible)
	{
		Show();
	}
	if (bControllerActive != `ISCONTROLLERACTIVE)
	{
		// Mr. Nice: Ok, the use has swapped interface type, need to refresh the button
		// Is there a better way then this? Maybe, but at least I don't just assume the button is enabled!
		// The other buttons get nuked and recreated, but this code is within the button, so less of an option...
		Hide();
		mc.FunctionVoid(IsDisabled ? "disable" : "enable");
		bControllerActive = !bControllerActive;
	}

	Super.Tick(DeltaTime);
}

defaultproperties
{
	bTickIsDisabled = true;
	bAlwaysTick = true;
}