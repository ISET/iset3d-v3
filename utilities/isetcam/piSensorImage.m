function [img, fname] = piSensorImage(oi)
% Make an image from the OI by passing through a sensor and IP
%
%  We do this because the OI itself can be very high dynamic range, and the
%  oiGet(oi,'rgb') may not save well.  By using this method, we always get
%  some sort of a reasonable image
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
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

ip = ipCreate;
ip = ipCompute(ip,sensor);

img = ipGet(ip,'srgb');
% ipWindow(ip);

end


