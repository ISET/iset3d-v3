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
%       'light spectrum' - The spectrum that the light will emit. Read
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
%       Not al the lights and parameters can be represented in ISET3d at
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
  % Need to get a recipe in here!
  thisR = piRecipeDefault;
  lightSources = piLightGet(thisR);
  thisR = piLightDelete(thisR, 1);
  thisR = piLightAdd(thisR, 'type', 'point');
  thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);  % Allow spaces and capitalization

p = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('name', 'Default light', @ischar);
p.addParameter('type', 'point', @ischar);
% Load in a light source saved in ISETCam/data/lights
p.addParameter('lightspectrum', 'D65');
% used for point/spot/distant/laser light
p.addParameter('from', [0 0 0]);
% used for spot light
p.addParameter('to', [0 0 1]);

% The angle that the spotlight's cone makes with its primary axis.
% For directions up to this angle from the main axis, the full radiant
% intensity given by "I" is emitted. After this angle and up to
% "coneangle" + "conedeltaangle", illumination falls off until it is zero.
p.addParameter('coneangle', 30, @isnumeric); % It's 30 by default
% The angle at which the spotlight intensity begins to fall off at the edges.
p.addParameter('conedeltaangle', 5, @isnumeric); % It's 5 by default
% place a lightsource at the camera's position
p.addParameter('cameracoordinate',false);
% scale the spectrum
p.addParameter('spectrumscale', 1);
% update an exist light
p.addParameter('update',0);

% Directly assign update a light source with one
p.addParameter('newlightsource', [], @isstruct);

p.parse(thisR, varargin{:});

name = p.Results.name;
type = p.Results.type;
lightSpectrum = p.Results.lightspectrum;
spectrumScale = p.Results.spectrumscale;
from      = p.Results.from;
to        = p.Results.to;
coneAngle = p.Results.coneangle;
coneDeltaAngle   = p.Results.conedeltaangle;
idxL             = p.Results.update;
newLightSource   = p.Results.newlightsource;
cameraCoordinate = p.Results.cameracoordinate;

%%

if idxL
    %% Updating the light at index idxL
    
    if ~isempty(newLightSource)
        thisR.lights{idxL} = newLightSource;
    else
        for ii=1:2:numel(varargin)
            piLightSet(thisR,idxL,varargin{ii},varargin{ii+1});
            
        end
    end
    

    %{
    if find(piContains(varargin), 'type')
        thisR.lights{idxL}.type = type;
    end
    
    if find(piContains(varargin, 'name'))
        thisR.lights{idxL}.name = name;
    end
    
    if any(piContains(varargin, 'lightspectrum'))
        thisR.lights{idxL}.lightspectrum = lightSpectrum;
    end
   
    if any(piContains(varargin, 'from'))
        thisR.lights{idxL}.from = from;
    end
    
    if any(piContains(varargin, 'to'))
        thisR.lights{idxL}.to = to;
    end

    if any(piContains(varargin, 'coneangle'))
        thisR.lights{idxL}.coneangle = coneAngle;
    end

    if any(piContains(varargin, 'conedeltaangle'))
        thisR.lights{idxL}.conedeltaangle = coneDeltaAngle;
    end

    if any(piContains(varargin, 'spectrumscale'))
        thisR.lights{idxL}.spectrumscale = spectrumScale;
    end
    
    if any(piContains(varargin, 'cameracoordinate'))
        thisR.lights{idxL}.cameracoordinate = cameraCoordinate;
    end
    
    return;
end
%}
else
    %% Create a new light
    newLight{1} = piLightInit(thisR);
    
    newLight{1}.name = name;
    newLight{1}.spectrumscale = spectrumScale;
    
    %% Write out lightspectrum into a light .spd file
    if ischar(lightSpectrum)
        try
            % Load from ISETCam/ISETBio ligt data
            thisLight = load(lightSpectrum);
        catch
            error('%s light is not recognized \n', lightSpectrum);
        end
        outputDir = fileparts(thisR.outputFile);
        lightSpdDir = fullfile(outputDir, 'spds', 'lights');
        thisLightfile = fullfile(lightSpdDir,...
            sprintf('%s.spd', lightSpectrum));
        if ~exist(lightSpdDir, 'dir'), mkdir(lightSpdDir); end
        fid = fopen(thisLightfile, 'w');
        for ii = 1: length(thisLight.data)
            fprintf(fid, '%d %d \n', thisLight.wavelength(ii), thisLight.data(ii)*spectrumScale);
        end
        fclose(fid);
        % Zheng Lyu added 10-2019
        if ~isfile(fullfile(lightSpdDir,strcat(lightSpectrum, '.mat')))
            copyfile(which(strcat(lightSpectrum, '.mat')), lightSpdDir);
        end
    else
        % to do
        % add customized lightspectrum array [400 1 600 1 800 1]
    end
end

%% Construct a lightsource structure
% Different types of lights that we know how to add.

if cameraCoordinate
    newLight{1}.cameracoordinate = true;
end

switch type
    case 'point'
        newLight{1}.type = 'point';

        newLight{1}.spectrum = lightSpectrum;
        newLight{1}.from = from;
        
    case 'spot'
        newLight{1}.type = 'spot';
        newLight{1}.spectrum = lightSpectrum;
        newLight{1}.from = from;
        newLight{1}.to = to;
        
        newLight{1}.coneangle = coneAngle;
        newLight{1}.conedeltaangle = coneDeltaAngle;
    case 'laser'
        newLight{1}.type = 'laser';
        newLight{1}.spectrum = lightSpectrum;
        newLight{1}.from = from;
        newLight{1}.to = to;
        
        newLight{1}.coneangle = coneAngle;
        newLight{1}.conedeltaangle = coneDeltaAngle;
    case 'distant'
        newLight{1}.spectrum = lightSpectrum;
        newLight{1}.from = from;
        newLight{1}.to = to;
    case 'infinite'
        newLight{1}.spectrum = lightSpectrum;
    case 'area'
        newLight{1}.name = name;
        newLight{1}.spectrumscale = spectrumScale;
        newLight{1}.type = 'area';
        newLight{1}.spectrum = lightSpectrum;
end

%% Add the lightSources into recipe.lights
thisR.lights{numel(thisR.lights)+1:numel(thisR.lights)+numel(newLight)} = newLight{:};
thisR.lights = piLightGet(thisR, 'print', false);

%% Tell the user the status.  We might turn this off some day.

if idxL, fprintf('Existing lights updated.\n');
else,    fprintf('New light added.\n');
end

end