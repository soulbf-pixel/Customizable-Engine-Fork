package backend;

import backend.MusicBeatState;
import crowplexus.iris.Iris;
import sys.FileSystem;
import sys.io.File;
import backend.Paths;
import ModSourceCodeLoader;

class ScriptedState extends MusicBeatState {
    public var script:Iris;
    public var scriptName:String;

    public function new(scriptName:String) {
        super();
        this.scriptName = scriptName;
    }

    override function create() {
        var scriptPath = Paths.mods('source/states/' + scriptName + '.hx');

        if (FileSystem.exists(scriptPath)) {
            try {
                script = new Iris(File.getContent(scriptPath), {
                    name: scriptName,
                    autoRun: false,
                    autoPreset: true
                });

                ModSourceCodeLoader.setupScript(script);

                script.set("add", this.add);
                script.set("remove", this.remove);
                script.set("controls", this.controls);
                script.set("state", this);

                script.execute();

                script.call("create", []);

            } catch(e:Dynamic) {
                trace('Error loading state script $scriptName: $e');
            }
        } else {
            trace('Could not find state script for: $scriptName');
        }

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (script != null) script.call("update", [elapsed]);
    }

    override function destroy() {
        if (script != null) script.call("destroy", []);
        super.destroy();
    }

    override function beatHit() {
        if (script != null) script.call("beatHit", []);
        super.beatHit();
    }

    override function stepHit() {
        if (script != null) script.call("stepHit", []);
        super.stepHit();
    }
}