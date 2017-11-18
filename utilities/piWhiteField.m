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
%  None
% Returns
%    correctionMatrix:  Sensor pixel voltage array from white scene
%    sensor:            Contains the responses to the white scene
%    oi:                The light field of the white scene
%
% The white field response (correctionMatrix) can be used to normalize the
% sensor response.  In this case, a large white field will be rendered as
% white.   
%
% The white scene has to be calculated using the same camera parameters as
% in the original light field.  This correctionMatrix can be reused if the
% camera is maintained, but it must be recalibrated if we change the number
% of pinholes, subpixel properties, lens, or film.
%
% See also:  s_piReadRenderLF, ip2lightfield
%
% This source file contains programming notes
%
% BW, Scien Stanford, 2017

% Programming Notes
%
%  You can download the white scene, if it is not local, using
%   piFetchPBRT('whiteScene');
%  We need a way to just save and load the white calibration values rather
%  than re-running every time.
%
%{

% This is based on running the chess set scene.

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
vcAddObject(sensor); sensorImageWindow;

ip = ipCreate;
ip = ipCompute(ip,sensor);
lightfield = ip2lightfield(ip,'pinholes',thisR.get('n microlens'));
LFDispVidCirc(lightfield.^(1/2.2));

%}

%% Load in the white scene

% Read the white pbrt file.  Return it as a recipe
fname = fullfile(piRootPath,'data','whiteScene','whiteScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end
whiteRecipe = piRead(fname);

% Copy the camera and film parts of the light field recipe
whiteRecipe.camera = lfRecipe.camera;
whiteRecipe.film   = lfRecipe.film;

% Where we store the output
whiteRecipe.set('outputFile',fullfile(piRootPath,'local','whiteScene.pbrt'));
piWrite(whiteRecipe);

%%
oi = piRender(whiteRecipe);
oi = oiSet(oi,'name','LF white field');

%% Build up the sensor calibration
sensor = sensorCreate('light field',oi);
sensor = sensorCompute(sensor,oi);
correctionMatrix = sensorGet(sensor,'volts');

% vcAddObject(sensor); sensorImageWindow;
%% 
end


