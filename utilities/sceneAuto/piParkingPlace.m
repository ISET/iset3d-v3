function trafficflow = piParkingPlace(road, trafficflow, varargin)
% Add parking cars in trafficflow
%
% Syntax:
%   trafficflow = piParkingPlace(road, trafficflow, [varargin])
%
% Description:
%    Add parked cars to a trafficflow structure.
%
% Inputs:
%    Road        - Struct. A structure that includes road information.
%
% Outputs:
%    trafficflow - Struct. The trafficflow structure that contains
%                  information about the entirety of the scene for each
%                  timestep, not just active cars on the road.
%
% Optional key/value parameters:
%   density      - Numeric. A control on how many parking cars, ranging
%                  from 0~1. Default 0.5.
%

% History:
%    XX/XX/18  SL   Shuangting Liu, VISTALAB, 2018
%    05/02/19  JNM  Documentation pass

%% read the information of parking street
parking_list = road.roadinfo.parking_list;
%% parse the input
p = inputParser;
p.addParameter('density', 0.5);
p.parse(varargin{:});
inputs = p.Results;
density = inputs.density;

%%
x = size(parking_list, 2);
remain_length = 2+randi(3);
offset = parking_list(1).width/2;
% interval distance between positions of cars
interval = 12;

for jj = 1 : x
    start_point = parking_list(jj).coordinate - ...
        [cos(parking_list(jj).direction * pi / 180) * offset, ...
        -sin(parking_list(jj).direction * pi / 180) * offset];
    total_number = ...
        floor((parking_list(jj).length - 2 * remain_length) / interval);
    object_number = floor(density * ...
        (parking_list(jj).length - 2 * remain_length) / interval);
    
    rand_list = randperm(total_number);
    rand_length = rand_list(1:object_number) * 4 + ...
        remain_length * ones(1, object_number);
    coordinate_rand(1, :) = ...
        (rand_length .* sin(parking_list(jj).direction * pi / 180));
    coordinate_rand(2, :) = ...
        (cos(parking_list(jj).direction * pi / 180) .* rand_length);
    for ii = 1 : length(trafficflow)
        if isfield(trafficflow(ii).objects, 'car')
            car_num = length(trafficflow(ii).objects.car);
            for kk = 1:object_number
                trafficflow(ii).objects.car(car_num + kk).class = 'car';
                trafficflow(ii).objects.car(car_num + kk).type = ...
                    'passenger';
                trafficflow(ii).objects.car(car_num + kk).name = ...
                    sprintf('car_%d_%d', jj, kk);
                trafficflow(ii).objects.car(car_num + kk).pos = ...
                    [start_point(1) + coordinate_rand(1, kk), -0.15, ...
                    start_point(2) + coordinate_rand(2, kk)];
                trafficflow(ii).objects.car(car_num + kk).speed = 0;
                trafficflow(ii).objects.car(car_num + kk).orientation = ...
                    parking_list(jj).direction + 180;
            end
        end
    end
end
