function val = recipeGet(thisR, param, varargin)
% Derive parameters from the recipe class
%
% Syntax:
%   val = recipeGet(thisR, param, [varargin])
%
% Description:
%    Derive parameters from the recipe class.
%
% Inputs:
%    thisR - Object. A recipe object
%    param - String. A parameter name. Some of the possible options and
%            their types are listed below within their categories.
%   	Data management:
%           inputFile         - String. The full path to original scene
%                               pbrt file.
%           inputBaseName     - String. Just the base name of input file.
%           outputFile        - String. The full path to scene pbrt file in
%                               the current working directory.
%           outputBaseName    - String. Just base name of the output file.
%           workingDirectory  - String. The docker image mounted directory.
%                               Also has alias dockerDirectory.
%       Camera and scene
%           objectDistance    - Numeric. The magnitude ||(from - to)|| of
%                               the difference between from and to. Units
%                               are from the scene, typically in meters. 
%           objectDirection   - Vector. Unit length vector of from and to.
%           lookAt            - Struct. A structure with four components.
%           from              - Matrix. 1x3 matrix of the camera location.
%           to                - Matrix. A 1x3 matrix the camera points at.
%           up                - Matrix. A 1x3 matrix indicating what's 'up'
%           fromTo            - Vector. The vector difference (from - to).
%       Lens & Optics
%           opticsType        - String. The subtype of the camera.
%           lensFile          - String. Name of the lens file in data/lens.
%           focalDistance     - Numeric. See autofocus calculation (mm), as
%                               result will depend on OpticsType.
%           pupilDiameter     - Numeric. The pupil diameter in millimeters.
%           fov               - Numeric. The field of view in degrees. This
%                               is only used if 'optics type' is 'pinhole'.
%           chromAbb          - Boolean. Alias chromaticAbberation. Whether
%                               or not to enable chromatic abberation.
%           numCAbands        - Numeric. The number of chromatic abberation
%                               bands (if CA is enabled).
%       Light field camera
%           nMicrolens        - Matrix. 2-vector, [row, col], with an alias
%                               nPinholes (can also call it by this name).
%                               This is how many microlens are present.
%           nSubPixels        - Matrix. 2 vector, [row, col]. The number of
%                               subpixels behind each microlens/pinhole.
%       Film
%           filmResolution    - Matrix. A 1x2 matrix of the x and y film
%                               resolutions, which can also be requestsed
%                               individually. (Shown below).
%           filmXresolution   - Numeric. The film resolution in X direction
%           filmYresolution   - Numeric. The film resolution in Y direction
%           apertureDiameter  - Numeric. The aperture's diameter.
%           filmDiagonal      - Numeric. Alias diagonal. The measurement of
%                               the scene's diagonal.
%           filmSubtype       - String. A string of the film's subtype.
%           raysPerPixel      - Numeric. Alias pixelSamples. The number of
%                               pixel samples in the scene.
%           cropWindow        - Matrix. A 1x4 matrix - if the field already
%                               exists, use the provided values, otherwise
%                               use [0, 1, 0, 1].
%       Rendering
%           integrator        - String. Returns the integrator subtype.
%           nBounces          - Numeric. Aliases bounces and nBounces. This
%                               is the number of bounces in light.
%
% Outputs:
%    val   - VARIES. The requested parameter's information.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/17  BW   ISETBIO Team, 2017
%    05/08/19  JNM  Documentation pass
%    05/09/19  JNM  Merge with master

% Examples
%{
    val = thisR.get('working directory');
    val = thisR.get('object distance');
    val = thisR.get('focal distance');
    val = thisR.get('camera type');
    val = thisR.get('lens file');
%}

%% Parameters
if isequal(param, 'help')
    doc('recipe.recipeGet');
    return;
end

p = inputParser;
vFunc = @(x)(isequal(class(x), 'recipe'));
p.addRequired('thisR', vFunc);
p.addRequired('param', @ischar);

p.parse(thisR, param, varargin{:});

