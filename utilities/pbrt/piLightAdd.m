function thisR = piLightAdd(thisR, varargin)
% Add different types of light sources to a scene
%
% Syntax
%       thisR = piLightAdd(thisR, varargin)
%
% Brief description
%   Change the light structs in recipe
%
% Inputs:
%       'thisR' -  Insert a light source in this recipe.
%
% Optional key/value pairs
%
%       'type'  - The type of light source to insert. Can be the following:
%             'point'   - Casts the same amount of illumination in all
%                         directions. Takes parameters 'to' and 'from'.
%             'spot'    - Specify a cone of directions in which light is
%                         emitted. Takes parameters 'to','from',
%                         'coneangle', and 'conedeltaangle.'
%             'distant' - A directional light source "at
%                         infinity". Takes parameters 'to' and 'from'.
%             'area'    - convert an object into an area light. (TL: Needs
%                         more documentation; I'm not sure how it's used at
%                         the moment.)
%             'infinite' - an infinitely far away light source that
%                          potentially casts illumination from all
%                          directions. Takes no parameters.
%
%       'spectrum' - The spectrum that the light will emit. Read
%                          from ISETCam/ISETBio light data. See
%                          "isetbio/isettools/data/lights" or
%                          "isetcam/data/lights."
%       'spectrumscale'  - scale the spectrum. Important for setting
%                          relative weights for multiple light sources.
%       'cameracoordinate' - true or false. automatically place the light
%                            at the camera location.
%       'update'         - update an existing light source.
%
%       For more information in the different light sources and their
%       parameters, take a look at the PBRT web page:
%
%       https://www.pbrt.org/fileformat-v3.html#lights
%
%       Not all the lights and parameters can be represented in ISET3d at
%       the moment, but our hope is that they will be in the future.
%
% Outputs:
%
% Zhenyi, TL, SCIEN, 2019
%
% Required: ISETCam
%
% See also:
%   piSkymapAdd, piLight*
%

% Examples:
%{
  ieInit;
  thisR = piRecipeDefault;
  lightSources = piLightGet(thisR);
  thisR = piLightDelete(thisR, 1);
  thisR = piLightAdd(thisR, 'type', 'point');
  thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);
%}

%% Parse inputs
varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('recipe', @(x)(isa(x,'recipe')));

% update an exist light, zero means to add a new one
p.addParameter('update',0); 
% Directly assign update a light source with one
p.addParameter('newlightsource', [], @isstruct); 

p.parse(thisR, varargin{:});

idxL             = p.Results.update;
newLightSource   = p.Results.newlightsource;

%%
if idxL
    %% Updating the light at index idxL
    
    if ~isempty(newLightSource)
        thisR.lights{idxL} = newLightSource;
    else
        for ii=1:2:numel(varargin)
            if ~strcmp(varargin{ii}, 'update') && ~strcmp(varargin{ii}, 'newlightsource')
                piLightSet(thisR,idxL,varargin{ii},varargin{ii+1});
            end
        end
    end
    
else
    %% Create a new light
    newVarargin = {};
    for ii = 1:2:numel(varargin)
        if ~strcmp(varargin{ii}, 'update') && ~strcmp(varargin{ii}, 'newlightsource')
            newVarargin = [newVarargin, varargin{ii:ii+1}];
        end
    end
    piLightInit(thisR, newVarargin{:});
    thisR.lights = piLightGet(thisR, 'print', false);

end

%% Tell the user the status.  We might turn this off some day.

if idxL, fprintf('Existing lights updated.\n');
else,    fprintf('New light added.\n');
end

end