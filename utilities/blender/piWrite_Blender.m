function workingDir = piWrite_Blender(thisR,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: below added
% Adapted from piWrite.m to handle the exporter being set to 'Blender'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write a PBRT scene file based on its renderRecipe
%
% Syntax
%   workingDir = piWrite(thisR,varargin)
%
% The pbrt scene file and all the relevant resource files (geometry,
% materials, spds, others) are written out in a working directory. These
% are the files that will be mounted by the docker container and used by
% PBRT to create the radiance, depth, mesh metadata outputs.
%
% There are multiple options as to whether or not to overwrite files that
% are already present in the output directory.  The logic and conditions
% about these overwrites is quite complex right now, and we need to
% simplify.  
%
% In some cases, multiple PBRT scenes use the same resources files.  If you
% know the resources files are already there, you can set
% overwriteresources to false.  Similarly if you do not want to overwrite
% the pbrt scene file, set overwritepbrtfile to false.
%
% Input
%   thisR: a recipe object describing the rendering parameters.
%
% Optional key/value parameters
% There are too many of these options.  We hope to simplify
%
%   overwrite pbrtfile  - If scene PBRT file exists,    overwrite (default true)
%   overwrite resources - If the resources files exist, overwrite (default true) 
%   overwrite lensfile  - Logical. Default true  
%   overwrite materials - Logical. Default true
%   overwrite geometry  - Logical. Default true
%   overwrite json      - Logical. Default true
%   creatematerials     - Logical. Default false
%   lightsFlag         
%   thistrafficflow   
%
% Return
%    workingDir - path to the output directory mounted by the Docker
%                 container.  This is not necessary, however, because we
%                 can find it from thisR.get('output dir')
%
% TL Scien Stanford 2017
% JNM -- Add Windows support 01/25/2019
%
% See also
%   piRead, piRender

% Examples:
%{
 thisR = piRecipeDefault('scene name','MacBethChecker');
 % thisR = piRecipeDefault('scene name','SimpleScene');
 % thisR = piRecipeDefault('scene name','teapot');

 piWrite(thisR);
 scene =  piRender(thisR,'render type','radiance');
 sceneWindow(scene);
%}
%{
thisR = piRecipeDefault('scene name','chessSet');
lensfile = 'fisheye.87deg.6.0mm.json'; 

thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('film resolution',round([300 200]));
thisR.set('pixel samples',32);   % Number of rays set the quality.
thisR.set('focus distance',0.45);
thisR.set('film diagonal',10);
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype = 'sobol';
thisR.set('aperture diameter',3);

piWrite(thisR,'creatematerials',true);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);
%}
%{
piWrite(thisR,'overwrite resources',false,'overwrite pbrt file',true);
piWrite(thisR);
%}

%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;

% When varargin contains a number, the ieParamFormat() method fails.
% It takes only a string or cell.  We should look into that.
% varargin = ieParamFormat(varargin);

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));

% % JNM -- Why format variables twice?
% % Format the parameters by removing spaces and forcing lower case.
% if ~isempty(varargin), varargin = ieParamFormat(varargin); end

% Copy over the whole directory
p.addParameter('overwriteresources', true,@islogical);

% Overwrite the specific scene file
p.addParameter('overwritepbrtfile',true,@islogical);

% Force overwrite of the lens file
p.addParameter('overwritelensfile',true,@islogical);

% Overwrite materials.pbrt
p.addParameter('overwritematerials',true,@islogical);

% Overwrite geometry.pbrt
p.addParameter('overwritegeometry',true,@islogical);

% Create a new materials.pbrt
p.addParameter('creatematerials',false,@islogical);

% control lighting in geomtery.pbrt
p.addParameter('lightsflag',false,@islogical);

% Read trafficflow variable
p.addParameter('thistrafficflow',[]);

% Second rendering for reflectance calculation
% p.addParameter('reflectancerender',false,@islogical);

% Store JSON recipe for the traffic scenes
p.addParameter('overwritejson',true,@islogical);

