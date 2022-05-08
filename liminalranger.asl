state("LiminalRanger Windows 1.3")
{
    // Pointer to the id for the current level
    int levelid : "ig9icd64.dll", 0xF406EC;

    bool frozen : 0x021D9760, 0x408;

    bool isLoading : 0x021D9B80, 0xF0, 0x108, 0x8, 0x108, 0x0, 0x14;
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
    settings.Add("15", true, "Split after Office 5 (Normal ending only)");

    settings.Add("trueEnd", false, "True Ending");
}

init
{ 
    // Variable to store the id of the level, since the levelid address is volatile during level transitions
    vars.split = 1;
    vars.MAX_SPLIT = settings["trueEnd"] ? 15 : 16;

    // Freezes left before true ending
    vars.teFreezesLeft = 3;
}

start
{
    if (old.isLoading && !current.isLoading && current.levelid == 1){
        return true;
    }
    return false;
}

isLoading
{
    return current.isLoading;
}

split
{
    // Split when levelid increments, and update vars.split
    if (vars.split < vars.MAX_SPLIT){
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
        if (settings["trueEnd"]){
            if (current.frozen && !old.frozen){
                if (vars.teFreezesLeft == 0){
                    return true;
                }else{
                    vars.teFreezesLeft -= 1;
                }
                vars.Log("Freezes left: " + vars.teFreezesLeft);
            }
        }
        else if (current.levelid > vars.split){
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