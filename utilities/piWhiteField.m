function [correctionMatrix, sensor,oi] = piWhiteField(lfRecipe,varargin)
% piWhiteField - Create a white response at the sensor to color calibrate 
%
% Syntax:
%   [correctionMatrix, sensor,oi] = piWhiteField(lfRecipe,varargin)
%
% Input:
%  lfRecipe:  Recipe describing the light field camera you used to render
%
% Optional inputs
%  'mean illuminance' - Set oi mean illuminance (default 10 lux)
%
% Returns
%    correctionMatrix:  Sensor pixel voltage array from white scene
%    sensor:            Contains the responses to the white scene
%    oi:                The light field of the white scene
%
% The white field response (correctionMatrix) is computed.  This matrix can
% be used to normalize the sensor volts from a light field camera,
% accounting for the inhomogeneity across the subpixels and for color
% sensitivity differences.  When the correction matrix is applied, a large
% white field will be rendered as white.
%
% The white scene is calculated using the same camera parameters as in the
% original light field.  This correctionMatrix can be reused, but it must
% be recalibrated if you change the number of pinholes, subpixel
% properties, lens, or film.
%
% By default, the white scene is treated as if it is a 10 lux image.  The
% sensor created here is the one returned sensorCreate('light field',oi). 
%
% See also:  s_piReadRenderLF, ip2lightfield
%
% This source file contains programming notes
%
% BW, Scien Stanford, 2017

%% Programming Notes
%
% We need a way to send in different sensor parameters, I guess.
%
% You can download the white scene, if it is not local, using\
%
%   piPBRTFetch('whiteScene');
%
%  We need a way to just save and load the white calibration values rather
%  than re-running every time.
%

%% Example
%{

% This is based on running the chess set scene.  Neaten or eliminate soon.

% Not sure why the chess voltages are so low.  Probably the exposure
% duration.
chess = sensorGet(cSensor,'volts');
chess = ieClip(chess,0,0.1);
chess = ieScale(chess,1);
vcNewGraphWin; imagesc(chess.^(1/2.2)); colormap(gray); truesize
vcNewGraphWin; histogram(chess(:));

white = sensorGet(wSensor,'volts');
white = ieScale(white,1);

foo = chess ./ white;
foo = ieScale(foo,sensorGet(sensor,'pixel voltage swing'));
vcNewGraphWin; imagesc(foo.^(1/2.2)); colormap(gray); truesize

sensor = sensorSet(sensor,'volts',foo);
ieAddObject(sensor); sensorImageWindow;

ip = ipCreate;
ip = ipCompute(ip,sensor);
lightfield = ip2lightfield(ip,'pinholes',thisR.get('n microlens'));
LFDispVidCirc(lightfield.^(1/2.2));

%}

%% Begin routine
p = inputParser;
p.addRequired('lfRecipe',@(x)(isa(x,'recipe')));

for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end
p.addParameter('meanilluminance',10,@isscalar)
p.parse(lfRecipe,varargin{:});
meanIlluminance = p.Results.meanilluminance;

%% Load in the white scene

% Read the white pbrt file.  Return it as a recipe
fname = fullfile(piRootPath,'data','whiteScene','whiteScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end
whiteRecipe = piRead(fname);

% Copy the camera and film parts of the light field recipe
whiteRecipe.camera    = lfRecipe.camera;
whiteRecipe.film      = lfRecipe.film;
whiteRecipe.sampler   = lfRecipe.sampler;
whiteRecipe.filter    = lfRecipe.filter;
whiteRecipe.renderer  = lfRecipe.renderer;

% Where we store the output
whiteRecipe.set('outputFile',fullfile(piRootPath,'local','whiteScene.pbrt'));
piWrite(whiteRecipe);

%%
oi = piRender(whiteRecipe,'renderType','radiance');
oi = oiSet(oi,'name','LF white field');
oi = oiSet(oi,'mean illuminance',meanIlluminance);
% ieAddObject(oi); oiWindow; 

%% Build up the sensor calibration
sensor = sensorCreate('light field',oi);
sensor = sensorCompute(sensor,oi);
correctionMatrix = sensorGet(sensor,'volts');
% ieAddObject(sensor); sensorImageWindow; 

end