p.parse(thisR,varargin{:});

overwriteresources  = p.Results.overwriteresources;
overwritepbrtfile   = p.Results.overwritepbrtfile;
overwritelensfile   = p.Results.overwritelensfile;
overwritematerials  = p.Results.overwritematerials;
overwritegeometry   = p.Results.overwritegeometry;
creatematerials     = p.Results.creatematerials;
lightsFlag          = p.Results.lightsflag;
thistrafficflow     = p.Results.thistrafficflow;
overwritejson       = p.Results.overwritejson;

%% Check exporter condition

% What we read and copy depends on how we got the PBRT files in the first
% place.  The exporter string identifies whether it is a C4D set of files,
% the most common for us, or another source that we are simply copying
% ('Copy') or just 'Unknown'.  We impose some constraints on the
% over-writing flags if the exporter is 'Copy'.
exporter = thisR.get('exporter');
switch exporter
    case 'Copy'
        creatematerials = false;
        overwritegeometry = false;
        overwritematerials = false;
        overwritejson = false;
    otherwise
        % In most cases, we accept whatever the user set.  The other cases
        % at present are 'C4D' and 'Unknown'
end

%% Check the input and output directories

% Input must exist
inputDir   = thisR.get('input dir');
if ~exist(inputDir,'dir'), warning('Could not find %s\n',inputDir); end

% Make working dir if it does not already exist
workingDir = thisR.get('output dir');
if ~exist(workingDir,'dir'), mkdir(workingDir); end

% Make a geometry directory
geometryDir = thisR.get('geometry dir');
if ~exist(geometryDir, 'dir'), mkdir(geometryDir); end

renderDir = thisR.get('rendered dir'); 
if ~exist(renderDir,'dir'), mkdir(renderDir); end

%% Selectively copy data from the input to the output directory.  

piWriteCopy(thisR,overwriteresources,overwritepbrtfile)

%% If the optics type is lens, copy the lens file to a lens sub-directory

if isequal(thisR.get('optics type'),'lens')
    % realisticEye has a lens file slot but it is empty. So we check
    % whether there is a lens file or not.
    if ~isempty(thisR.get('lensfile'))
        piWriteLens(thisR,overwritelensfile);
    end
end

%% Open up the main PBRT scene file.

outFile = thisR.get('output file');
fileID = fopen(outFile,'w');

%% Write header
piWriteHeader(thisR,fileID)

%% Write Scale and LookAt commands first
piWriteLookAtScale(thisR,fileID);

%% Write all other blocks that we have field names for
piWriteBlocks(thisR,fileID);

%% Write out the lights
piLightWrite(thisR);

%{
 renderRecipe = piLightDeleteWorld(thisR, 'all');
 % Check if we removed all lights
 piLightGetFromWorld(thisR)
%}

%% Add 'Include' lines for materials, geometry and lights into the scene PBRT file
piIncludeLines(thisR,fileID, creatematerials,overwritegeometry);

%% Close the main PBRT scene file
fclose(fileID);

%% Write scene_materials.pbrt
piWriteMaterials(thisR,creatematerials,overwritematerials);

%% Overwrite geometry.pbrt
piWriteGeometry(thisR,overwritegeometry,lightsFlag,thistrafficflow)

%% Overwrite xxx.json
if overwritejson
    [~,scene_fname,~] = fileparts(thisR.outputFile);
    jsonFile = fullfile(workingDir,sprintf('%s.json',scene_fname));
    jsonwrite(jsonFile,thisR);
end

end

%% Helper functions

%% Copy the input resources to the output directory

function piWriteCopy(thisR,overwriteresources,overwritepbrtfile)
% Copy files from the input to output dir
%
% In some cases we are looping over many renderings.  In that case we may
% turn off the repeated copies by setting overwriteresources to false.  

inputDir   = thisR.get('input dir');
outputDir = thisR.get('output dir');

