function [img, filename] = piSensorImage(oi,varargin)
% Make an image from the OI by passing through a sensor and IP
%
% Syntax
%   [img,filename] = piSensorImage(oi, ...)
%
% Description
%  Convert the oi through a sensor and the ip into an RGB image. We do this
%  because the OI itself can be very high dynamic range, and the
%  oiGet(oi,'rgb') may not save well.  This method always produces some
%  sort of a reasonable image.  The simulated sensor is 1.5 microns.
%
% Input
%   oi
% Key/value
%   filename
% Outputs
%   img
%   fname
%
% Wandell
%
% See also
%

% Examples:
%{
  oi = ieGetObject('oi');
  img = piSensorImage(oi);
  fname = fullfile(piRootPath,'local',oiGet(oi,'name'));
  imwrite(img,fname,'png')
%}

%%
p = inputParser;
p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addParameter('filename','',@ischar);
p.parse(oi,varargin{:});
filename = p.Results.filename;

%% High resolution sensor
sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size constant fill factor',[1.5 1.5]*1e-6);
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% Image process
ip = ipCreate;
ip = ipCompute(ip,sensor);

img = ipGet(ip,'srgb');
% ipWindow(ip);

%% Test for saving
if ~isempty(filename)
    imwrite(img,filename);
end


end


