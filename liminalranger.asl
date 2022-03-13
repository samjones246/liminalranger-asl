state("liminal ranger 1.2")
{
    // Pointer to the id for the current level
    int levelid : 0x20938E0;
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
            print("LIMINALRANGER_ASL - First 1");
            vars.ready = 1;
        }
        if (vars.ready == 2){
            vars.ready = 0;
            print("LIMINALRANGER_ASL - Starting timer");
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
            print("LIMINALRANGER_ASL - Split");
            return true;
        }

    // On last level, split as soon as levelid changes to anything higher than current, as this indicates the end cutscene is loading
    }else{
        if (current.levelid > vars.split){
            print("LIMINALRANGER_ASL - Done");
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