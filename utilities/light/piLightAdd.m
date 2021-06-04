function thisR = piLightAdd(thisR, varargin)
% Deprecated
%
% Add different types of light sources to a scene
%
% Syntax
%       thisR = piLightAdd(thisR, varargin)
%
% Brief description
%   Change the light structs in recipe
%
% Inputs:
%       'thisR' -  Insert a light source into this recipe.
%
% Optional key/value pairs
%
%  Many key/value pairs to define the light are acceptable in the varargin.
%  This routine calls piLightCreate with the variables in varargin, and that
%  function in turn calls  piLightSet to set all the key/value pairs here.
%
%  The list of settable light parameters is determined by the light
%  parameters in PBRT. Those parameters are defined on this web-page in the
%  PBRT web site.
%
%      https://www.pbrt.org/fileformat-v3.html#lights
%
%  Some of the most important variables are listed here for convenience.
%  See some of the examples in piLightSet, also.
%
%    'type'  - The type of light source to insert. Can be the following:
%          'point'   - Casts the same amount of illumination in all
%                         directions. Takes parameters 'to' and 'from'.
%          'spot'    - Specify a cone of directions in which light is
%                         emitted. Takes parameters 'to','from',
%                         'coneangle', and 'conedeltaangle.'
%          'distant' - A directional light source "at
%                         infinity". Takes parameters 'to' and 'from'.
%          'area'    - convert an object into an area light. These can be
%                      specified only for triangle, sphere, cylinder, and
%                      disk shapes, but they must have a shape.
%          'infinite' - an infinitely far away light source that
%                          potentially casts illumination from all
%                          directions. Takes no parameters.
%
%     'spectrum' - The spectrum that the light will emit. Read
%                          from ISETCam/ISETBio light data. See
%                          "isetbio/isettools/data/lights" or
%                          "isetcam/data/lights."
%      'spectrum scale'  - scale the spectrum. Important for setting
%                          relative weights for multiple light sources.
%      'camera coordinate' - true or false. automatically place the light
%                            at the camera location.
%      'update'         - update an existing light source.
%
%
% Outputs:
%   thisR - Returned, but not really necessary because it is pass by
%           reference.
%
% Zhenyi, TL, SCIEN, 2019
% Zheng L, SCIEN, 2020
%
% See also:
%   piLightSet, piLightCreate
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

%%
error('piLightAdd has been deprecated.  Use thisR.set(''light'',''add'',newLight)');

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
    %% Update an existing light with index idxL
    
    if ~isempty(newLightSource)
        thisR.lights{idxL} = newLightSource;
    else
        % Set all the variables except for 'update' and 'newlightsource'
        for ii=1:2:numel(varargin)
            if ~strcmp(varargin{ii}, 'update') && ~strcmp(varargin{ii}, 'newlightsource')
                piLightSet(thisR,idxL,varargin{ii},varargin{ii+1});
            end
        end
    end
    
else
    %% Create a new light
    
    % These are the parameters for initializing the new light.  They are
    % built up from the varargin sent here.  We remove the 'update' and
    % 'newlightsource' parameters because they are not part of PBRT.
    newVarargin = {};
    for ii = 1:2:numel(varargin)
        if ~strcmp(varargin{ii}, 'update') && ~strcmp(varargin{ii}, 'newlightsource')
            newVarargin = [newVarargin, varargin{ii:ii+1}];
        end
    end
    
    % We create the light with parameters sent in by varargin. We call
    % piLightCreate.  The new light is attached to the recipe upon return.
    newLight = piLightCreate(newVarargin{:});
    %% Add the light to the recipe

    val = numel(piLightGet(thisR,'print',false));
    thisR.lights{val+1} = newLight;
    idx = val + 1;
    
    %% Now if the user sent in any additional arguments ...

    for ii=1:2:length(varargin)
        piLightSet(thisR,idx, newVarargin{ii}, newVarargin{ii+1});
    end
end



%% Tell the user the status.  We might turn this off some day.
% I can't see why we need to tell the user that the function worked via a
% debug message...
%if idxL, fprintf('Existing lights updated.\n');
%else,    fprintf('New light added.\n');
%end

end