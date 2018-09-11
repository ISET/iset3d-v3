function [from,to,orientation]= piCamPlace(varargin)
%% Find a position for camera.
p = inputParser;
p.addParameter('trafficflow',[]);
p.addParameter('timestamp','');
p.addParameter('CamPosition',[]);
p.addParameter('CamOrientation','');
p.parse(varargin{:});
trafficflow = p.Results.trafficflow;
timestamp = p.Results.timestamp;
CamPos = p.Results.CamPosition;
CamOri = p.Results.CamOrientation;
carlist = trafficflow(timestamp).objects.car;
idx = [];
if isempty(CamPos)
if isfield(trafficflow(timestamp).objects,'car')
    idx = randi(length(carlist),1);
else
    disp('Can not find a position for camera');
end
else
    % Check if there is a Car nearby
    L = linspace(0,2*pi,50);
    xv = 5*cos(L)';
    yv = 5*sin(L)';
    for jj = 1:length(carlist)
        [in,on] = inpolygon(carlist(jj).pos(1),carlist(jj).pos(3),xv,yv);
        if in || on
            idx = jj;
            break;
        end
    end 
end
if ~isempty(idx)
from = trafficflow(timestamp).objects.car(idx).pos;
orientation = carlist(idx).orientation-90;

from(1) = from(1)+2*cosd(orientation);
from(2) = rand*0.5 + 1.5; % random height from 1.5m to 2m;
from(3) = from(3)-2*sind(orientation);
to(1)   = from(1)+30*cosd(orientation);
to(2)   = from(2);
to(3)   = from(3)-30*sind(orientation);    

else
    from = CamPos;
    to(1)   = from(1)+30*cosd(CamOri);
    to(2)   = from(2);
    to(3)   = from(3)-30*sind(CamOri);
    orientation = CamOri;
end
from = reshape(from,[3,1]);
to   = reshape(to,[3,1]);
end