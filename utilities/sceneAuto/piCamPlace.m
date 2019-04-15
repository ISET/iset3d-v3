function [thisCar, thisR]= piCamPlace(varargin)
%% Find a position for camera by checking the position of cars, place the camera in front of the car.
%%
p = inputParser;
% if length(varargin) > 1
%     for i = 1:length(varargin)
%         if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
%             varargin{i} = ieParamFormat(varargin{i});
%         end
%     end
% else
%     
% end
varargin =ieParamFormat(varargin);

p.addParameter('thisR',[]);
p.addParameter('thistrafficflow',[]);
p.addParameter('nexttrafficflow',[]);
% p.addParameter('CamPosition',[]);
p.addParameter('CamOrientation','');
p.addParameter('oriOffset',0);
p.addParameter('camPos','front');
p.parse(varargin{:});

thisR = p.Results.thisR;
thisTrafficflow = p.Results.thistrafficflow;
% CamPos = p.Results.CamPosition;
CamOri = p.Results.CamOrientation;
carlist = thisTrafficflow.objects.car;
oriOffset = p.Results.oriOffset;
camPos  = p.Results.camPos;
%%
idx = [];

if isfield(thisTrafficflow.objects,'car')
    dd=1;
    for ii = 1:length(thisR.assets)
        if piContains(thisR.assets(ii).name,'car')
            if ~isempty(CamOri)
                for jj = 1:size(thisR.assets(ii).position,2)
                    orientation = thisR.assets(ii).rotate(:,jj*3-2);
                    orientation  = orientation(1);
                    if orientation <0
                        orientation = orientation+360;
                    end
                    if abs(orientation-CamOri) < 20
                        from = thisR.assets(ii).position;
                        if CamOri==270
                            if from(3)<170
                                idx{dd} = [ii,jj];
                                dd=dd+1;
                            end
                        else
                            idx{dd}=[ii,jj];dd=dd+1;
                        end
                    end
                end
            end
        end
    end
else
    error('no car found');
end
% else
%     % Check if there is a Car nearby
%     L = linspace(0,2*pi,50);
%     xv = 5*cos(L)';
%     yv = 5*sin(L)';
%     for jj = 1:length(carlist)
%         [in,on] = inpolygon(carlist(jj).pos(1),carlist(jj).pos(3),xv,yv);
%         if in || on
%             idx = jj;
%             break;
%         end
%     end
% end

% Find this car in trafficflow

thisCar = [];

if ~isempty(idx)
    thisCar=[];
    idx_num = randi(length(idx),1);
    idx = idx(idx_num);
    for jj = 1:length(carlist)
        if isempty(find((carlist(jj).pos == thisR.assets(idx{1}(1)).position(:,idx{1}(2)))==0, 1))
            thisCar = carlist(jj);
            break;
        end
    end
    from = thisR.assets(idx{1}(1)).position(:,idx{1}(2));
    orientation = thisR.assets(idx{1}(1)).rotate(:,idx{1}(2)*3-2);
    orientation = orientation(1);
    if orientation <0
        orientation = orientation+360;
    end
    orientation = orientation+oriOffset;
    % the pivot point is at the the front of the car
    switch camPos
        case 'front'
            from(1) = from(1)+rand*0.8;
            from(2) = rand*0.5 + 1.3; % random height from 1.5m to 2m;
            from(3) = from(3);
            to(1)   = from(1)+30*cosd(orientation);
            to(2)   = from(2);
            to(3)   = from(3)-30*sind(orientation);
            from = reshape(from,[3,1]);
            to   = reshape(to,[3,1]);
        case 'left'
            from(1) = from(1)-thisR.assets(idx{1}(1)).size.w/2;
            from(2) = rand*0.5 + 2.5;
            from(3) = from(3)-thisR.assets(idx{1}(1)).size.l/2;
            to(3)   = from(3)+30*cosd(orientation);
            to(2)   = from(2)-0.1;
            to(1)   = from(1)+30*sind(orientation);
            from = reshape(from,[3,1]);
            to   = reshape(to,[3,1]);
         case 'right'
            from(1) = from(1)+thisR.assets(idx{1}(1)).size.w/2;
            from(2) = rand*1.5 + 2.5;
            from(3) = from(3)-thisR.assets(idx{1}(1)).size.l/2;
            to(3)   = from(3)-30*cosd(orientation);
            to(2)   = from(2)-0.1;
            to(1)   = from(1)-30*sind(orientation);
            from = reshape(from,[3,1]);
            to   = reshape(to,[3,1]);
        case 'rear'
            from(1) = from(1)+rand*0.8;
            from(2) = rand*0.5 + 1.3;
            from(3) = from(3)-thisR.assets(idx{1}(1)).size.l;
            to(1)   = from(1)-30*cosd(orientation);
            to(2)   = from(2);
            to(3)   = from(3)+30*sind(orientation);
            from = reshape(from,[3,1]);
            to   = reshape(to,[3,1]);
    end
else
    from = 0;
    to(1)=0;
    to(2)=2;
    to(3)=30;

end
thisR.lookAt.from = from;
thisR.lookAt.to   = to;
thisR.lookAt.up = [0;1;0];
end

