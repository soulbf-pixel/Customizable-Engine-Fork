package utility;

import sys.FileSystem;
import flixel.FlxState;
import backend.ScriptedState;

class StateIntercepter {
    /**
     * Checks if a custom script exists for the requested state.
     * If it does, it returns a ScriptedState. Otherwise, it returns the default state.
     */
    public static function checkOverride(stateName:String, defaultState:FlxState):FlxState {
        var scriptPath = backend.Paths.mods('source/states/' + stateName + '.hx');
        
        if (FileSystem.exists(scriptPath)) {
            trace('Custom state found for $stateName! Overriding...');
            return new ScriptedState(stateName);
        }
        
        return defaultState;
    }
}