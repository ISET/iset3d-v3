function val = recipeGet(thisR, param, varargin)
% Derive parameters from the recipe class
%
% Syntax:
%     val = recipeGet(thisR, param, ...)
%
% Inputs:
%     thisR - a recipe object
%     param - a parameter (string)
%
% Returns
%     val - derived parameter
%
% Parameters
%
%   % Data management
%     'input file'      - full path to original scene pbrt file
%     'input base name' - just base name of input file
%     'input dir'       - Directory of the input file
%     'output file'     - full path to scene pbrt file in working directory
%     'output base name' - just the base name of the output file
%     'output dir'       - Directory of the output file
%     'rendered file'    - dat-file where piRender creates the radiance
%     'rendered dir'     - directory with rendered data 
%     'working directory' - directory mounted by docker image
%
%   % Camera and scene
%     'object distance'  - The magnitude ||(from - to)|| of the difference
%                          between from and to.  Units are from the scene,
%                          typically in meters. 
%     'object direction' - Unit length vector of from and to
%     'look at'          - Struct with four components
%        'from'           - Camera location
%        'to'             - Camera points at
%        'up'             - Direction that is 'up'
%        'from to'        - vector difference (from - to)
%     'optics type'      -
%     'lens file'        - Name of lens file in data/lens
%     'focal distance'   - See autofocus calculation (mm)
%     'pupil diameter'   - In millimeters
%     'fov'              - (Field of view) only used if 'optics type' is
%                          'pinhole' 
%     'depth range'      - Depth range of the scene elements given the
%                          camera position
%
%    % Light field camera
%     'n microlens'      - 2-vector, row,col (alias 'n pinholes')
%     'n subpixels'      - 2 vector, row,col
%
%    % Rendering
%      'integrator'
%      'n bounces'
%
%    %  Asset information
%       'assets'      - Not sure I am doing this right
%       'asset names' - The names in groupobjs.name
%
% BW, ISETBIO Team, 2017

% Examples
%{
  val = thisR.get('working directory');
  val = thisR.get('object distance');
  val = thisR.get('focal distance');
  val = thisR.get('camera type');
  val = thisR.get('lens file');
%}

% Programming todo
%

%% Parameters

if isequal(param,'help')
    doc('recipe.recipeGet');
    return;
end

p = inputParser;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar);
% p.addOptional('material', [], @iscell);

p.parse(thisR,param);

val = [];