% We check for the overwrite here and we make sure there is also an input
% directory to copy from.
if overwriteresources && ~isempty(inputDir)
    
    sources = dir(inputDir);
    status  = true;
    for i=1:length(sources)
        if startsWith(sources(i).name(1),'.')
            % Skip dot-files
            continue;
        elseif sources(i).isdir && (strcmpi(sources(i).name,'spds') || strcmpi(sources(i).name,'textures'))
            % Copy the spds and textures directory files.
            status = status && copyfile(fullfile(sources(i).folder, sources(i).name), fullfile(outputDir,sources(i).name));
        else
            % Selectively copy the files in the scene root folder
            [~, ~, extension] = fileparts(sources(i).name);
            if ~(piContains(extension,'pbrt') || piContains(extension,'zip') || piContains(extension,'json'))
                thisFile = fullfile(sources(i).folder, sources(i).name);
                fprintf('Copying %s\n',thisFile)
                status = status && copyfile(thisFile, fullfile(outputDir,sources(i).name));
            end
        end
    end
    
    if(~status)
        error('Failed to copy input directory to docker working directory.');
    else
        fprintf('Copied resources from:\n');
        fprintf('%s \n',inputDir);
        fprintf('to \n');
        fprintf('%s \n \n',outputDir);
    end
end

%% Potentially overwrite the scene PBRT file

outFile = thisR.get('output file');

% Check if the outFile exists. If it does, decide what to do.
if(exist(outFile,'file'))
    if overwritepbrtfile
        % A pbrt scene file exists.  We delete here and write later.
        fprintf('Overwriting PBRT file %s\n',outFile)
        delete(outFile);
    else
        % Do not overwrite is set, and yet it exists. We don't like this
        % condition, so we throw an error.
        error('PBRT file %s exists.',outFile);
    end 
end

end

%% Put the header into the scene PBRT file

function piWriteHeader(thisR,fileID)
% Write the header
%

fprintf(fileID,'# PBRT file created with piWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
fprintf(fileID,'# PBRT version = %i \n',thisR.version);
fprintf(fileID,'\n');

% If a crop window exists, write out a warning
if(isfield(thisR.film,'cropwindow'))
    fprintf(fileID,'# Warning: Crop window exists! \n');
end

end

%% Write lens information
function piWriteLens(thisR,overwritelensfile)
% Write out the lens file.  Manage cases of overwrite or not
%
% We also manage special human eye model cases Some of these require
% auxiliary files like Index of Refraction files that are specified using
% Include statements in the World block.
%
% See also
%   navarroWrite, navarroLensCreate, setNavarroAccommodation

% Make sure the we have the full path to the input lens file
inputLensFile = thisR.get('lens file');

outputDir      = thisR.get('output dir');
outputLensFile = thisR.get('lens file output');
outputLensDir  = fullfile(outputDir,'lens');
if ~exist(outputLensDir,'dir'), mkdir(outputLensDir); end

if isequal(thisR.get('realistic eye model'),'navarro')
    % Write lens file and the ior files into the output directory.
    navarroWrite(thisR);
elseif isequal(thisR.get('realistic eye model'),'legrand')
    % Write lens file and the ior files into the output directory.
    legrandWrite(thisR);
elseif isequal(thisR.get('realistic eye model'),'arizona')
    % Write lens file into the output directory.
    % Still tracking down why no IOR files are associated with this model.
    arizonaWrite(thisR);
else
    % If the working copy doesn't exist, copy it.  
    % If it exists but there is a force overwrite, delete and copy.
    if ~exist(outputLensFile,'file')
        copyfile(inputLensFile,outputLensFile);
    elseif overwritelensfile
        % It must exist.  So if we are supposed overwrite
        delete(outputLensFile);
        copyfile(inputLensFile,outputLensFile);
    end
end

end

%% LookAt and Scale fields
function piWriteLookAtScale(thisR,fileID)

% Optional Scale
theScale = thisR.get('scale');

if(~isempty(theScale))   
   fprintf(fileID,'Scale %0.2f %0.2f %0.2f \n', [theScale(1) theScale(2) theScale(3)]);
    fprintf(fileID,'\n');
end

% Optional Motion Blur
% default StartTime and EndTime is 0 to 1;
if isfield(thisR.camera,'motion') 
       
    motionTranslate = thisR.get('camera motion translate'); 
    motionStart     = thisR.get('camera motion rotation start'); 
    motionEnd       = thisR.get('camera motion rotation end'); 
    
    fprintf(fileID,'ActiveTransform StartTime \n');
    fprintf(fileID,'Translate 0 0 0 \n');
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,1)); % Z
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,2)); % Y
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,3));  % X
    fprintf(fileID,'ActiveTransform EndTime \n');
    fprintf(fileID,'Translate %0.2f %0.2f %0.2f \n',...
        [motionTranslate(1),...
        motionTranslate(2),...
        motionTranslate(3)]);
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,1)); % Z
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,2)); % Y
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,3));  % X
    fprintf(fileID,'ActiveTransform All \n');
