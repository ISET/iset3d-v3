%% Flywheel asset creation and uploading 
%
% This script illustrates how to create a set of files that we upload
% to FLywheel to serve as assets for later scene assembly.
%
% ZL, BW Vistasoft Team, 2018
%% Initialize ISETCAM and Docker
ieInit;
%if ~piDockerExists, piDockerConfig; end
%%
tic
for dd =1:34
%%
% index = ii;

% The students have been producing these files on SNI shared storage
mainPath = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets';
assetType = 'car';
assetname = sprintf('Car_%03d',dd);
% assetType = 'pedestrian';
% assetname = sprintf('pedestrian_%03d',dd);

% fname = '/Users/zhenyiliu/Desktop/cross/cross.pbrt';
fname = fullfile(mainPath,assetType,assetname,sprintf('%s.pbrt',assetname));
% fname = '/Users/zhenyiliu/Desktop/building_test/building_test.pbrt';
if ~exist(fname,'file'), error('File not found'); end

% When we read, we also write a JSON recipe.
thisR = piRead(fname,'version',3);

%% Change render quality

% We might decide to make a funciton that sets some defaults so that
% people could relatively quickly have a look at the rendered object.

thisR.set('filmresolution',[1280 720]);
thisR.set('pixelsamples',64);
thisR.integrator.maxdepth.value = 10;
thisR.integrator.subtype = 'bdpt';
thisR.sampler.subtype = 'sobol';

%% Add skymap a default day time sky map

piSkymapAdd(thisR,'day');
%  
%% Assign Materials and Color

piMaterialGroupAssign(thisR);
% piMaterialList(thisR);

% use piColorPick to wisely choose a black color.
% thisR.materials.list.NissanTitan_carbody_black_paint_base.colorkd = piColorPick('black');

%% Write out the 
% assetname = 'Road_cross';
[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',assetname,[n,e]));

piWrite(thisR);

%%
%{
%% Figure out where the sessions and acquisitions are
st = scitran('stanfordlabs');
st.verify;
hierarchy = st.projectHierarchy('Graphics assets');
%% Set the modality and some info data

modality = flywheel.model.Modality('id', 'CG', 'classification', struct('Aspect1', {{'value1', 'value2'}}))
fw.addModality(modality);

Then you should be able to do this:
st.fw.modifyAcquisitionFile(id, fileList{1}.name, struct('modality', 'CG'));


% The reosurce file should be Car_1.cgresource.zip
hierarchy = st.projectHierarchy('Graphics assets');
id = hierarchy.acquisitions{1}{1}.id;
a = st.fw.getAcquisition(id);
fileList = a.files;
fileList{1}.modality = 'CG';
j = jsonwrite(fileList{1})
s = struct('modality','CG');
j = jsonwrite(s);
st.fw.modifyAcquisitionFile(id, fileList{1}.name, j)


f1 = st.fw.getAcquisitionFileInfo(id, fileList{1}.name)
%}

%% zip the folder
% assetname = 'cross';
folder = fullfile(piRootPath,'local',assetname);
chdir(folder);
resourceFile = sprintf('%s.cgresource.zip',assetname);
% zip(resourceFile,{'texture','spds','skymaps','scene','bsdfs'});
zip(resourceFile,{'textures','scene'});

%%
oldRecipeFile = sprintf('%s.json',assetname);
recipeFile = sprintf('%s.recipe.json',assetname);
movefile(oldRecipeFile,recipeFile);
objFile = sprintf('%s.obj',assetname);

%%  We upload the .cgresource.zip and the .json file

% There could be an stScitranConfig
st = scitran('stanfordlabs');
hierarchy = st.projectHierarchy('Graphics assets');
sessions = hierarchy.sessions;
modality = st.fw.getModality('CG');

for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),'car')
        carSession = sessions{ii};
        break;
    end
end

%%
% Create the acquisition for this object
% First check whether an acquisition with this name exists

% st.fileUpload(...,'modality','CG');
current_acquisitions = assetname;
acquisitions = st.list('acquisition',carSession.id);
Acq_index = [];
for ii=1:length(acquisitions)
    if isequal(lower(acquisitions{ii}.label),lower(current_acquisitions))
        Acq_index = ii;
        % Upload the two files and set their modality.
        st.fileUpload(recipeFile,'acquisition',acquisitions{ii}.id);
        fprintf('%s uploaded \n',recipeFile);
        st.fileUpload(resourceFile,'acquisition',acquisitions{ii}.id);
        fprintf('%s uploaded \n',resourceFile);
%         st.fileUpload(objFile,'acquisition',acquisitions{ii}.id);
%         fprintf('%s uploaded \n',objFile);
    break;
       
       
    end
end
% create an acquisition
if isempty(Acq_index)
    current_id = st.containerCreate('Wandell Lab', 'Graphics assets',...
        'session','car','acquisition',current_acquisitions);
    if ~isempty(current_id.acquisition)
        fprintf('%s acquisition created \n',current_acquisitions);
    end
    st.fileUpload(recipeFile,'acquisition',current_id.acquisition);
    fprintf('%s uploaded \n',recipeFile);
    st.fileUpload(resourceFile,'acquisition',current_id.acquisition);
    fprintf('%s uploaded \n',objFile);
%     st.fileUpload(objFile,'acquisition',current_id.acquisition);
%     fprintf('%s uploaded \n',objFile);
end
fprintf('%d asset uploaded \n',dd);
end
disp('>>>>>>>>>>>>>>Done!<<<<<<<<<<<<<<<<<<')
toc
%%

%{
hierarchy = st.projectHierarchy('Graphics assets');
acquisitions = hierarchy.acquisitions;


cgClasses.model = {'Subaru','Mercedes','Ford','Volvo'};
modality = flywheel.model.Modality('id','CG','classification',cgClasses);
% First time
% st.fw.addModality(modality);
%
% Afterwards,
modalities = st.fw.getAllModalities;
% Find the one
id = modalities{2}.id;
st.fw.replaceModality(id,modality);
%}

%%  How to set a file's classification
%{
acquisitions = hierarchy.acquisitions{2};
thisAcquisition = acquisitions{1};
files = thisAcquisition.files{4};

% How do we adjust cInput?
% cInput = flywheel.model.ClassificationUpdateInput;
cInput = struct('modality','CG','classification',struct('asset','car'));
st.fw.modifyAcquisitionFile(thisAcquisition.id, files.name, struct('modality', 'CG'))
st.fw.setAcquisitionFileClassification(thisAcquisition.id, files.name, struct('asset',{{'car'}}))
%}
%{
% We think this follows the logic.  Let's ask JE what we should do
%
st.fw.replaceAcquisitionFileClassification(thisAcquisition.id, files.name, struct('asset',{{'car'}}))
%}

%%

% st.fw.modifyAcquisitionFileClassification(f.id, f.files{1}.name, cInput);

%% Render irradiance
% tic, oi = piRender(thisR); toc
% ieAddObject(oi); oiWindow;
