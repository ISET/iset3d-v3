function thisR = recipeSet(thisR, param, val, varargin)
% Set a recipe value
%
% The recipe has lots of fields, including camera, filter, and so forth. Many
% comments needed here.
%
% Examples
%   thisR.set('lensFile','dgauss.22deg.3.0mm.dat')
%
% BW ISETBIO Team, 2017

%% Set up
if isequal(param,'help')
    doc('recipe.recipeSet');
    return;
end

p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar);
p.addRequired('val');

p.addParameter('lensfile','dgauss.22deg.12.5mm.dat',@(x)(exist(x,'file')));

p.parse(thisR, param, val, varargin{:});

param = ieParamFormat(p.Results.param);

%% Act 
switch param
    
    % Rendering and Docker related
    case {'outputfile'}
        thisR.outputFile = val;

    case {'inputFile'}
        thisR.inputFile = val;   
        % Scene
    case 'objectdistance'
        % Adjust the lookat 'from' field to match the distance in val
        objDirection = thisR.get('object direction');
        
        % Make the unit vector a val distance away and add
        newDirection = objDirection*val;
        thisR.lookAt.from = thisR.lookAt.to + newDirection;
        
        % Camera
    case 'camera'
        % Initialize a camera type with default parameters
        % To adjust the parameters use recipe.set() calls
        thisR.camera = piCameraCreate(val,'lensFile',p.Results.lensfile, ...
            'pbrtVersion',thisR.version);
        
        % If version number is 3, add the film diagonal into the Film
        if(thisR.version == 3)
            thisR.film.diagonal.value = 35;
            thisR.film.diagonal.type = 'float';
        end
        
    case 'cameratype'
        thisR.camera.subtype = val;
    case 'lensfile'
        if(thisR.version == 3)
            thisR.camera.lensfile.value = val;
            thisR.camera.lensfile.type = 'string';
        elseif(thisR.version == 2)
            thisR.camera.specfile.value = val;
            thisR.camera.specfile.type = 'string';
        end
    case 'aperture'
        if(thisR.version == 3)
            thisR.camera.aperturediameter.value = val;
            thisR.camera.aperturediameter.type = 'float';
        elseif(thisR.version == 2)
            thisR.camera.aperture_diameter.value = val;
            thisR.camera.aperture_diameter.type = 'float';
        end
    case {'focaldistance','filmdistance'}
        % What to do here? Focus distance is interpreted differently for
        % version 2 and version 3...
        if(thisR.version == 2)
            thisR.camera.filmdistance.value = val;
            thisR.camera.filmdistance.type = 'float';
        elseif(thisR.version == 3)
            thisR.camera.focusdistance.value = val;
            thisR.camera.focusdistance.type = 'float';
        end
    case 'lookat'
        % Includes the from, to and up in a struct
        if isstruct(val) &&  isfield(val,'from') && isfield(val,'to')
            thisR.lookAt = val; 
        end
    case 'fov'
        % We should check that this is a pinhole, I think
        thisR.camera.fov.value = val;
        thisR.camera.fov.type = 'float';
        
    case 'diffraction'
        if(thisR.version == 2)
            thisR.camera.diffractionEnabled.value = val;
            thisR.camera.diffractionEnabled.type = 'bool';
        elseif(thisR.version == 3)
            warning('diffraction parameter not applicable for version 3')
        end
        
    case 'chromaticaberration'
        if(thisR.version == 2)
            thisR.camera.chromaticAberrationEnabled.value = val;
            thisR.camera.chromaticAberrationEnabled.type = 'bool';
        elseif(thisR.version == 3)
            warning('chromaticaberration parameter not applicable for version 3')
        end
    case 'from'
        thisR.lookAt.from = val;
    case 'to'
        thisR.lookAt.to = val;
    case 'up'
        thisR.lookAt.up = val;
        
    case 'autofocus'
        % thisR.set('autofocus',true);
        % Sets the film distance so the lookAt to point is in good focus
        if val
            fdist = thisR.get('focal distance');
            if isnan(fdist)
                error('Camera is probably too close (%f) to focus.',thisR.get('object distance'));
            end
            thisR.set('focal distance',fdist);
        end
    case 'microlens'
        % Not sure about what this means.  It is on or off
        thisR.camera.microlens_enabled.value = val;
        thisR.camera.microlens_enabled.type = 'float';
    case 'nmicrolens'
        % Number of microlens/pinhole samples for a light field camera
        %
        if length(val) == 1, val(2) = val(1); end
        thisR.camera.num_pinholes_h.value = val(1);
        thisR.camera.num_pinholes_h.type = 'float';
        thisR.camera.num_pinholes_w.value = val(2);
        thisR.camera.num_pinholes_w.type = 'float';
    case 'lightfieldfilmresolution'
        % This is printed out in the pbrt scene file
        nMicrolens = thisR.get('n microlens');
        nSubpixels = thisR.get('n subpixels');
        thisR.set('film resolution', nMicrolens .* nSubpixels);
    case 'nsubpixels'
        % How many pixels behind each microlens/pinhole
        % The type is not included because this is not passed to pbrt.
        thisR.camera.subpixels_h = val(1);
        thisR.camera.subpixels_w = val(2);
        
        % Film
    case 'filmresolution'
        % This is printed out in the pbrt scene file
        if length(val) == 1, val(2) = val(1); end
        thisR.film.xresolution.value = val(1);
        thisR.film.yresolution.value = val(2);
    case {'filmdiagonal','diagonal'}
        if(thisR.version == 2)
            thisR.camera.filmdiag.value = val(1);
            thisR.camera.filmdiag.type = 'float';
        elseif(thisR.version == 3)
            thisR.film.diagonal.value = val(1);
            thisR.film.diagonal.type = 'float';
        end
    case {'pixelsamples','raysperpixel'}
        % Sampler
        thisR.sampler.pixelsamples.value = val;
    case{'cropwindow','crop window'}
        thisR.film.cropwindow.value = [val(1) val(2) val(3) val(4)];
        thisR.film.cropwindow.type = 'float';
    case{'maxdepth','bounces'}
        if(~(strcmp(thisR.integrator.subtype,'directlighting') || ...
                strcmp(thisR.integrator.subtype,'path')))
            error('Integrator type must be directlighting or path for this to be set.');
        end
        thisR.integrator.maxdepth.value = val(1);
        thisR.integrator.maxdepth.type = 'integer';
    otherwise
        error('Unknown parameter %s\n',param);
end
 