switch ieParamFormat(param)
    % Data management
    case 'inputfile'
        val = thisR.inputFile;
    case 'outputfile'
        % This file location defines the working directory that docker
        % mounts to run.
        val = thisR.outputFile;
    case {'workingdirectory', 'dockerdirectory'}
        % Docker mounts this directory. Everything is copied into it for
        % the piRender command to run.
        outputFile = thisR.get('output file');
        val = fileparts(outputFile);
    case {'inputbasename'}
        name = thisR.inputFile;
        [~, val] = fileparts(name);
    case {'outputbasename'}
        name = thisR.outputFile;
        [~, val] = fileparts(name);
    % Scene and camera direction
    case 'objectdistance'
        diff = thisR.lookAt.from - thisR.lookAt.to;
        val = sqrt(sum(diff .^ 2));
    case 'objectdirection'
        % A unit vector in the lookAt direction
        val = thisR.lookAt.from - thisR.lookAt.to;
        val = val / norm(val);
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
    case {'cameratype'}
    case {'exposuretime', 'cameraexposure'}
        try
            val = thisR.camera.shutterclose.value - ...
                thisR.camera.shutteropen.value;
        catch
            val = 1;  % 1 sec is the default.  Too long.
        end
    % Lens and optics
    case 'opticstype'
        % perspective means pinhole. Maybe we should rename.
        % realisticDiffraction means lens. Not sure of all the
        % possibilities yet.
        val = thisR.camera.subtype;
        if isequal(val, 'perspective')
            val = 'pinhole';
        elseif isequal(val, 'environment')
            val = 'environment';
        elseif ismember(val, {'realisticDiffraction', 'realisticEye', ...
                'realistic', 'omni'})
            val = 'lens';
        end
    case 'lensfile'
        % See if there is a lens file and assign it.
        subType = thisR.camera.subtype;
        switch(lower(subType))
            case 'pinhole'
                val = 'pinhole';
            case 'perspective'
                val = 'pinhole (perspective)';
            otherwise
                % realisticeye and realisticDiffraction both work here.
                % Need to test 'omni'               
                try
                    [~, val, ~] = fileparts(thisR.camera.lensfile.value);
                catch
                    error('Unknown lens file %s\n', subType);
                end
                
        end
    case 'focaldistance'
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole', 'perspective'}
                disp('Pinhole optics. No focal distance');
                val = NaN;
            case {'environment'}
                disp('Panorama rendering. No focal distance');
                val = NaN;
            case 'lens'
                % Focal distance given the object distance & the lens file
                [p, flname, ~] = fileparts(thisR.camera.lensfile.value);
                focalLength = load(fullfile(p, [flname, '.FL.mat']));  % Mm
                % objDist Units? Where does this come from?
                objDist = thisR.get('object distance');
                % objDist = objDist * 1e3;
                if objDist < min(focalLength.dist(:))
                    fprintf('** Object too close to focus\n');
                    val = []; return;
                elseif objDist > max(focalLength.dist(:))
                    fprintf('** Object too far to focus\n');
                    val = []; return;
                else
                    val = interp1(focalLength.dist, ...
                        focalLength.focalDistance, objDist);
                end
            otherwise
                error('Unknown camera type %s\n', opticsType);
        end
    case 'fov'
        % If pinhole optics, this works. Should check and deal with other
        % cases, I suppose.
        if isequal(thisR.get('optics type'), 'pinhole')
            if isfield(thisR.camera, 'fov')
                val = thisR.camera.fov.value;
            else
                val = atand(thisR.camera.filmdiag.value / 2 / ...
                    thisR.camera.filmdistance.value);
            end
        else
            % Perhaps we could figure out the FOV here for the lens or
            % light field type cameras. Should be possible.
            warning('Not a pinhole camera. Setting fov to 40');
            val = 40;
        end
    case 'pupildiameter'
        % Default is millimeters
        val = 0;  % Pinhole
        if strcmp(thisR.camera.subtype, 'realisticEye')
            val = thisR.camera.pupilDiameter.value;
        end
    case {'chromAbb', 'chromaticaberration'}
        % thisR.get('chromatic aberration')
        % True or false (on or off)
        val = thisR.camera.chromaticAberrationEnabled.value;
        if isequal(val, 'true'), val = true; else, val = false; end
    case 'numcabands'
        % thisR.get('num ca bands')
        try
            val = thisR.integrator.numCABands.value;
        catch
            val = 0;
        end
    % Light field camera parameters
    case {'nmicrolens', 'npinholes'}
        % How many microlens (pinholes)
        val(2) = thisR.camera.num_pinholes_w.value;
        val(1) = thisR.camera.num_pinholes_h.value;
    case 'nsubpixels'
        % How many film pixels behind each microlens/pinhole
        val(2) = thisR.camera.subpixels_w;
        val(1) = thisR.camera.subpixels_h;
    % Film
    case 'filmresolution'
        val = [thisR.film.xresolution.value, thisR.film.yresolution.value];
    case 'filmxresolution'
        val = thisR.film.xresolution.value;    % An integer
    case 'filmyresolution'
        val = [thisR.film.yresolution.value];  % An integer
    case 'aperturediameter'
        switch thisR.version
            case 2
                val = thisR.camera.aperture_diameter.value;
            case 3
                val = thisR.camera.aperturediameter.value;
            otherwise
                error('Unsupported version number! Please use 2 or 3.');
        end
    case {'filmdiagonal', 'diagonal'}
        switch thisR.version
            case 2
                val = thisR.camera.filmdiag.value;
            case 3
                val = thisR.film.diagonal.value;
        end
    case 'filmsubtype'
        % What are the legitimate options?
        val = thisR.film.subtype;
    case {'raysperpixel'}
        val = thisR.sampler.pixelsamples.value;
    case {'cropwindow', 'crop window'}
        if(isfield(thisR.film, 'cropwindow'))
            val = thisR.film.cropwindow.value;
        else
            val = [0 1 0 1];
        end
    % Rendering related
    case{'maxdepth', 'bounces', 'nbounces'}
        val = thisR.integrator.maxdepth.value;
    case{'integrator'}
        val = thisR.integrator.subtype;
    otherwise
        error('Unknown parameter %s\n', param);
end

end
