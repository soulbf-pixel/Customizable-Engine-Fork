package;

import sys.FileSystem;
import sys.io.File;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

using StringTools;

class ModSourceCodeLoader {
    public static var loadedScripts:Map<String, Iris> = new Map();
    public static var scriptRegistry:Map<String, Dynamic> = new Map();

    public static function loadModScripts(modFolder:String):Void {
        var sourceDir = modFolder + "/source";

        if (!FileSystem.exists(sourceDir) || !FileSystem.isDirectory(sourceDir)) {
            trace('[$modFolder] No source folder found, skipping script load.');
            return;
        }

        trace('[$modFolder] Found source folder, scanning for scripts...');
        scanAndLoad(sourceDir);
    }

    static function scanAndLoad(dir:String):Void {
        for (entry in FileSystem.readDirectory(dir)) {
            var fullPath = dir + "/" + entry;

            if (entry.endsWith(".hx")) {
                executeScript(fullPath);
            }
        }
    }

    static function executeScript(path:String):Void {
        try {
            trace('Loading script: $path');

            var script = new Iris(File.getContent(path), {
                name: path,
                autoRun: false,
                autoPreset: true // auto-exposes common classes
            });

            setupScript(script);

            script.execute();

            loadedScripts.set(path, script);
            trace('Script loaded OK: $path');
        } catch (e:Dynamic) {
            trace('ERROR loading script $path: $e');
        }
    }

    public static function setupScript(script:Iris):Void {
        // Just add your custom ones here

        script.set("Paths", backend.Paths);
        script.set("Mods", backend.Mods);
        script.set("Language", backend.Language);
        script.set("ClientPrefs", backend.ClientPrefs);
        script.set("Conductor", backend.Conductor);
        script.set("CoolUtil", backend.CoolUtil);
        script.set("Highscore", backend.Highscore);
        script.set("Rating", backend.Rating);

        script.set("PlayState", states.PlayState);
        script.set("FreeplayState", states.FreeplayState);
        script.set("StoryMenuState", states.StoryMenuState);
        script.set("TitleState", states.TitleState);
        script.set("LoadingState", states.LoadingState);
        script.set("CreditsState", states.CreditsState);
        script.set("ModsMenuState", states.ModsMenuState);

        script.set("CharacterEditorState", states.editors.CharacterEditorState);
        script.set("ChartingState", states.editors.ChartingState);

        script.set("GameOverSubstate", substates.GameOverSubstate);
        script.set("PauseSubState", substates.PauseSubState);
        script.set("OutdatedSubState", substates.OutdatedSubState);
        script.set("ResetScoreSubState", substates.ResetScoreSubState);

        script.set("DialogueBoxPsych", cutscenes.DialogueBoxPsych);
        script.set("DialogueBox", cutscenes.DialogueBox);
        script.set("DialogueCharacter", cutscenes.DialogueCharacter);
        script.set("CutsceneHandler", cutscenes.CutsceneHandler);

        script.set("VideoSprite", objects.VideoSprite);

        script.set("registerClass", ModSourceCodeLoader.registerClass);
        script.set("getClass", ModSourceCodeLoader.getClass);
    }

    public static function setOnAll(varName:String, value:Dynamic):Void {
        for (script in loadedScripts)
            script.set(varName, value);
    }

    public static function callOnAll(funcName:String, args:Array<Dynamic>):Void {
        for (path => script in loadedScripts) {
            try {
                var result = script.call(funcName, args);
            } catch (e:Dynamic) {
                trace('Error calling $funcName in $path: $e');
            }
        }
    }

    public static function registerClass(name:String, obj:Dynamic):Void {
        scriptRegistry.set(name, obj);
        setOnAll(name, obj);
        trace('Registered class: $name');
    }

    public static function getClass(name:String):Dynamic {
        return scriptRegistry.get(name);
    }

    public static function clearScripts():Void {
        loadedScripts.clear();
    }
}