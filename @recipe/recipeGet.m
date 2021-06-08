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
%    % Data management
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
%     'lookat direction' - Unit length vector of from and to
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
%       'asset names' 
%       'asset id'
%       'asset root'
%       'asset names'
%       'asset parent id'
%       'assetparent'
%       'asset list'  - a list of branches.
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
  thisR = piRecipeDefault('scene name','SimpleScene');
  thisR.get('working directory')
  thisR.get('object distance')
  thisR.get('focal distance')
  thisR.get('camera type')
  thisR.get('lens file')

  thisR.get('asset names')       % The call should be the same!
  thisR.get('materials','names');
  thisR.get('textures','names')  
  thisR.get('light','names')      

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
        
    case {'lookatdirection','objectdirection'}
        % A unit vector in the lookAt direction
        % At some point we called this the object direction to indicate
        % that we are looking at an object in this direction.  Though the
        % reality is we may just be looking at the sky - no object.
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
        
        % Trying to change from perspective to pinhole (BW)
        if isequal(val,'perspective'), val = 'pinhole'; end
        
    case 'lookat'
        val = thisR.lookAt;
    case {'from','cameraposition'}
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
        % The returns are pinhole, lens, or environment
        %
        % perspective means pinhole.  I am trying to get rid of perspective
        % as a subtype (BW).
        %
        % realisticEye is a lens type used for human eye models.  You must
        % check the camera subtype to determine when lens model is omni or
        % realisticEye
        %
        val = thisR.camera.subtype;
        
        % Translate
        if     isequal(val,'perspective'), val = 'pinhole';
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
            case {'pinhole'}
                % Everything is in focus for a pinhole camera.  For
                % pinholes this is focaldistance.  But not for omni.
                disp('No true focal distance for pinhole. This value is arbitrary');
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
        % For the realisticEye, this is retina distance in mm.
        %
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole'}
                % Calculate this from the fov, if it is not already stored.
                if isfield(thisR.camera,'filmdistance')
                    % Worried about the units.  mm or m?  Assuming meters.
                    val = thisR.camera.filmdistance.value;
                else
                    % Compute the distance to achieve the diagonal fov.  We
                    % might have to make this match the smaller size (x or
                    % y) because of PBRT conventions.  Some day.  For now
                    % we use the diagonal.
                    fov = thisR.get('fov');  % Degrees
                    filmDiag = thisR.get('film diagonal','m');  % m
                    
                    %   tand(fov) = opp/adj; adjacent is distance
                    val = (filmDiag/2)/tand(fov);               % m
                    
                end
                
            case 'lens'
                % We separate out the omni and human realisticEye models
                if strcmp(thisR.get('camera subtype'),'realisticEye')
                    % For the human eye model we store the distance to the
                    % retina in millimeters.
                    warning('Returning retina distance in m')
                    val = thisR.get('retina distance','m');
                else
                    % We calculate the focal length from the lens file
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
            case 'environment'
                % No idea
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
        
        % Film (because of PBRT.  ISETCam it would be sensor).
    case {'spatialsamples','filmresolution','spatialresolution'}
        % thisR.get('spatial samples');
        %
        % When using ISETBio, we usually call it spatial samples or spatial
        % resolution.  For ISET3d, it is usually film resolution because of
        % the PBRT notation.
        % 
        % We also have some matters to consider for light field cameras.
        try
            val = [thisR.film.xresolution.value,thisR.film.yresolution.value];
        catch
            warning('Film resolution not specified');
            val = [];
        end
        %{
        % For a lightfield camera, if film resolution is not defined, we
          could do this. This would be an omni camera that has microlenses.
          
          nMicrolens = thisR.get('n microlens');
          nSubpixels = thisR.get('n subpixels');
          thisR.set('film resolution', nMicrolens .* nSubpixels);
        %}
        
    case 'filmxresolution'
        % An integer specifying number of samples
        val = thisR.film.xresolution.value;
    case 'filmyresolution'
        % An integer specifying number of samples
        val = [thisR.film.yresolution.value];
        
    case 'aperturediameter'
        % Needs to be checked.  Default units are meters or millimeters?
        if isfield(thisR.camera, 'aperturediameter') ||...
                isfield(thisR.camera, 'aperture_diameter')
            val = thisR.camera.aperturediameter.value;
        else
            val = NaN;
        end
        
        % Need to check on the units!
        if isempty(varargin), return;
        else, val = val*ieUnitScaleFactor(varargin{1});
        end
        
    case {'filmdiagonal','filmdiag'}
        % recipe.get('film diagonal');  in mm
        if isfield(thisR.film,'diagonal')
            val = thisR.film.diagonal.value;
        else
            % warning('Setting film diagonal to 10 mm. Previously unspecified');
            thisR.set('film diagonal',10);
            val = 10;
        end
        
        % By default the film is stored in mm, unfortunately.  So we scale
        % to meters and then apply unit scale factor
        if isempty(varargin), return;
        else, val = val*1e-3*ieUnitScaleFactor(varargin{1});
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
        
        % Here we list the material names or find a material by its name.
        % If there is a material name (varargin{1}) and then a material
        % property (varargin{2}) we call piMaterialGet.  See piMaterialGet
        % for the list of material properties you can get.
        switch varargin{1}
            % Special cases
            case 'names'
                % thisR.get('material','names');
                val = keys(thisR.materials.list);
            otherwise
                % The first argument indicates the material name and there
                % must be a second argument for the property
                if isstruct(varargin{1})
                    % The user sent in the material.  We hope.
                    % We should have a slot in material that identifies itself as a
                    % material.  Maybe a test like "material.type ismember valid
                    % materials."
                    thisMat = varargin{1};
                elseif ischar(varargin{1})
                    % Search by name, find the index
                    thisMat = thisR.materials.list(varargin{1});
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
        val = thisR.materials.list.Count;
    case {'materialsprint','printmaterials', 'materialprint', 'printmaterial'}
        % thisR.get('materials print');
        %
        % These are the materials that are named in the tree hierarchy.        
        piMaterialPrint(thisR);
    case {'materialsoutputfile'}
        % Unclear why this is still here.  Probably deprecated.
        val = thisR.materials.outputfile;
        
        % Getting ready for textures
    case{'texture', 'textures'}
        % thisR.get('texture', textureName, property)
        
        % thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');
        % textures = thisR.get('texture');
        % thisTexture = thisR.get('texture', 'reflectanceChart_color');
        % thisName = thisR.get('texture', 'reflectanceChart_color', 'name');
        % filename = thisR.get('texture', 'reflectanceChart_color', 'filename');
        % filenameVal = thisR.get('texture', 'reflectanceChart_color', 'filename val');
        
        if isempty(varargin)
            % Return the whole texture list
            if isfield(thisR.textures, 'list')
                val = thisR.textures.list;
            else
                % Should this be just empty, or an empty cell?
                warning('No material in this recipe')
                val = {};
            end
            return;        
        end
        
        switch varargin{1}
            % Special cases
            case 'names'
                % thisR.get('texture', 'names');
                val = keys(thisR.textures.list);
            otherwise
                % The first argument indicates the texture name and there
                % must be a second argument for the property
                if isstruct(varargin{1})
                    thisTexture = varargin{1};
                elseif ischar(varargin{1})
                    % Search by name, find the index
                    [~, thisTexture] = piTextureFind(thisR.textures.list, 'name', varargin{1});
                    val = thisTexture;
                end
                
                if isempty(thisTexture)
                    warning('Could not find material. Return.')
                    return;
                end
                if numel(varargin) >= 2
                    % Return the texture property
                    % thisR.get('texture', texture/idx/name, property)
                    % Return the texture property
                    val = piTextureGet(thisTexture, varargin{2});
                end                
        end
        
    case {'ntexture', 'ntextures', 'texturenumber', 'texturesnumber'}
        % thisR.get('n textures')
        % Number of textures in this scene
        if isfield(thisR.textures, 'list')
            val = thisR.textures.list.Count;
        else
            val = 0;
        end
    case {'texturesprint', 'printmtextures', 'textureprint', 'printtexture'}
        % thisR.get('textures print')
        %
        piTexturePrint(thisR);
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
    case {'objectcoords','objectcoordinates'}
        % Returns the coordinates of the objects (leafs of the asset tree)
        % Units should be meters
        % coords = thisR.get('object coordinates');
        %
        Objects  = thisR.get('objects');
        nObjects = numel(Objects);
        
        % Get their world positions
        val = zeros(nObjects,3);
        for ii=1:nObjects
            thisNode = thisR.get('assets',Objects(ii));
            val(ii,:) = thisR.get('assets',thisNode.name,'world position');
        end
        
        % Lights
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
        
        %{
        if ischar(varargin{1})
            varargin{1} = ieParamFormat(varargin{1});
        end
        %}
        
        switch varargin{1}
            case 'names'
                n = numel(thisR.lights);
                val = cell(1, n);
                for ii=1:n
                    val{ii} = thisR.lights{ii}.name;
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
                    warning('Could not find light. Return.')
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
        % If only one asset matches, turn it from cell to struct.
        if numel(thisAsset) == 1
            thisAsset = thisAsset{1};
        end
        if isempty(id), error('Could not find asset %s\n',varargin{1}); end
        if length(varargin) == 1
            val = thisAsset;
            return;
        else 
            if strncmp(varargin{2},'material',8)
                material = thisR.materials.list(thisAsset.material.namedmaterial);
            end
            switch ieParamFormat(varargin{2})
                case 'id'
                    val = id;
                case 'subtree'
                    % thisR.get('asset', assetName, 'subtree', ['replace', false]);
                    % The id is retrieved above.
                    val = thisR.assets.subtree(id);

                    % The current IDs only make sense as part of the whole
                    % tree.  So we strip them and replace the names in the
                    % current structure.
                    if numel(varargin) >= 4
                        replace = varargin{4};
                    else
                        replace = true;
                    end
                    [~, val] = val.stripID([],replace);

                case {'nodetoroot','pathtoroot'}
                    % thisR.get('asset',assetName,'node to root');
                    %
                    % Returns the sequence of ids from this node id to
                    % root of the tree.
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
                
                    % World position and orientation properties.  These
                    % need more explanation.
                case 'worldrotationmatrix'
                    nodeToRoot = thisR.assets.nodetoroot(id);
                    [val, ~] = piTransformWorld2Obj(thisR, nodeToRoot);
                case 'worldrotationangle'
                    rotM = thisR.get('asset', id, 'world rotation matrix');
                    val = piTransformRotM2Degs(rotM);
                case {'worldtranslation', 'worldtranslationmatrix'}
                    nodeToRoot = thisR.assets.nodetoroot(id);
                    [~, val] = piTransformWorld2Obj(thisR, nodeToRoot);
                case 'worldposition'
                    % thisR.get('asset',idOrName,'world position')
                    val = thisR.get('asset', id, 'world translation');
                    val = val(1:3, 4)';
                    
                    % These are local values, not world
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
    case {'assetlist'}
        assetNames = thisR.get('asset names');
        nn = 1;
        for ii = 1:numel(assetNames)
            % we have several branch here, we only need the main branch
            % which contains size information
            if piContains(assetNames{ii},'_B') && ...
                    ~piContains(assetNames{ii},'_T') && ...
                    ~piContains(assetNames{ii},'_S') && ...
                    ~piContains(assetNames{ii},'_R')
                
                val{nn} = thisR.get('assets',assetNames{ii});
                nn=nn+1;
            end
        end
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end