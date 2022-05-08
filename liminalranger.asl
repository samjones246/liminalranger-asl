state("LiminalRanger Windows 1.3")
{
    bool frozen : 0x021D9760, 0x408;

    bool isLoading : 0x021D9B80, 0xF0, 0x108, 0x8, 0x108, 0x0, 0x14;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[liminalranger ASL] " + output));

    // Create settings for which splits to enable
    settings.Add("textCrawl", true, "Split after Intro");
    settings.Add("S_Main", true, "Split after Car Park 1");
    settings.Add("officeBlankworld_1", true, "Split after Office 1");
    settings.Add("learnArea", true, "Split after Tutorial");
    settings.Add("officeBlankworld_2", true, "Split after Office 2");
    settings.Add("walnutBlankworld", true, "Split after Concordia (Entrance)");
    settings.Add("Hallway", true, "Split after Concordia (Main)");
    settings.Add("officeBlankworld_3", true, "Split after Office 3");
    settings.Add("hotelBlankworld", true, "Split after Hotel (Entrance)");
    settings.Add("Room", true, "Split after Hotel (Main)");
    settings.Add("officeBlankworld_4", true, "Split after Office 4");
    settings.Add("alleyBlankworld", true, "Split after Corridor (Entrance)");
    settings.Add("Corridor1", true, "Split after Something's Off");
    settings.Add("Corridor2", true, "Split after Corridor (Main)");
    settings.Add("officeBlankworld_5", true, "Split after Office 5 (Normal ending only)");

}

init
{
    // Variable to store the id of the level, since the levelid address is volatile during level transitions
    vars.officeVisit = 1;

    // Freezes left before true ending
    vars.teFreezesLeft = 3;

    // SceneTree.singleton.current_scene.data.scene_file_path
    vars.sceneNamePtr = new MemoryWatcher<int>(new DeepPointer("LiminalRanger Windows 1.3.exe", 0x21D9B80, 0x1D0, 0xD8));
    current.levelname = "";
}

update {
    vars.sceneNamePtr.Update(game);
    old.levelname = current.levelname;
    current.levelname = game.ReadString(new IntPtr(vars.sceneNamePtr.Current), 256).Split('/').Last().Split('.').First();
    if (current.levelname != old.levelname){
        vars.Log("Level changed to " + current.levelname);
    }
}

start
{
    return old.levelname == "mainmenu" && current.levelname == "openingAlley";
}

isLoading
{
    return current.isLoading;
}

split
{
    // Split when changing scene if that transition is enabled in the settings
    if (current.levelname != old.levelname){
        // Normal Ending
        if (old.levelname == "S_Main Night"){
            return true;
        }
        // Office visits
        bool split = false;
        if (old.levelname == "officeBlankworld"){
            if (settings["officeBlankworld_" + vars.officeVisit]){
                split = true;
            }
            vars.officeVisit++;
            return split;
        }

        // Everything else
        return settings[old.levelname];
    }

    // True ending
    if (current.levelname == "GlowingHalls"){
        if (current.frozen && !old.frozen){
            if (vars.teFreezesLeft == 0){
                return true;
            }else{
                vars.teFreezesLeft -= 1;
            }
            vars.Log("Freezes left: " + vars.teFreezesLeft);
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