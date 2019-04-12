function scene = piSceneCreate(photons, varargin)
% Create a scene from radiance data
%
% Syntax:
%   scene = piSceneCreate(photons, [varargin])
%
% Description:
%    Create a scene from provided radiance data.
%
% Inputs:
%    photons - Matrix. The row x col x nwave data, computed by PBRT usually
%
% Outputs:
%    scene   - Struct. The created scene structure.
%
% Optional key/value pairs:
%    fov     - Numeric. The horizontal field of view, in degrees.
%

% History:
%    XX/XX/17  BW   SCIENTSTANFORD, 2017
%    03/27/19  JNM  Documentation pass, select different sceneFile for Ex.

% Examples:
%{
    % sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bunny.dat';
    sceneFile = fullfile(piRootPath, ...
        '/local/renderings/numbersAtDepth.dat');
    photons = piReadDAT(sceneFile, 'maxPlanes', 31);
    scene = piSceneCreate(photons);
    ieAddObject(scene);
    sceneWindow;
%}

%% When the PBRT uses a pinhole, we treat the radiance data as a scene
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('photons', @isnumeric);
p.addParameter('fov', 40, @isscalar); % Horizontal fov, degrees
p.addParameter('meanluminance', 100, @isscalar);

if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.parse(photons, varargin{:});

%% Sometimes ISET is not initiated. We need at least this
global vcSESSION
if ~isfield(vcSESSION, 'SCENE'), vcSESSION.SCENE = {}; end

%% Set the photons into the scene
scene = sceneCreate;
scene = sceneSet(scene, 'photons', photons);
[r, c] = size(photons(:, :, 1));
depthMap = ones(r, c);

scene = sceneSet(scene, 'depth map', depthMap);
scene = sceneSet(scene, 'fov', p.Results.fov);
% luminance adjustment for ISETBio
scene = sceneAdjustLuminance(scene, p.Results.meanluminance);

% Adjust other parameters
if ~isempty(varargin)
    for ii = 1:2:length(varargin)
        param = varargin{ii};
        val = varargin{ii + 1};
        scene = sceneSet(scene, param, val);
    end
end

end
