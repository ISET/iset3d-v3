function thisR = piMotionBlurEgo(thisR,varargin)
% Modify render recipe to add motion blur to ego vehicle by given trafficflow.
%       thisR;
%       fps;
%       trafficflow;
%       thisCar;
%Output:
%       None;
%
%
%%
p = inputParser;
p.addRequired('thisR',@(x)(isequal(class(x),'recipe')));
p.addParameter('fps',60,@isnumeric);
% pass in trafficflow with given timestamp
p.addParameter('nextTrafficflow',[]);
p.addParameter('thisCar',@isstruct);
p.parse(thisR,varargin{:});

thisR = p.Results.thisR;
fps   = p.Results.fps;
nextTrafficflow = p.Results.nextTrafficflow;
thisCar = p.Results.thisCar;
%% Add shutter open time
shutterclosed = 1/fps;
thisR.camera.shutteropen.type = 'float';
thisR.camera.shutteropen.value = 0;
thisR.camera.shutterclose.type = 'float';
thisR.camera.shutterclose.value = shutterclosed;
%%
motion = [];

for ii = 1:numel(nextTrafficflow.objects.car)
    if strcmp(thisCar.name,nextTrafficflow.objects.car(ii).name)
        motion.pos = nextTrafficflow.objects.car(ii).pos;
        motion.pos(2) = thisR.lookAt.from(2);
        motion.rotate = nextTrafficflow.objects.car(ii).orientation;
        motion.slope = nextTrafficflow.objects.car(ii).slope;
    end
end
if isempty(motion)
    % there are cases when a car is going out of boundary or just disappear
    % for some other reason, so in these cases, the motion info remains 
    % empty or we should estimate motion End position by speed information;
    from = thisCar.pos;
    distance = thisCar.speed;
    orientation = thisCar.orientation;
    to(1)   = from(1)+distance*cosd(orientation);
    to(2)   = thisR.lookAt.from(2);
    to(3)   = from(3)-distance*sind(orientation);
    motion.pos = to;
    motion.rotate = thisCar.orientation;
    motion.slope = thisCar.slope;
end

thisCar.pos(2) = thisR.lookAt.from(2);

%%
% default start time is 0, end time is 1; It means that the motion duration
% is 1 second by default.
thisR.camera.motion.activeTransformStart.pos   = thisCar.pos;
thisR.camera.motion.activeTransformStart.rotate=piRotationMatrix('yrot',thisCar.orientation);
% translation and rotation will be written out.
thisR.camera.motion.activeTransformEnd.pos     = motion.pos;
thisR.camera.motion.activeTransformEnd.rotate  = piRotationMatrix('yrot', motion.rotate);
end



















