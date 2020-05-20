function [ scaled_input ] = piIlluminanceAdjustRect(input,r_patch,desiredIlluminance)
% Scale a scene or optical image so that a given rectangular patch reaches
% a specificed mean illuminance. 

switch(input.type)
    
    case {'scene'}
        scene_patch = sceneCrop(input,r_patch);
        currentLevel = sceneGet(scene_patch,'mean luminance');
        s = desiredIlluminance/currentLevel;
        
        scaled_input = sceneSet(input,'photons',sceneGet(input,'photons').*s);
        
    case {'opticalimage'}
        oi_patch = oiCrop(input,r_patch);
        currentLevel = oiGet(oi_patch,'mean illuminance');
        s = desiredIlluminance/currentLevel;
        
        scaled_input = oiSet(input,'photons',oiGet(input,'photons').*s);
end

end