%%
switch ieParamFormat(param)  % lower case, no spaces
    
    % File management
    case 'inputfile'
        % The place where the PBRT scene files start before being modified
        val = thisR.inputFile;
    case 'inputdir'
        val = fileparts(thisR.get('input file'));
    case {'inputbasename'}
        name = thisR.inputFile;
        [~,val] = fileparts(name);        
    case 'outputfile'
        % This file location defines the working directory that docker
        % mounts to run.
        val = thisR.outputFile;
    case {'outputdir','workingdirectory','dockerdirectory'}
        val = fileparts(thisR.get('output file'));
    case {'outputbasename'}
        name = thisR.outputFile;
        [~,val] = fileparts(name);
    case 'renderedfile'
        % We store the renderings in a 'renderings' directory within the
        % output directory.
        rdir = thisR.get('rendered dir');
        outputFile = thisR.get('output basename');
        val = fullfile(rdir,[outputFile,'.dat']);
    case {'rendereddir'}
        outDir = thisR.get('output dir'); 
        val = fullfile(outDir,'renderings'); 
    case {'renderedbasename'}
        val = thisR.get('output basename');
    case {'inputmaterialsfile','materialsfile'}
        % Stored in the root of the input directory
        n = thisR.get('input basename');
        p = thisR.get('input dir');
        fname_materials = sprintf('%s_materials.pbrt',n);
        val = fullfile(p,fname_materials);
    case {'geometrydir','outputgeometrydir'}
        % Standard location for the scene geometry output information
        outputDir = thisR.get('output dir');
        val = fullfile(outputDir,'scene','PBRT','pbrt-geometry');
    
        % Graphics related
    case {'exporter'}
        % 'C4D' or 'Unknown' or 'Copy' at present.
        val = thisR.exporter;
        
        % Scene and camera direction
    case 'objectdistance'
        % thisR.get('object distance',units)
        diff = thisR.lookAt.from - thisR.lookAt.to;
        val = sqrt(sum(diff.^2));
        % Spatial scale
        if ~isempty(varargin)
            val = val*ieUnitScaleFactor(varargin{1});
        end
        
    case 'objectdirection'
        % A unit vector in the lookAt direction
        val = thisR.lookAt.from - thisR.lookAt.to;
        val = val/norm(val);
        
        % Camera fields
    case {'cameratype'}
        % This is always 'Camera'
        val = thisR.camera.type;
    case {'camerasubtype'}
        % This is the type of Camera, maybe perspective, pinhole,
        % realisticEye, omni, realistic, environment???
        if isfield(thisR.camera,'subtype')
            val = thisR.camera.subtype;
        end
    case 'lookat'
        val = thisR.lookAt;
    case 'from'
        val = thisR.lookAt.from;
    case 'to'
        val = thisR.lookAt.to;
    case 'up'
        val = thisR.lookAt.up;
    case 'fromto'
        % Vector between from minus to
        val = thisR.lookAt.from - thisR.lookAt.to;
    case 'tofrom'
        % Vector between from minus to
        val = thisR.lookAt.to - thisR.lookAt.from;
    case {'scale'}
        % Change the size (scale) of something.  Almost always 1 1 1
        val = thisR.scale;
        
        % Motion is not always included.
    case {'cameramotiontranslate'}
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformStart.pos - thisR.camera.motion.activeTransformEnd.pos;
        end
    case {'cameramotionstart'}
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformStart.rotate;
        end
    case {'cameramotionend'}
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformEnd.rotate;
        end
    case {'exposuretime','cameraexposure'}
        try
            val = thisR.camera.shutterclose.value - thisR.camera.shutteropen.value;
        catch
            val = 1;  % 1 sec is the default.  Too long.
        end
        
        % Lens and optics
    case 'opticstype'
        % val = thisR.get('optics type');
        %
        % perspective means pinhole.
        % not sure I understand environment
        % Others include a lens and so we return the val as 'lens'.
        % Note that for realisticEye we have different types of human eye
        % models.  See realistic eye model to figure out how to get the
        % specific eye model.
        
        val = thisR.camera.subtype;
        if isequal(val,'perspective'), val = 'pinhole';
        elseif isequal(val,'environment'), val = 'environment';
        elseif ismember(val,{'realisticDiffraction','realisticEye','realistic','omni'})
            val = 'lens';
        end
    case 'realisticeyemodel'
        % For the realisticEye we have several models.  Over time we will
        % figure out how to identify them.  We might insert a slot in the
        % recipe with the label when we create the model.

        if isequal(thisR.get('camera subtype'),'realisticEye') && ...
                contains(thisR.get('lensfile'),'navarro')
            val = 'navarro';
        else
            val = [];
        end
        
    case {'lensfile','lensfileinput'}
        % The lens file from the data/lens directory.
        
        % There are a few different camera types.  Not all have lens files.
        subType = thisR.camera.subtype;
        switch(lower(subType))
            case 'pinhole'
                val = 'pinhole';
                % There are no lenses for pinhole/perspective
            case 'perspective'
                % There are no lenses for pinhole/perspective
                val = 'pinhole (perspective)';
            case 'realisticeye'
                % This will be navarro.dat or one of the other models,
                % usually.
                val = thisR.camera.lensfile.value;
            otherwise
                % I think this is used by omni, particularly for microlens
                % cases.  We might do something about putting the microlens
                % examples in the data/lens directory and avoiding this
                % problem.
                
                % Make sure the lensfile is in the data/lens directory.
                [~,name,ext] = fileparts(thisR.camera.lensfile.value);
                baseName = [name,ext];
                val = fullfile(piRootPath,'data','lens',baseName);
                if ~exist(val,'file')
                    val = which(baseName);
                    if isempty(val)
                        error('Can not find the lens file %s\n',val);
                    else
                        fprintf('Using lens file at %s\n',val);
                    end
                end
           
        end
    case {'lensdir','lensdirinput'}
        % This is the directory where the lens files are kept, not the
        % directory unique to this recipe. We copy the lens files from this
        % directory, usually.  There are some complications for navarro and
        % the realisticEye human models.
        val = fullfile(piRootPath,'data','lens');
    case 'lensdiroutput'
        % Directory where we are stsoring the lens file for rendering
        val = fullfile(thisR.get('outputdir'),'lens');
    case 'lensbasename'
        % Just the name, like fisheye
        val = thisR.get('lens file');
        [~,val,~] = fileparts(val);
    case 'lensfullbasename'
        % the name plus the extension fisheye.dat
        val = thisR.get('lens file');
        [~,val,ext] = fileparts(val);
        val = [val,ext];
    case 'lensfileoutput'
        % The full path to the file in the output area where the lens
        % file is kept
        outputDir = thisR.get('outputdir');
        lensfullbasename = thisR.get('lens full basename');
        val = fullfile(outputDir,'lens',lensfullbasename);
        
    case {'focusdistance','focaldistance'}
        % recipe.get('focal distance')  (m)
        %
        % Distance in object space that is in focus on the film. If the
        % camera model has a lens, we check whether the lens can bring this
        % distance into focus on the film plane.
        %
        % N.B.  For pinhole this is focal distance.  
        %       For lens, this   is focus distance.
        %
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole','perspective'}
                % Everything is in focus for a pinhole camera.  For
                % pinholes and perspect this is focaldistance.  But not for
                % realistic or omni.
                val = thisR.camera.focaldistance.value;
            case {'environment'}
                % Everything is in focus for the panorama
                disp('Panorama rendering. No focal distance');
                val = NaN;
            case 'lens'
                % Focal distance given the object distance and the lens file
                val      = thisR.camera.focusdistance.value; % Meters
                
                % If isetlens is on the path, we convert the distance to
                % the focal plane into millimeters and warn if there is no
                % film distance that will bring the object into focus.
                if exist('lensFocus','file')
                    % This will run if isetlens is on the path.  Then the
                    % function lensFocus will be on the path
                    lensFile     = thisR.get('lens file');
                    filmdistance = lensFocus(lensFile,val*1e+3); %mm
                    if filmdistance < 0
                        warning('%s lens cannot focus an object at this distance.', lensFile);
                    end
                end                
            otherwise
                error('Unknown camera type %s\n',opticsType);
        end
    case {'filmdistance'}
        % thisR.get('film distance',unit); % Returned in meters
        %
        % If the camera is a pinhole, we might have a filmdistance.  We
        % don't understand that.
        %
        % When there is a lens, PBRT sets the filmdistance so that an
        % object at the focaldistance is in focus. This is a means of
        % calculating roughly where that will be.  It requires having
        % isetlens on the path, though.
        %
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole','perspective'}
                % Calculate this from the fov, if it is not already stored.
                if isfield(thisR.camera,'filmdistance')
                    val = thisR.camera.filmdistance.value;
                else
                    % Compute the distance to achieve the diagonal fov.  We
                    % might have to make this match the smaller size (x or
                    % y) because of PBRT conventions.  Some day.  For now
                    % we use the diagonal.
                    fov = thisR.get('fov');
                    filmDiag = thisR.get('film diagonal');
                    val = (filmDiag/2)/atan(fov);
                end
            case 'lens'
                if exist('lensFocus','file')
                    opticsType = thisR.get('optics type');
                    if strcmp(opticsType,'lens')
                        lensFile = thisR.get('lens file');
                        if exist('lensFocus','file')
                            % If isetlens is on the path, we convert the
                            % distance to the focal plane into millimeters
                            % and see whether there is a film distance so
                            % that the plane is in focus.
                            % 
                            % But we return the value in meters
                            val = lensFocus(lensFile,1e+3*thisR.get('focal distance'))*1e-3;
                        else
                            % No lensFocus, so tell the user about isetlens
                            warning('Add isetlens to your path if you want the film distance estimate')
                        end
                        if ~isempty(val) && val < 0
                            warning('%s lens cannot focus an object at this distance.', lensFile);
                        end
                    end
                end
            case 'environment'
                % No idea
            case 'realisticeye'
                % 
                warning('Returning retina distance in m')
                val = thisR.get('retina distance','m'); 
                
            otherwise
                error('Unknown opticsType %s\n',opticsType);
        end
        
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = val*ieUnitScaleFactor(varargin{1});
        end

        
    % realisticEye parameters
    case {'retinadistance'}
        % Default storage in mm.  Hence the scale factor on units
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'retinaradius'}
        % Default storage in mm.  Hence the scale factor on units
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'retinasemidiam'}
        % Curved retina parameter.
        % Default storage in mm.  Hence the scale factor on units
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'ior1'}
        % Index of refraction 1
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior2'}
        % Index of refraction 1
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior3'}
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior4'}
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaDistance.value;
        else, error('%s only exists for realisticEye model',param);
        end
            
    % Back to the general case
    case {'fov','fieldofview'}
        % recipe.get('fov') - degrees
        % 
        % We have to deal with fov separately for different types of camera
        % models.
        
        filmDiag      = thisR.get('film diagonal'); 
        switch lower(thisR.get('camera subtype'))
            case {'pinhole','perspective'}
                % For the pinhole the film distance and the field of view always
                % match.  The fov is normally stored which implies a film distance
                % and film size.
                if isfield(thisR.camera,'fov')
                    % The fov was set.
                    val = thisR.camera.fov.value;  % There is an FOV
                    if isfield(thisR.camera,'filmdistance')
                        % A consistency check.  The field of view should make
                        % sense for the film distance.
                        tst = atand(filmDiag/2/thisR.camera.filmdistance.value);
                        assert(abs((val/tst) - 1) < 0.01);
                    end
                else
                    % If there is no FOV, then we have to have a film
                    % distance and size to know the FOV.  This code will break
                    % if we do not have the film distance.
                    val = atand(filmDiag/2/thisR.camera.filmdistance.value);
                end
            case 'realisticeye'
                % When we model the human eye the distance from the lens to
                % the retina is stored in (retinaDistance). So is the size
                % of the film (retinaRadius).
                retinaRadius = thisR.camera.retinaRadius.value;
                retinaDist   = thisR.camera.retinaDistance.value;
                val = atand(retinaRadius/retinaDist)*2;
            otherwise
                % Another lens model (not human)
                %
                % Coarse estimate of the diagonal FOV (degrees) for the
                % lens case. Film diagonal size and distance from the film
                % to the back of the lens.
                if ~exist('lensFocus','file')
                    warning('To calculate FOV you need isetlens on your path');
                    return;
                end
                focusDistance = thisR.get('focus distance');    % meters
                lensFile      = thisR.get('lens file');
                filmDistance  = lensFocus(lensFile,1e+3*focusDistance); % mm
                val           = atand(filmDiag/2/filmDistance);
        end
    case 'depthrange'
        % dRange = thisR.get('depth range');
        % Values in meters
        val = piSceneDepth(thisR);
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = val*ieUnitScaleFactor(varargin{1});
        end
        
    case 'pupildiameter'
        % Default units are millimeters
        switch ieParamFormat(thisR.camera.subtype)
            case 'pinhole'
                val = 0;  
            case 'realisticeye'                
                val = thisR.camera.pupilDiameter.value;
            otherwise
                disp('Need to figure out pupil diameter!!!')
        end
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case 'chromaticaberration'
        % thisR.get('chromatic aberration')
        % True or false (on or off)
        val = thisR.camera.chromaticAberrationEnabled.value;
        if isequal(val,'true'), val = true; else, val = false; end
    case 'numcabands'
        % thisR.get('num ca bands')
        try
            val = thisR.integrator.numCABands.value;
        catch
            val = 0;
        end

        % Light field camera parameters
    case {'nmicrolens','npinholes'}
        % How many microlens (pinholes)
        val(2) = thisR.camera.num_pinholes_w.value;
        val(1) = thisR.camera.num_pinholes_h.value;
    case 'nsubpixels'
        % How many film pixels behind each microlens/pinhole
        val(2) = thisR.camera.subpixels_w;
        val(1) = thisR.camera.subpixels_h;
        
        % Film
    case 'filmresolution'
        try
            val = [thisR.film.xresolution.value,thisR.film.yresolution.value];
        catch
            warning('Film resolution not specified');
            val = [];
        end
        
    case 'filmxresolution'
        % An integer
        val = thisR.film.xresolution.value;
    case 'filmyresolution'
        % An integer
        val = [thisR.film.yresolution.value];
    case 'aperturediameter'
        % Needs to be checked.
        if isfield(thisR.camera, 'aperturediameter') ||...
            isfield(thisR.camera, 'aperture_diameter')
                val = thisR.camera.aperturediameter.value;
        else
            val = nan;
        end
        
    case {'filmdiagonal','filmdiag'}
        % recipe.get('film diagonal');  in mm
        if isfield(thisR.film,'diagonal')
            val = thisR.film.diagonal.value;
        end
  
    case 'filmsubtype'
        % What are the legitimate options?
        if isfield(thisR.film,'subtype')
            val = thisR.film.subtype;
        end
        
    case {'raysperpixel'}
        if isfield(thisR.sampler,'pixelsamples')
            val = thisR.sampler.pixelsamples.value;
        end
        
    case {'cropwindow'}
        if(isfield(thisR.film,'cropwindow'))
            val = thisR.film.cropwindow.value;
        else
            val = [0 1 0 1];
        end
        
        % Rendering related
    case{'maxdepth','bounces','nbounces'}
        % Number of bounces.  If not specified, 1.  Otherwise ...
        val = 1;
        if isfield(thisR.integrator,'maxdepth')
            val = thisR.integrator.maxdepth.value;            
        end
        
    case{'integrator'}
        if isfield(thisR.integrator,'subtype')
            val = thisR.integrator.subtype;
        end
    case {'nwavebands'}
        % Not sure about this.  Initialized this way because expected this
        % way in sceneEye.  Could be updated once we understand.
        val = 0;
        if(isfield(thisR.renderer, 'nWaveBands'))
            val = thisR.renderer.nWaveBands.value;
        end
        
    case{'camerabody'}
        % thisR.get('camera body');
        val.camera = thisR.camera;
        val.film   = thisR.film;
        val.filter = thisR.filter;
        
    case{'materials'}
        if isfield(thisR.materials, 'list')
            val = thisR.materials.list;
        else
            % Should this be just empty, or an empty cell?
            val = {};
        end
    case {'materialsoutputfile'}
        val = thisR.materials.outputfile;
        
    case{'texture'}
        if isfield(thisR.textures, 'list')
            val = thisR.textures.list;
        else
            val = {};
        end
    case{'light'}
        val = thisR.light;
        
    % Assets - more work needed here.
    case {'assetroot'}
        % The root of all assets
        val = thisR.assets;
        
    case {'groupnames'}
        % Cell array (2D) of the groupobj names
        % val{level}{idx}
        val = piAssetNames(thisR);
    case {'groupindex'}
        % thisR.get('groupindex',groupName)
        % gnames = thisR.get('group names')
        %
        % gnames{idx(1)}{dx(2)}
        if isempty(varargin), error('group name required'); end
        val = piAssetNames(thisR,'group find',varargin{1});
    case {'groupobj'}
        % groupobj = thisR.get('groupobj',idx);
        % idx from group index
        %
        % idx = piAssetNames(thisR,'group find','figure_3m');
        thisG = thisR.assets;
        % Work through the levels
        for level = 1:idx(1)
            thisG = thisG.groupobjs;
        end
        % Select the group
        val = thisG(idx(2));
        
    case {'childrennames'}
        % cnames = thisR.get('children names')
        % Cell array (2D) of the children names
        %
        [~,val] = piAssetNames(thisR);
        
    case {'childrenindex'}
        % idx = thisR.get('children index',childName)
        % cnames = thisR.get('children names')
        %
        % These are 3-vectors (level, group, idx)
        %
        % cnames{idx(1)}{dx(2)}
        %
        if isempty(varargin), error('child name required'); end
        val = piAssetNames(thisR,'children find',varargin{1});
    case {'child'}
        % child = thisR.get('child',idx); 
        %
        % idx from child index is a 3 vector. There can be multiple
        % groupobjs at this level and we need to know which one has the
        % specific child.  So we need
        %
        %   [level, groupidx, childidx]
        %
        % idx = piAssetNames(thisR,'children find','3_1_Moon Light');
        thisG = thisR.assets;
        for level = 1:idx(1)
            % Work through the levels
            thisG = thisG.groupobjs;
        end
        % Find the group and child
        val = thisG(idx(2)).children(idx(3));
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end