end

% Required LookAt
from = thisR.get('from');
to   = thisR.get('to');
up   = thisR.get('up');
fprintf(fileID,'LookAt %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f \n', ...
    [from(:); to(:); up(:)]);

fprintf(fileID,'\n');

end

%%
function piWriteBlocks(thisR,fileID)
% Loop through the thisR fields, writing them out as required
%
% The blocks that are written out include
%
%  Camera and lens
%

workingDir = thisR.get('output dir');

% These are the main fields in the recipe.  We call them the outer fields.
% Within each outer field, there will be inner fields.
outerFields = fieldnames(thisR);

for ofns = outerFields'
    ofn = ofns{1};
    
    % If empty, we skip this field.
    if(~isfield(thisR.(ofn),'type') || ...
            ~isfield(thisR.(ofn),'subtype'))
        continue;
    end
    
    % Skip, we don't want to write these out here.  So if any one of these,
    % we skip to the next for-loop step
    if(strcmp(ofn,'world') || ...
            strcmp(ofn,'lookAt') || ...
            strcmp(ofn,'inputFile') || ...
            strcmp(ofn,'outputFile')|| ...
            strcmp(ofn,'version')) || ...
            strcmp(ofn,'materials')|| ...
            strcmp(ofn,'world')
        continue;
    end
    
    % Deal with camera and medium
    if strcmp(ofn,'camera') && isfield(thisR.(ofn),'medium') 
       if ~isempty(thisR.(ofn).medium)
           currentMedium = [];
           for j=1:length(thisR.media.list)
                if strcmp(thisR.media.list(j).name,thisR.(ofn).medium)
                    currentMedium = thisR.media.list;
                end
           end           
           fprintf(fileID,'MakeNamedMedium "%s" "string type" "water" "string absFile" "spds/%s_abs.spd" "string vsfFile" "spds/%s_vsf.spd"\n',currentMedium.name,...
               currentMedium.name,currentMedium.name);
           fprintf(fileID,'MediumInterface "" "%s"\n',currentMedium.name);
       end
    end
    
    % Write header that identifies which block this is
    fprintf(fileID,'# %s \n',ofn);
    
    % Write out the main type and subtypes
    fprintf(fileID,'%s "%s" \n',thisR.(ofn).type,...
        thisR.(ofn).subtype);
    
    % Find and then loop through inner field names
    innerFields = fieldnames(thisR.(ofn));
    if(~isempty(innerFields))
        for ifns = innerFields'
            ifn = ifns{1};
            
            % Skip these since we've written these out earlier.
            if(strcmp(ifn,'type') || ...
                    strcmp(ifn,'subtype') || ...
                    strcmp(ifn,'subpixels_h') || ...
                    strcmp(ifn,'subpixels_w') || ...
                    strcmp(ifn,'motion') || ...
                    strcmp(ifn,'subpixels_w') || ...
                    strcmp(ifn,'medium'))
                continue;
            end
            
            %{
             Many fields are written out in here.  
             Some examples are 
             type, subtype, lensfile retinaDistance 
             retinaRadius pupilDiameter retinaSemiDiam ior1 ior2 ior3 ior4
             type subtype pixelsamples type subtype xresolution yresolution
             type subtype maxdepth
            %}
            
            currValue = thisR.(ofn).(ifn).value;
            currType  = thisR.(ofn).(ifn).type;
            
            if(strcmp(currType,'string') || ischar(currValue))
                % We have a string with some value
                lineFormat = '  "%s %s" "%s" \n';
                
                % The currValue might be a full path to a file with an
                % extension. We find the base file name and copy the file
                % to the working directory. Then, we transform the string
                % to be printed in the pbrt scene file to be its new
                % relative path.  There is a minor exception for the lens
                % file. Perhaps we should have a better test here, say an
                % exist() test. (BW).
                [~,name,ext] = fileparts(currValue);

                if(~isempty(ext))
                    % This looks like a file with an extension. If it is a
                    % lens file or an iorX.spd file, indicate that it is in
                    % the lens/ directory. Otherwise, copy the file to the
                    % working directory.
                    
                    fileName = strcat(name,ext);
                    if strcmp(ifn,'specfile') || strcmp(ifn,'lensfile')
                        % It is a lens, so just update the name.  It
                        % was already copied
                        % This should work.
                        % currValue = strcat('lens',[filesep, strcat(name,ext)]);
                        if ispc()
                            currValue = strcat('lens/',strcat(name,ext));
                        else
                            currValue = fullfile('lens',strcat(name,ext));
                        end
                    elseif piContains(ifn,'ior')
                        % The the innerfield name contains the ior string,
                        % then we change it to this
                        currValue = strcat('lens',[filesep, strcat(name,ext)]);
                    else
                        [success,~,id]  = copyfile(currValue,workingDir);
                        if ~success && ~strcmp(id,'MATLAB:COPYFILE:SourceAndDestinationSame')
                            warning('Problem copying %s\n',currValue);
                        end
                        % Update the file for the relative path
                        currValue = fileName;
                    end
                end
                                
            elseif(strcmp(currType,'spectrum') && ~ischar(currValue))
                % A spectrum of type [wave1 wave2 value1 value2]. TODO:
                % There are probably more variations of this...
                lineFormat = '  "%s %s" [%f %f %f %f] \n';
            elseif(strcmp(currType,'rgb'))
                lineFormat = '  "%s %s" [%f %f %f] \n';
            elseif(strcmp(currType,'float'))
                if(length(currValue) > 1)
                    lineFormat = '  "%s %s" [%f %f %f %f] \n';
                else
                    lineFormat = '  "%s %s" [%f] \n';
                end
            elseif(strcmp(currType,'integer'))
                lineFormat = '  "%s %s" [%i] \n';
            end
            
            fprintf(fileID,lineFormat,...
                currType,ifn,currValue);          
        end
    end
    
    % Blank line.
    fprintf(fileID,'\n');
