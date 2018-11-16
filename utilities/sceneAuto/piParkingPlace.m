function trafficflow=piParkingPlace(road, trafficflow, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: Add parking cars in trafficflow
%
% Inputs
%  Road: include road information
%
% Optional key/value parameters
%   density: control how many parking cars, ranging from 0~1
%
% Output
%   trafficflow: including parking cars' information
%
% Shuangting Liu, VISTALAB, 2018
%% read the information of parking street
parking_list=road.roadinfo.parking_list;
%% parse the input
p = inputParser;
p.addParameter('density',0.5);
p.parse(varargin{:});
inputs = p.Results;
density = inputs.density;
%%
x = size(parking_list,2);
remain_length=2+randi(3);
offset = parking_list(1).width/2;
% interval distance between positions of cars
interval=12;

for jj = 1 : x
    start_point = parking_list(jj).coordinate - [cos(parking_list(jj).direction*pi/180)*offset, -sin(parking_list(jj).direction*pi/180)*offset];
    total_number = floor((parking_list(jj).length-2*remain_length)/interval);
    object_number = floor(density*(parking_list(jj).length-2*remain_length)/interval);
    
    rand_list = randperm(total_number);
    rand_length =rand_list(1:object_number)*4+remain_length*ones(1,object_number);
    coordinate_rand(1,:) = (rand_length .* sin(parking_list(jj).direction * pi/180));
    coordinate_rand(2,:) = (cos(parking_list(jj).direction * pi/180) .* rand_length);
    for ii = 1 : length(trafficflow)
        car_num= length(trafficflow(ii).objects.car);
        for kk =1:object_number
            trafficflow(ii).objects.car(car_num+kk).class='car';
            trafficflow(ii).objects.car(car_num+kk).type='passenger';
            trafficflow(ii).objects.car(car_num+kk).name=sprintf('car_%d_%d',jj,kk);
            trafficflow(ii).objects.car(car_num+kk).pos=[start_point(1) + coordinate_rand(1,kk), -0.15, start_point(2) + coordinate_rand(2,kk)];
            trafficflow(ii).objects.car(car_num+kk).speed=0;
            trafficflow(ii).objects.car(car_num+kk).orientation= parking_list(jj).direction+180;
        end
    end
end
