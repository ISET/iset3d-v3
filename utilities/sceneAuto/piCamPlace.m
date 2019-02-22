function [thisCar, from,to,orientation]= piCamPlace(varargin)
%% Find a position for camera by checking the position of cars, place the camera in front of the car.
%%
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin =ieParamFormat(varargin);
end
p.addParameter('thistrafficflow',[]);
p.addParameter('nexttrafficflow',[]);
p.addParameter('CamPosition',[]);
p.addParameter('CamOrientation','');
p.parse(varargin{:});

thisTrafficflow = p.Results.thistrafficflow;
CamPos = p.Results.CamPosition;
CamOri = p.Results.CamOrientation;
carlist = thisTrafficflow.objects.car;
%%
idx = [];
if isempty(CamPos)
    if isfield(thisTrafficflow.objects,'car')
        dd=1;
        for ii = 1:length(carlist)
            if ~isempty(CamOri)
                orientation = carlist(ii).orientation-90;
                if orientation <0
                    orientation = orientation+360;
                end
                if abs(orientation-CamOri) < 20
                    idx(dd) = ii;dd=dd+1;
                end
            end
        end
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
    idx_num = randi(length(idx),1);
    idx = idx(idx_num);
    thisCar = carlist(idx);
    from = carlist(idx).pos;
    orientation = carlist(idx).orientation-90;
    if orientation <0
        orientation = orientation+360;
    end
    if ~isempty(CamOri)
        
    end
    % the pivot point is at the the front of the car
    from(1) = from(1);
    from(2) = rand*0.5 + 1.5; % random height from 1.5m to 2m;
    from(3) = from(3);
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