end

end

%%
function piIncludeLines(thisR,fileID, creatematerials,overwritegeometry)
% Insert the 'Include scene_materials.pbrt' and similarly for geometry and
% lights into the main scene file 
%

% We may have created new materials in ISET3d. We insert 'Include' for
% materials, geometry, and lights.
if creatematerials

    for ii = 1:length(thisR.world)
        currLine = thisR.world{ii};
        
        if piContains(currLine, 'materials.pbrt')
            [~,n] = fileparts(thisR.outputFile);
            currLine = sprintf('Include "%s_materials.pbrt"',n);
        end
           
        if overwritegeometry
            % We get here if we generated the geometry file from the
            % recipe.
            if piContains(currLine, 'geometry.pbrt')
                [~,n] = fileparts(thisR.outputFile);
                currLine = sprintf('Include "%s_geometry.pbrt"',n);
            end
        end
        
        if piContains(currLine, 'WorldEnd')
            % We also insert a *_lights.pbrt include because we also write
            % out the lights file.  This file might be empty, but it will
            % also exist.
            [~,n] = fileparts(thisR.outputFile);
            fprintf(fileID, sprintf('Include "%s_lights.pbrt" \n', n));
        end
        fprintf(fileID,'%s \n',currLine);
    end
    
else
    % No materials were created by ISET3d.
    % So we skip the 'Include *_materials.pbrt.  But we still insert the
    % geometry and light Includes
    for ii = 1:length(thisR.world)
        currLine = thisR.world{ii};
        
        if overwritegeometry
            % We get here if we generated the geometry file from the
            % recipe, even though we did not make any changes to the
            % materials.
            if piContains(currLine, 'geometry.pbrt')
                [~,n] = fileparts(thisR.outputFile);
                currLine = sprintf('Include "%s_geometry.pbrt"',n);
            end
        end
        
        if piContains(currLine, 'WorldEnd')
            % We also insert a *_lights.pbrt include because we also write
            % out the lights file.  This file might be empty, but it will
            % also exist.
            [~,n] = fileparts(thisR.outputFile);
            fprintf(fileID, sprintf('Include "%s_lights.pbrt" \n', n));
        end
        fprintf(fileID,'%s \n',currLine);
    end
