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
%     'output file'     - full path to scene pbrt file in working directory
%     'output base name' - just the base name of the output file
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
%
%    % Light field camera
%     'n microlens'      - 2-vector, row,col (alias 'n pinholes')
%     'n subpixels'      - 2 vector, row,col
%
%    % Rendering
%      'integrator'
%      'n bounces'
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

p.parse(thisR,param,varargin{:});

switch ieParamFormat(param)
    
    % Data management
    case 'inputfile'
        val = thisR.inputFile;
    case 'outputfile'
        % This file location defines the working directory that docker
        % mounts to run.
        val = thisR.outputFile;
    case {'workingdirectory','dockerdirectory'}
        % Docker mounts this directory.  Everything is copied into it for
        % the piRender command to run.
        outputFile = thisR.get('output file');
        val = fileparts(outputFile);
    case {'inputbasename'}
        name = thisR.inputFile;
        [~,val] = fileparts(name);
    case {'outputbasename'}
        name = thisR.outputFile;
        [~,val] = fileparts(name);
        
        % Scene and camera direction
    case 'objectdistance'
        diff = thisR.lookAt.from - thisR.lookAt.to;
        val = sqrt(sum(diff.^2));
    case 'objectdirection'
        % A unit vector in the lookAt direction
        val = thisR.lookAt.from - thisR.lookAt.to;
        val = val/norm(val);
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
        
        % Lens and optics
    case 'opticstype'
        % perspective means pinhole.  Maybe we should rename.
        % realisticDiffraction means lens.  Not sure of all the possibilities
        % yet.
        val = thisR.camera.subtype;
        if isequal(val,'perspective'), val = 'pinhole';
        elseif isequal(val,'environment'), val = 'environment';
        elseif ismember(val,{'realisticDiffraction','realisticEye','realistic','omni'})
            val = 'lens';
        end
    case 'lensfile'
        % See if there is a lens file and assign it.
        subType = thisR.camera.subtype;
        switch(lower(subType))
            case 'pinhole'
                val = 'pinhole (no lens)';
            otherwise
                % realisticeye and realisticDiffraction both work here.
                % Not sure what else is out there.
                if thisR.version==2
                    try
                        [~,val,~] = fileparts(thisR.camera.specfile.value);
                    catch
                        error('Unknown lens file %s\n',subType);
                    end
                elseif thisR.version == 3
                    try
                        [~,val,~] = fileparts(thisR.camera.lensfile.value);
                    catch
                        error('Unknown lens file %s\n',subType);
                    end
                end
        end
    case 'focaldistance'
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole','perspective'}
                disp('Pinhole optics.  No focal distance');
                val = NaN;
            case {'environment'}
                disp('Panorama rendering. No focal distance');
                val = NaN;
            case 'lens'
                % Focal distance given the object distance and the lens file
                [p,flname,~] = fileparts(thisR.camera.lensfile.value);
                focalLength = load(fullfile(p,[flname,'.FL.mat']));  % Millimeters
                objDist = thisR.get('object distance');   % Units?  Where does this come from?
                % objDist = objDist*1e3;
                if objDist < min(focalLength.dist(:))
                    fprintf('Object too close to focus\n');
                elseif objDist > max(focalLength.dist(:))
                    fprintf('Object too far to focus\n');
                else
                    val = interp1(focalLength.dist,focalLength.focalDistance,objDist);
                end
            otherwise
                error('Unknown camera type %s\n',opticsType);
        end
    case 'fov'
        % If pinhole optics, this works.  Should check and deal with other
        % cases, I suppose.
        if isequal(thisR.get('optics type'),'pinhole')
            
            if isfield(thisR.camera,'fov')
                val = thisR.camera.fov.value;
            else
                val = atand(thisR.camera.filmdiag.value/2/thisR.camera.filmdistance.value);
            end
        else
            % Perhaps we could figure out the FOV here for the lens or
            % light field type cameras.  Should be possible.
            warning('Not a pinhole camera.  Setting fov to 40');
            val = 40;
        end
    case 'pupildiameter'
        % Default is millimeters
        val = 0;  % Pinhole
        if strcmp(thisR.camera.subtype,'realisticEye')
            val = thisR.camera.pupilDiameter.value;
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
        val = [thisR.film.xresolution.value,thisR.film.yresolution.value];
    case 'filmxresolution'
        % An integer
        val = thisR.film.xresolution.value;
    case 'filmyresolution'
        % An integer
        val = [thisR.film.yresolution.value];
    case 'aperturediameter'
        switch thisR.version
            case 2
                val = thisR.camera.aperture_diameter.value;
            case 3
                val = thisR.camera.aperturediameter.value;
        end
        
    case {'filmdiagonal','diagonal'}
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
        
    case {'cropwindow','crop window'}
        if(isfield(thisR.film,'cropwindow'))
            val = thisR.film.cropwindow.value;
        else
            val = [0 1 0 1];
        end
        
        % Rendering related
    case{'maxdepth','bounces','nbounces'}
        val = thisR.integrator.maxdepth.value;
        
    case{'integrator'}
        val = thisR.integrator.subtype;
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end