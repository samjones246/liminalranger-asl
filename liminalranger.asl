state("liminal ranger 1.2")
{
    // Pointer to the id for the current level
    int levelid : 0x20938E0;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[liminalranger ASL] " + output));

    // Create settings for which splits to enable
    settings.Add("1", true, "Split after Intro");
    settings.Add("2", true, "Split after Car Park 1");
    settings.Add("3", true, "Split after Office 1");
    settings.Add("4", true, "Split after Tutorial");
    settings.Add("5", true, "Split after Office 2");
    settings.Add("6", true, "Split after Concordia (Entrance)");
    settings.Add("7", true, "Split after Concordia (Main)");
    settings.Add("8", true, "Split after Office 3");
    settings.Add("9", true, "Split after Hotel (Entrance)");
    settings.Add("10", true, "Split after Hotel (Main)");
    settings.Add("11", true, "Split after Office 4");
    settings.Add("12", true, "Split after Corridor (Entrance)");
    settings.Add("13", true, "Split after Something's Off");
    settings.Add("14", true, "Split after Corridor (Main)");
    settings.Add("15", true, "Split after Office 5");
}

init
{ 
    // Variable to store the id of the level, since the levelid address is volatile during level transitions
    vars.split = 1;

    // Used to keep track of madness when game starts up
    vars.ready = 0;
}

start
{
    // If levelid is 0 after having been 1, madness is over and player is in the menu
    if (current.levelid == 0){
        if (vars.ready == 1){
            vars.ready = 2;
        }
        return false;
    }
    // If levelid is 1, either it's pre-menu madness or the player has started the first level
    if (current.levelid == 1){
        if(vars.ready == 0){
            vars.ready = 1;
        }
        if (vars.ready == 2){
            vars.ready = 0;
            vars.Log("Starting Timer");
            return true;
        }
    }
    return false;
}

split
{
    // Split when levelid increments, and update vars.split
    if (vars.split < 16){
        if (current.levelid == vars.split + 1){
            vars.split = current.levelid;
            vars.Log("Splitting");
            // Only split if this split is enabled in settings
            if(settings[(vars.split - 1).ToString()]){
                return true;
            }
        }

    // On last level, split as soon as levelid changes to anything higher than current, as this indicates the end cutscene is loading
    }else{
        if (current.levelid > vars.split){
            vars.Log("Final Split");
            return true;
        }
    }
    return false;
}

exit
{
    print("LIMINALRANGER_ASL - EXIT");
    vars.ready = 0;
    vars.split = 1;
}