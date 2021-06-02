%% The new approach to parsing is illustrated here for PBRT V3
%
% We reformat various types of pbrt files into a standard format.  This
% format is output by PBRT (V3) itself, when we use the 'toply' switch
%
%    pbrt -toply ....
%
% We describe several different cases.
%
% N.B: Amy and David know something useful about reading the ply format
% into Matlab if we want to.  They figured out how to do it correctly.
%
% NOTES:
%
% 1. The piRead method now takes a lot longer to run because it calls the
% Docker container and converts the file into a new format.  Probably we
% should run the conversion on all the files in data/V3 so that it will
% bypass the conversion.
%
% 2.
%
%%
ieInit;

%% Illustrate the teapot scene

% The teapot scene in its original form does not have assets that can be
% parsed.  So in this case, the 'formatted' output does not have any 'ply'
% files.
% thisR = piRecipeDefault('scene name','teapot','toply',true);

fname = fullfile(piRootPath,'data','V3','SimpleScene','SimpleScene.pbrt');
% fname = fullfile(piRootPath,'data','V3/ChessSet/ChessSet.pbrt');
% Format the file
formattedFname = piPBRTReformat(fname);
% As normal
thisR = piRead(formattedFname);
% click on the asset showed in the GUI, thisAsset data is returned. 
thisR.assets.showUI;
thisR.set('film resolution',[300 200]*1.5);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5);

piWrite(thisR);

%%
disp('*** Rendering...')
[scene,result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);
% scene = sceneSet(scene, 'scene name',name);


%%
sceneFolder = fullfile(piRootPath, 'data');

namelist = { ...
    fullfile(sceneFolder,'blender/BlenderScene/BlenderScene.pbrt'),...
    fullfile(sceneFolder,'/V3/teapot/teapot-area-light.pbrt')...
    fullfile(sceneFolder, 'V3/cornell_box/cornell_box.pbrt'),...
    fullfile(sceneFolder, 'V3/SimpleScene/SimpleScene.pbrt'),...
    % '/Users/zhenyi/Downloads/kitchen/scene.pbrt'...
    % '/Users/zhenyi/Downloads/classroom/scene.pbrt',...
    fullfile(sceneFolder,'V3/ChessSet/ChessSet.pbrt'), ...
    };
%%
for ii = 7%1:numel(namelist)
    fname = namelist{ii};
    [~,name,~]=fileparts(fname);
    thisR = piRead(fname,'toply',true);
    
    thisR.set('film resolution',[300 300]*1.5);
    thisR.set('rays per pixel',32);
    thisR.set('fov',30);
    thisR.set('nbounces',5);
    if ii ==1
        infiniteLight = piLightCreate('infiniteLight','type','infinite','spd','D65');
        thisR.set('light','add',infiniteLight);
        % thisR = piLightAdd(thisR,'type','infinite','light spectrum','D65');
    end
    %%
    piWrite(thisR);
    %%
    disp('*** Rendering...')
    [scene,result] = piRender(thisR,'render type','radiance');
    sceneWindow(scene);
    scene = sceneSet(scene, 'scene name',name);
    %%
    % depth = piRender(thisR,'render type','depth');
    % figure;imagesc(depth);
    
end

%% move chess set

