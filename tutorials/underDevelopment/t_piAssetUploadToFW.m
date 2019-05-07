%% Flywheel asset creation and uploading
%
% This script illustrates how to create a set of files that we upload
% to FLywheel to serve as assets for later scene assembly.
%
% ZL, BW Vistasoft Team, 2018
%% Initialize ISETCAM and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%%
tic
for dd =87
    % The students have been producing these files on SNI shared storage
    mainPath = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets';
    assetType = 'car';
    assetname = sprintf('Car_%03d',dd);
    % assetname ='city_cross_6lanes_001';
    % assetType = 'suburb_1';
    % assetname = sprintf('building_%03d',dd);
    
    % assetType = 'city_1';
    % assetname = sprintf('building_%03d',dd);
    % sourceTex = fullfile(mainPath,assetType,assetname,'texture');
    % movefile(sprintf('%s/*.png',sourceTex),targetTex);
    %  end
    % fname = '/Users/zhenyiliu/Desktop/cross/cross.pbrt';
    
    fname = fullfile(mainPath,assetType,assetname,sprintf('%s.pbrt',assetname));
    if ~exist(fname,'file'), error('File not found'); end
    
    % When we read, we also write a JSON recipe.
    thisR = piRead(fname,'version',3);
    %%
    
    %% Change render quality
    
    % We might decide to make a funciton that sets some defaults so that
    % people could relatively quickly have a look at the rendered object.
    
    thisR.set('filmresolution',[640 480]);
    for ii = 1:length(thisR.assets)
        if ~isempty(thisR.assets(ii).children), index = ii;
        end
    end
    h = thisR.assets(index).size.h;
    l = thisR.assets(index).size.l;
    w = thisR.assets(index).size.w;
    d = -h*2/3;
    % % thisR.lookAt.from = [h*1.25/2/sind(23)*cosd(23) h/2-h*0.08 0.5];
    thisR.lookAt.to = [0 h/2 0];
    thisR.lookAt.from = [l*0.85 h+0.3 l*0.5];%Car
    % % thisR.lookAt.from = [-l*0.3 h*0.25 -h*1.25/2/sind(23)*cosd(23)]; %building
    % thisR.lookAt.to   = [0 0 0];% car
    % % thisR.lookAt.to   = [l/2 h/2+1 w/2];% building
    % thisR.lookAt.up   = [0 1 0];
    thisR.set('pixelsamples',16);
    thisR.integrator.maxdepth.value = 10;
    thisR.integrator.subtype = 'bdpt';
    thisR.sampler.subtype = 'sobol';
    thisR.camera.fov.value = 43.5;
    %% Add skymap a default day time sky map
    piSkymapAdd(thisR,'noon');
    
    %% Assign Materials and Color
    thisR.materials.lib = piMateriallib;
    piMaterialGroupAssign(thisR);
    %% Write out the
    % assetname = 'Road_cross';
    [~,n,e] = fileparts(fname);
    thisR.set('outputFile',fullfile(piRootPath,'local',assetname,[n,e]));
    
    piWrite(thisR,'creatematerials',true);
    %% zip the folder
    folder = fullfile(piRootPath,'local',assetname);
    chdir(folder);
    resourceFile = sprintf('%s.cgresource.zip',assetname);
    
    zip(resourceFile,{'textures','scene'});
    oldRecipeFile = sprintf('%s.json',assetname);
    recipeFile = sprintf('%s.recipe.json',assetname);
    movefile(oldRecipeFile,recipeFile);
    
    % Render a pngfile
    [scene,result] = piRender(thisR,'rendertype','radiance');
    pngFigure = sceneGet(scene,'rgb image');
    pngFile = pngFigure.^(1/1.5); % for Tree, too dark.
    figure;
    imshow(pngFile);
    pngfile = sprintf('%s.png',assetname);
    imwrite(pngFile,pngfile);
    
    %%  We upload the .cgresource.zip and the .json file
    
    % There could be an stScitranConfig
    st = scitran('stanfordlabs');
    
    subject = st.lookup('wandell/Graphics auto/assets');
    thisSession = subject.sessions.findOne(sprintf('label=%s',assetType));
    %%
    current_acquisitions = assetname;
    acquisition = thisSession.acquisitions.findOne(sprintf('label=%s',assetname));
    
    if ~isempty(acquisition)
        
        % Upload the two files and set their modality.
        st.fileUpload(recipeFile,acquisition.id,'acquisition');
        fprintf('%s uploaded \n',recipeFile);
        st.fileUpload(resourceFile,acquisition.id,'acquisition');
        fprintf('%s uploaded \n',resourceFile);
        
        %         st.fileUpload(pngfile,acquisition.id,'acquisition');
        %         fprintf('%s uploaded \n',pngfile);toc
    else
        current_id = st.containerCreate('Wandell Lab', 'Graphics auto',...
            'session',assetType,'acquisition',current_acquisitions);
        if ~isempty(current_id.acquisition)
            fprintf('%s acquisition created \n',current_acquisitions);
        end
        st.fileUpload(recipeFile,current_id.acquisition,'acquisition');
        fprintf('%s uploaded \n',recipeFile);
        st.fileUpload(resourceFile,current_id.acquisition,'acquisition');
        fprintf('%s uploaded \n',resourceFile);
        st.fileUpload(pngfile,current_id.acquisition,'acquisition');
        fprintf('%s uploaded \n',pngfile);toc
        %     st.fileUpload(objFile,current_id.acquisition,'acquisition');
        %     fprintf('%s uploaded \n',objFile);
    end
    %%
    fprintf('%d asset uploaded \n',dd);
end
disp('>>>>>>>>>>>>>>Done!<<<<<<<<<<<<<<<<<<')
toc
%%
