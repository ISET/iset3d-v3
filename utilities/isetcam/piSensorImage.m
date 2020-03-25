function [img, filename, camera] = piSensorImage(oi,varargin)
% Make an image from the OI after passing through a sensor and ip pipeline
%
% Syntax
%   [img, filename, camera] = piSensorImage(oi, ...)
%
% Description
%  Convert the oi through a sensor and the ip into an RGB image. We do this
%  because the OI itself can be very high dynamic range, and the
%  oiGet(oi,'rgb') may not save well.  This method always produces some
%  sort of a reasonable image.  
%
% Input
%   oi          - The optical image returned by the PBRT Docker container
%
% Key/value
%   filename    - Output png file
%   pixel size  - Default value is 2 (in microns)
%   exp time    - Default value is 10 ms
%
% Outputs
%   img         - RGB image
%   fname       - Output file name (full path)
%
% Wandell
%
% See also
%
% TODO:
%   Return a camera, with the oi, sensor and ip, rather than separate
%   items.
%   Allow setting parameters here, or maybe just run cameraCompute with the
%   returned camera.  To decide.

% Examples:
%{
  oi = ieGetObject('oi');
  img = piSensorImage(oi);
  fname = fullfile(piRootPath,'local',oiGet(oi,'name'));
  imwrite(img,fname,'png')
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addParameter('filename','',@ischar);
p.addParameter('pixelsize',2,@isscalar);
p.addParameter('exptime',0.010,@isscalar);

p.parse(oi,varargin{:});
filename = p.Results.filename;
pSize    = p.Results.pixelsize;
expTime  = p.Results.exptime;

%% High resolution sensor
sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size constant fill factor',[pSize pSize]*1e-6);
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorSet(sensor,'exp time',expTime);
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

if nargout > 2
    camera = cameraCreate;
    camera = cameraSet(camera,'oi',oi);
    camera = cameraSet(camera,'sensor',sensor);
    camera = cameraSet(camera,'ip',ip);
end


end


