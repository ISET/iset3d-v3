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
        
        % Film
    case 'filmresolution'
        if length(val) == 1, val = [val,val]; end
        thisR.film.xresolution.value = val(1);
        thisR.film.yresolution.value = val(2);
        
        % Sampler
    case {'pixelsamples','raysperpixel'}
        thisR.sampler.pixelsamples.value = val;
        
        
    otherwise 
        error('Unknown parameter %s\n',param);
end