end
end

%%
function piWriteMaterials(thisR,creatematerials,overwritematerials)
% Write both materials and textures files into the output directory

inDir      = thisR.get('input dir');
outputDir  = thisR.get('output dir');
basename   = thisR.get('input basename');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: below changed
% to include Blender exporter
if piContains(thisR.exporter, 'C4D') || piContains(thisR.exporter, 'Blender')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If the scene is from Cinema 4D, 
    if ~creatematerials
        % We overwrite from the input directory, but we do not create
        % any new material files beyond what is already in the input
        if overwritematerials
            [~,n] = fileparts(thisR.inputFile);
            fname_materials = sprintf('%s_materials.pbrt',n);
            % thisR.materials.outputFile_materials = fullfile(outputDir,fname_materials);
            thisR.set('materials output file',fullfile(outputDir,fname_materials));
            piMaterialWrite(thisR);
        end
    else
        % Create new material files that could come from somewhere
        % other than the input directory.
        [~,n] = fileparts(thisR.outputFile);
        fname_materials = sprintf('%s_materials.pbrt',n);
        thisR.set('materials output file',fullfile(outputDir,fname_materials));

        % thisR.materials.outputFile_materials = fullfile(outputDir,fname_materials);
        piMaterialWrite(thisR);
    end
elseif piContains(thisR.exporter,'Copy')
    % Copy the materials and geometry file
    
    mFileIn  = fullfile(inDir,sprintf('%s_materials.pbrt',basename));
    mFileOut = fullfile(outputDir,sprintf('%s_materials.pbrt',basename));
    if exist(mFileIn,'file')
        copyfile(mFileIn,mFileOut);
    else
        % no materials file to copy
    end
        
else
    % Other case.
    fprintf('Skip the materials\n');
end

end

%%
function piWriteGeometry(thisR,overwritegeometry,lightsFlag,thistrafficflow)
% Write the geometry file into the output dir
%

inDir    = thisR.get('input dir');
outDir   = thisR.get('output dir');
exporter = thisR.get('exporter');
basename = thisR.get('output basename');  % The scene's

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: below changed
% to include Blender exporter
if piContains(exporter, 'C4D') || piContains(exporter, 'Blender')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if overwritegeometry
        piGeometryWrite(thisR,'lightsFlag',lightsFlag, ...
            'thistrafficflow',thistrafficflow);
    end
elseif piContains(exporter,'Copy')
    
    gFileIn  = fullfile(inDir,sprintf('%s_geometry.pbrt',basename));
    gFileOut = fullfile(outDir,sprintf('%s_geometry.pbrt',basename));
    
    if exist(gFileIn,'file')
        copyfile(gFileIn,gFileOut);
    else
        % no geometry file to copy
    end
    
else
    fprintf('Skip the geometry\n');
end

end
