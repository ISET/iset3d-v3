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
%     val - Stored or derived parameter from the recipe
%
% Parameters
%
%   % Data management
%    % The input files are the original PBRT files
%     'input file'        - full path to original scene pbrt file
%     'input basename'    - just base name of input file
%     'input dir'         - Directory of the input file
%
%    % The output files are the modified PBRT files after modifications to the
%    % parameters in ISET3d
%     'output file'       - full path to scene pbrt file in working directory
%     'output basename'   - base name of the output file
%     'output dir'        - Directory of the output file
%
%    % The rendered files are the output of PBRT, which starts with the
%    % output files
%     'rendered file'     - dat-file where piRender creates the radiance
%     'rendered dir'      - directory with rendered data
%     'rendered basename' - basename of rendered dat-file
%
%    % Scene properties
%     'exporter'  - Where the scene came from
%     'mm units'  - Some scenes were given to us in mm, rathern m, units
%     'depth range'      - Depth range of the scene elements given the
%                          camera position (m)
%
%   % Camera, scene and film
%    % There are several types of cameras: pinhole, realistic,
%    % realisticDiffraction, realisticEye, and omni.  The camera parameters
%    % are stored in the 'camera' and 'film' slots.  There are also some
%    % parameters that define the camera location, what it is pointed at in
%    % the World and motion
%     'camera'           - The whole camera struct
%     'camera type'      - Always 'camera'
%     'camera subtype'   - Valid camera subtypes are {'omni','pinhole', ...}
%     'camera body'
%     'optics type'      - Translates camera sub type into one of
%                          'pinhole', 'envronment', or 'lens'
%     'lens file'        - Name of lens file in data/lens
%     'focal distance'   - See autofocus calculation (mm)
%     'pupil diameter'   - In millimeters
%     'fov'              - (Field of view) Used if 'optics type' is
%                          'pinhole' or 'realisticEye' or ..???
%    % PBRT allows us to specify camera translations.  Here are the
%    % parameters
%     'camera motion start' - Start position in the World
%     'camera motion end'   - End position in the World
%     'camera exposure'     - Time (sec)
%     'camera motion translate' - Difference in position (Start - End)
%
%    % The relationship between the camera and objects in the World are
%    % specified by these parameters
%     'object distance'  - The magnitude ||(from - to)|| of the difference
%                          between from and to.  Units are from the scene,
%                          typically in meters.
%     'object direction' - Unit length vector of from and to
%     'look at'          - Struct with four components
%        'from'           - Camera location
%        'to'             - Camera points at
%        'up'             - Direction that is 'up'
%        'from to'        - vector difference (from - to)
%        'to from'        - vector difference (to - from)
%
%    % Lens
%      'lens file'
%      'lens dir input'
%      'lens dir output'
%      'lens basename'      - No extension
%      'lens full basename' - With extension
%      'focus distance'     - Distance to in-focus plane  (m)
%      'focal distance'     - Used with pinhole, which has infinite depth
%                             of field, to specify the distance from the
%                             pinhole and film
%      'accommodation'      - Inverse of focus distance (diopters)
%      'fov'                - Field of view (deg)
%      'aperture diameter'   - For most cameras, but not human eye
%      'pupil diameter'      - For realisticEye.  Zero for pinhole
%      'diffraction'         - Enabled or not
%      'chromatic aberraton' - Enabled or not
%      'num ca bands'        - Number of chromatic aberration spectral bands
%
%    % Film and retina
%      'film subtype'
%      'film distance'      - PBRT adjusts the film distance so that an
%                             object at the focus distance is in focus.
%                             This is that distance. If a pinhole, it might
%                             just exist as a parameter.  If it doesn't
%                             exist, then we use the film size to and FOV
%                             to figure out what it must be.
%      'spatial samples'    - Sampling resolution
%      'film x resolution'  - Number of x dimension samples
%      'film y resolution'  - Number of y-dimension samples
%      'film diagonarl'     - Size in mm
%
%
%      % Special retinal properties for human eye models
%      'retina distance'
%      'eye radius'
%      'retina semidiam'
%      'center 2 chord'
%      'lens 2 chord'
%      'ior1','ior2','ior3','ior4' - Index of refraction slots for Navarro
%                                    eye model
%
%    % Light field camera parameters
%     'n microlens'      - 2-vector, row,col (alias 'n pinholes')
%     'n subpixels'      - 2 vector, row,col
%
%    % Properties of how PBRT does the rendering
%      'integrator'
%      'rays per pixel'
%      'n bounces'
%      'crop window'
%      'integrator subtype'
%      'nwavebands'
%
%    % Asset information
%       'assets'      - This struct includes the objects and their
%                       properties in the World
%       'asset names' - The names in groupobjs.name
%       'group names'
%       'group index'
%       'group obj'
%       'child'
%       'children names'
%       'children index'
%
%    % Material information
%      'materials'
%      'materials output file'
%
%    % Textures
%      'texture'
%
%    % Lighting information
%      'light'
%
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
%   * Lots of gets needed for the assets, materials, lighting, ...
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
    case 'mmunits'
        % thisR.get('mm units',true/false)
        %
        % Indicates whether the PBRT scene representation is in millimeter
        % units.  Typically, it is not - it is in 'meters'.  The value is
        % stored as a string because PBRT reads it that way.  We might
        % choose to return true/false some day.
        val = 'false';
        if isfield(thisR.camera,'mmUnits')
            % val is true, so we are in millimeter units
            val = thisR.camera.mmUnits.value;
        end
        % Scene and camera direction
    case {'transformtimes'}
        val = thisR.transformTimes;
    case {'transformtimesstart'}
        if isfield(thisR.transformTimes, 'strat')
            val = thisR.transformTimes.start;
        else
            val = [];
        end
    case {'transformtimesend'}
        if isfield(thisR.transformTimes, 'end')
            val = thisR.transformTimes.end;
        else
            val = [];
        end        
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
    case {'camera'}
        % The whole struct
        val = thisR.camera;
    case {'cameratype'}
        % This is always 'Camera'
        val = thisR.camera.type;
    case {'cameramodel','camerasubtype'}
        % thisR.get('camera model')
        % This is Camera model, stored in the subtype slot.
        % It may be perspective, pinhole, realisticEye, omni, realistic,
        % environment.
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
        
        % Motion is not always included.  When it is, there is a start and
        % end position, and a start and end rotation.
    case {'cameramotiontranslate'}
        % This is the difference between start and end
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformStart.pos - thisR.camera.motion.activeTransformEnd.pos;
        end
    case {'cameramotiontranslatestart'}
        % Start position
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformStart.pos ;
        end
    case {'cameramotiontranslateend'}
        % End position
        if isfield(thisR.camera,'motion')
            val =  thisR.camera.motion.activeTransformEnd.pos;
        end
    case {'cameramotionrotationstart'}
        % Start rotation
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformStart.rotate;
        end
    case {'cameramotionrotationend'}
        % End rotation
        if isfield(thisR.camera,'motion')
            val = thisR.camera.motion.activeTransformEnd.rotate;
        end
    case {'exposuretime','cameraexposure'}
        try
            val = thisR.camera.shutterclose.value - thisR.camera.shutteropen.value;
        catch
            val = 1;  % 1 sec is the default.  Too long.
        end
    case {'shutteropen'}
        % thisR.get('shutter open');   % Time in sec
        try
            val = thisR.camera.shutteropen.value;
        catch
            val = 0;
        end
        
    case {'shutterclose'} 
        % thisR.get('shutter close');  % Time in sec
        % When not set, the exposure duration is 1 sec and open,close are
        % [0,1]
        try
            val = thisR.camera.shutterclose.value;
        catch
            val = 1;
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
        elseif isequal(thisR.get('camera subtype'),'realisticEye')  && ...
                contains(thisR.get('lensfile'),'legrand')
            val = 'legrand';
        elseif isequal(thisR.get('camera subtype'),'realisticEye')  && ...
                contains(thisR.get('lensfile'),'arizona')
            val = 'arizona';
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
                        % fprintf('Using lens file at %s\n',val);
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
        %       (in PBRT parlance)
        %
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole','perspective'}
                % Everything is in focus for a pinhole camera.  For
                % pinholes and perspect this is focaldistance.  But not for
                % realistic or omni.
                if isfield(thisR.camera,'focaldistance')
                    val = thisR.camera.focaldistance.value;
                end
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
        
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = val*ieUnitScaleFactor(varargin{1});
        end
        
    case {'accommodation'}
        % thisR.get('accommodation');   % Diopters
        val = 1 / thisR.get('focal distance','m');
        
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
                % The back of the lens to the retina is returned for the
                % realisticEye case
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
        
    case {'eyeradius','retinaradius'}
        % thisR.get('eye radius','m');
        % Default storage in mm.
        %
        % Originally called retina radius, but it really is the
        % radius of the eye ball, not the retina.
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.retinaRadius.value;
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
            val = thisR.camera.retinaSemiDiam.value;
        else, error('%s only exists for realisticEye model',param);
        end
        % Adjust spatial units per user's specification
        if isempty(varargin), return;
        else, val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case 'center2chord'
        % Distance from the center of the eyeball to the chord that defines
        % the field of view.  We know the radius of the eyeball and the
        % size of the chord.
        %
        %  val^2 + semiDiam^2 = radius^2
        %
        % See the PPT about the eyeball geometry, defining the retina
        % radius, distance, and semidiam
        
        eyeRadius = thisR.get('retina radius','mm');
        semiDiam  = thisR.get('retina semidiam','mm');
        if(eyeRadius < semiDiam)
            % The distance to the retina from the back of the lens should
            % always be bigger than the eye ball radius.  Otherwise the
            % lens is on the wrong side of the center of the eye.
            error('semiDiam is larger than eye ball radius. Not good.')
        end
        val = sqrt(eyeRadius^2 - semiDiam^2);
        
    case {'lens2chord','distance2chord'}
        %  Distance from the back of the lens to the chord that defines
        %  the field of view.
        %
        % See the PPT about the eyeball geometry, defining the retina
        % radius, distance, and semidiam
        
        eyeRadius     = thisR.get('retina radius','mm');
        focalDistance = thisR.get('retina distance','mm');
        d = focalDistance - eyeRadius;
        
        a = thisR.get('center 2 chord');
        val = a+d;
        
    case {'ior1'}
        % Index of refraction 1
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.ior1.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior2'}
        % Index of refraction 1
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.ior2.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior3'}
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.ior3.value;
        else, error('%s only exists for realisticEye model',param);
        end
    case {'ior4'}
        if isequal(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.ior4.value;
        else, error('%s only exists for realisticEye model',param);
        end
        
        % Back to the general case
    case {'fov','fieldofview'}
        % recipe.get('fov') - degrees
        %
        if isfield(thisR.camera,'fov')
            val = thisR.camera.fov.value;
            return;
        end
        
        % Try to figure out.  But we have to deal with fov separately for
        % different types of camera models.
        filmDiag = thisR.get('film diagonal');
        if isempty(filmDiag)
            thisR.set('film diagonal',10);
            warning('Set film diagonal to 10 mm, arbitrarily');
        end
        switch lower(thisR.get('camera subtype'))
            case {'pinhole','perspective'}
                % For the pinhole the film distance and the field of view always
                % match.  The fov is normally stored which implies a film distance
                % and film size.
                if isfield(thisR.camera,'fov')
                    % The fov was set.
                    val = thisR.get('fov');  % There is an FOV
                    if isfield(thisR.camera,'filmdistance')
                        % A consistency check.  The field of view should make
                        % sense for the film distance.
                        tst = atand(filmDiag/2/thisR.camera.filmdistance.value);
                        assert(abs((val/tst) - 1) < 0.01);
                    end
                else
                    % There is no FOV. We hneed a film distance and size to
                    % know the FOV.  With no film distance, we are in
                    % trouble.  So, we set an arbitrary distance and tell
                    % the user to fix it.
                    filmDistance = 3*filmDiag;  % Just made that up.
                    thisR.set('film distance',filmDistance);
                    warning('Set film distance  to %f (arbitrarily)',filmDistance);
                    % filmDistance = thisR.set('film distance');
                    val = atand(filmDiag/2/filmDistance);
                end
            case 'realisticeye'
                % thisR.get('fov') - realisticEye case
                %
                % The retinal geometry parameters are retinaDistance,
                % retinaSemidiam and retinaRadius.
                %
                % The field of view depends on the size of a chord placed
                % at the 'back' of the sphere where the image is formed.
                % The length of half of this chord is called the semidiam.
                % The distance from the lens to this chord can be
                % calculated from the
                rd = thisR.get('lens 2 chord','mm');
                rs = thisR.get('retina semidiam','mm');
                val = atand(rs/rd)*2;
            otherwise
                % Another lens model (not human)
                %
                % Coarse estimate of the diagonal FOV (degrees) for the
                % lens case. Film diagonal size and distance from the film
                % to the back of the lens.
                if ~exist('lensFocus','file')
                    warning('To calculate FOV with a lens, you need isetlens on your path');
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
        
    case 'diffraction'
        % thisR.get('diffraction');
        %
        % Status of diffraction during rendering.  Works with realistic eye
        % and omni.  Probably realisticEye, but we should ask TL.  It isn't
        % quite running in the new version, July 11.
        val = 'false';
        if isfield(thisR.camera,'diffractionEnabled')
            val = thisR.camera.diffractionEnabled.value;
        end
        if isequal(val,'true'), val = true; else, val = false; end
        
    case 'chromaticaberration'
        % thisR.get('chromatic aberration')
        % True or false (on or off)
        val = 'false';
        if isfield(thisR.camera,'chromaticAberrationEnabled')
            val = thisR.camera.chromaticAberrationEnabled.value;
        end
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
    case {'spatialsamples','filmresolution','spatialresolution'}
        % thisR.get('spatial samples');
        %
        % When using ISETBio, we usually call it spatial samples or spatial
        % resolution.  For ISETCam, it is usually film resolution.
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
        
    case{'integrator','integratorsubtype'}
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
        
        % Materials.  Still needs work, but exists (BW).
    case {'materials', 'material'}
        % thisR.Get('material',matName,property)
        %
        % thisR = piRecipeDefault('scene name','SimpleScene');
        % materials = thisR.get('materials');
        % thisMat   = thisR.get('material', 'BODY');
        % nameCheck = thisR.get('material', 'uber', 'name');
        % kd     = thisR.get('material', 'uber', 'kd');
        % kdType = thisR.get('material', 'uber', 'kd type');
        % kdVal  = thisR.get('material', 'uber', 'kd value');
        %
        % Get a  property from a material or a material property named in
        % this recipe. 

        if isempty(varargin)
            % Return the whole material list
            if isfield(thisR.materials, 'list')
                val = thisR.materials.list;
            else
                % Should this be just empty, or an empty cell?
                warning('No material in this recipe')
                val = {};
            end
            return;
        end
        
        if ischar(varargin{1})
            varargin{1} = ieParamFormat(varargin{1});
        end
        switch varargin{1}
            % Special cases
            case 'names'
                % thisR.get('material','names');
                n = numel(thisR.materials.list);
                val = cell(1,n);
                for ii=1:n
                    val{ii} = thisR.materials.list{ii}.name;
                end
            otherwise
                % The first argument indicates the material name and there
                % must be a second argument for the property
                if isnumeric(varargin{1}) && ...
                        varargin{1} <= numel(thisR.materials.list)
                    % Search by index.  Get the material directly.
                    matIdx = varargin{1};
                    thisMat = thisR.materials.list{matIdx};
                elseif isstruct(varargin{1})
                    % The user sent in the material.  We hope.
                    % We should have a slot in material that identifies itself as a
                    % material.  Maybe a test like "material.type ismember valid
                    % materials."
                    thisMat = varargin{1};
                elseif ischar(varargin{1})
                    % Search by name, find the index
                    [~, thisMat] = piMaterialFind(thisR.materials.list, 'name', varargin{1});
                    val = thisMat;
                end
                
                if isempty(thisMat)
                    warning('Could not find material. Return.')
                    return;
                end
                if numel(varargin) >= 2
                    % Return the material property
                    % thisR.get('material', material/idx/name, property)
                    % Return the material property
                    val = piMaterialGet(thisMat, varargin{2});
                end
        end                        
        
    case {'nmaterial', 'nmaterials', 'materialnumber', 'materialsnumber'}
        % thisR.get('n materials')
        % Number of materials in this scene.
        if isfield(thisR.materials, 'list')
            val = numel(thisR.materials.list);
        else
            val = 0;
        end        
    case {'materialsprint','printmaterials', 'materialprint', 'printmaterial'}
        % thisR.get('materials print');
        %
        % These are the materials that are named in the tree hierarchy.        
        piMaterialList(thisR);
    case {'materialsoutputfile'}
        % Unclear why this is still here.  Probably deprecated.
        val = thisR.materials.outputfile;
    case {'objectmaterial','materialobject'}
        % val = thisR.get('object material');
        %
        % Cell arrays of object names and corresponding material
        % names.
        %
        % We do not use findleaves because sometimes tree class
        % thinks what we call is a branch is a leaf because,
        % well, we don't put an object below a branch node.  We
        % should trim the tree of useless branches (any branch
        % that has no object beneath it). Maybe.  (BW).
        ids = thisR.get('objects');
        leafMaterial = cell(1,numel(ids));
        leafNames = cell(1,numel(ids));
        cnt = 1;
        for ii=ids
            thisAsset = thisR.get('asset',ii);
            leafNames{cnt} = thisAsset.name;
            leafMaterial{cnt} = piAssetGet(thisAsset,'material name');
            cnt = cnt + 1;
        end
        val.leafNames = leafNames;
        val.leafMaterial = leafMaterial;
    case {'objects'}
        % Indices to the objects
        nnodes = thisR.assets.nnodes;
        val = [];
        for ii=1:nnodes
            thisNode = thisR.assets.Node{ii};
            if isfield(thisNode,'type') && isequal(thisNode.type,'object')
                val = [val,ii]; %#ok<AGROW>
            end
        end
    case {'objectnames'}
        % Names of the objects
        ids = thisR.get('objects');
        names = thisR.assets.names;
        val = cell(1,numel(ids));
        for ii = 1:numel(ids)
            val{ii} = names{ids(ii)};
        end
        
        % Getting ready for textures
    case{'texture'}
        if isfield(thisR.textures, 'list')
            val = thisR.textures.list;
        else
            val = {};
        end
        
        % Getting read for lights
    case{'light', 'lights'}
        if isempty(varargin)
            if isprop(thisR, 'lights')
                val = thisR.lights;
            else
                warning('No lights in this recipe')
                val = {};
            end
            return;
        end

        if ischar(varargin{1})
            varargin{1} = ieParamFormat(varargin{1});
        end
        
        switch varargin{1}
            case 'names'
                n = numel(thisR.lights.list);
                val = cell(1, n);
                for ii=1:n
                    val{ii} = thisR.lights.list{ii}.name;
                end
            otherwise
                % The first argument indicates the material name and there
                % must be a second argument for the property
                if isnumeric(varargin{1}) && ...
                        varargin{1} <= numel(thisR.lights)
                    % Search by index.  Get the material directly.
                    lgtIdx = varargin{1};
                    thisLight = thisR.lights{lgtIdx};
                    val = thisLight;
                elseif isstruct(varargin{1})
                    % The user sent in the material.  We hope.
                    % We should have a slot in material that identifies itself as a
                    % material.  Maybe a test like "material.type ismember valid
                    % materials."
                    thisLight = varargin{1};
                elseif ischar(varargin{1})
                    % Search by name, find the index
                    [~, thisLight] = piLightFind(thisR.lights, 'name', varargin{1});
                    val = thisLight;
                end
                
                if isempty(thisLight)
                    warning('Could not find material. Return.')
                    return;
                end
                if numel(varargin) >= 2
                    % Return the material property
                    % thisR.get('material', material/idx/name, property)
                    % Return the material property
                    val = piLightGet(thisLight, varargin{2});
                end
        end
    case {'nlight', 'nlights', 'light number', 'lights number'}
        % thisR.get('n lights')
        % Number of lights in this scene.
        if isprop(thisR, 'lights')
            val = numel(thisR.lights);
        else
            val = 0;
        end                    
    case {'lightsprint', 'printlights', 'lightprint', 'printlight'}
        % thisR.get('lights print');
        piLightList(thisR);
    % Asset specific gets - more work needed here.
    case {'asset', 'assets'}
        % thisR.get('asset',assetName or ID);  % Returns the asset
        % thisR.get('asset',assetName,param);  % Returns the param val
        
        [id,thisAsset] = piAssetFind(thisR.assets,'name',varargin{1});
        if isempty(id), error('Could not find asset %s\n',varargin{1}); end
        if length(varargin) == 1
            val = thisAsset;
            return;
        else 
            if strncmp(varargin{2},'material',8)
                [~,material] = piMaterialFind(thisR.materials.list,...
                    'name',thisAsset.material.namedmaterial);
            end
            switch ieParamFormat(varargin{2})
                case 'id'
                    val = id;
                case 'subtree'
                    % thisR.get('asset', assetName, 'subtree');
                    val = thisR.assets.subtree(id);
                case {'nodetoroot','pathtoroot'}
                    % thisR.get('asset',assetName,'leaf to root');
                    % Sequence of ids from the leaf to root
                    % We should check that id is a leaf??? (BW)
                    val = thisR.assets.nodetoroot(id);
                    
                    % Get material properties from this asset
                case 'material'
                    % thisR.get('asset',assetName,'material');
                    val = material;
                case 'materialname'
                    val = material.name;
                case 'materialtype'
                    val = material.type;
                    % Leafs (objects) in the tree.
                
                    % World position and orientation properties.
                case 'worldrotationmatrix'
                    %{
                    % Should allow branch node as well.
                    if ~thisR.assets.isleaf(id)
                        warning('Only leaves have rotations')
                    else
                    %}
                    % Deleted a lot of code comments from here 12/24 (BW).
                    nodeToRoot = thisR.assets.nodetoroot(id);
                    [val, ~] = piTransformWorld2Obj(thisR, nodeToRoot);
                    %{
                    % Can we delete?
                    rotY = -atan2d(curXYZ(3, 1), curXYZ(1, 1)); % az
                    rotZ = atan2d(curXYZ(2, 1), sqrt(curXYZ(1, 1)^2+curXYZ(3, 1)^2)); % el
                    rotX = -atan2d(curXYZ(2, 3), sqrt(curXYZ(1, 3)^2 + curXYZ(3, 3)^2)); % az
                    a = 1;
                    %}
                case 'worldrotationangle'
                    rotM = thisR.get('asset', id, 'world rotation matrix');
                    val = piTransformRotM2Degs(rotM);
                case {'worldtranslation', 'worldtranslationmatrix'}
                    %{
                    % Should allow branch node as well.
                    if ~thisR.assets.isleaf(id)
                        warning('Only leaves have positions')
                    else
                    %}
                        % Deleted a lot of code comments from here 12/24 (BW).
                        nodeToRoot = thisR.assets.nodetoroot(id);                        
                        [~, val] = piTransformWorld2Obj(thisR, nodeToRoot);
                    
                case 'worldposition'
                    % thisR.get('asset',idOrName,'world position')
                    val = thisR.get('asset', id, 'world translation');
                    val = val(1:3, 4)';
                case 'translation'
                    % Translation is always in the branch, not in the
                    % leaf.
                    if thisR.assets.isleaf(id)
                        parentID = thisR.get('asset parent id', id);
                        val = thisR.get('asset', parentID, 'translation');
                    else
                        val = piAssetGet(thisAsset, 'translation');
                    end
                otherwise                    
                    val = piAssetGet(thisAsset,varargin{2});
            end
        end
    case {'assetid'}
        % thisR.get('asset id',assetName);  % ID from name
        val = piAssetFind(thisR.assets,'name',varargin{1});
    case {'assetroot'}
        % The root of all assets just has a name, not properties.
        val = thisR.assets.get(1);
    case {'assetnames'}
        % The names without the XXXID_ prepended
        val = thisR.assets.stripID;
    case {'assetparentid'}
        % thisR.get('asset parent id',assetName or ID);
        %
        % Returns the id of the parent node
        thisNode = varargin{1};
        if isstruct(thisNode)
            thisNodeID = piAssetFind(thisR.assets,'name',thisNode.name);
        elseif ischar(thisNode)
            % It is a name, get the ID
            thisNodeID = piAssetFind(thisR.assets,'name',thisNode);
        elseif isnumeric(thisNode)
            thisNodeID = thisNode;
        end
        val = thisR.assets.getparent(thisNodeID);
    case {'assetparent'}
        % thisR.get('asset parent',assetName)
        %
        thisNode = varargin{1};
        parentNode = thisR.get('asset parent id',thisNode);
        val = thisR.assets.Node{parentNode};   

        % Delete this stuff when we get ready to merge.
        %{
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
        %}

    otherwise
        error('Unknown parameter %s\n',param);
end

end