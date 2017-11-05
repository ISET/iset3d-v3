function thisR = recipeSet(thisR, param, val, varargin)
% Set a recipe value
%
% The recipe has lots of fields, including camera, filter, and so forth. Many
% comments needed here.
% 
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

p.parse(thisR, param, val, varargin{:});

param = ieParamFormat(p.Results.param);

%% Act
switch param
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
        thisR.camera = piCameraCreate(val);
    case 'aperture'
        thisR.camera.aperture_diameter.value = val;
    case 'focaldistance'
        thisR.camera.filmdistance.value = val;
    case 'autofocus'
        % thisR.set('autofocus',true);
        % Sets the film distance so the lookAt to point is in good focus
        if val
            thisR.set('focal distance',thisR.get('focal distance'));
        end
    case 'microlens'
        % Not sure about what this means.  It is on or off
        thisR.camera.microlens_enabled.value = val;
    case 'nmicrolens'
        % Number of microlens/pinhole samples for a light field camera
        % 
        if length(val) == 1, val(2) = val(1); end
        thisR.camera.num_pinholes_h.value = val(1);
        thisR.camera.num_pinholes_w.value = val(2);
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
        
        % Sampler
    case {'pixelsamples','raysperpixel'}
        thisR.sampler.pixelsamples.value = val;
        
        
    otherwise 
        error('Unknown parameter %s\n',param);
end
