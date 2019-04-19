function trafficflow = piTrafficflowGeneration(road, varargin)
% Return a state(position, orientation) struct of traffic participants
%
% Syntax:
%   trafficflow = piTrafficflowGeneration(RoadType, [varargin])
%
% Description:
%    Invokes the platform-specific SUMO to create the traffic flow. It
%    returns the position of cars and status of other items at a particular
%    moment in time (timestamp).
%
% Input Parameters
%    road           - Struct. A road/roadType structure.
%
% Output
%    trafficflow    - Struct. A structure containing the state of each
%                     traffic participant at each time stamp. The state
%                     is represented by the position and orientation.
%
% Optional key/value pairs:
%    generationTime - Numeric. The time duration to generate vehicles.
%                     Default 180.
%    iterMax        - Numeric. The number of iteration in duaIterate.py.
%                     Default 1.
%    pedestrian     - Boolean. Whether or not to include pedestrians in the
%                     traffic flow. Default true.
%
% Notes:
%    * TODO: SUMO and this Matlab call should be dockerized
%    * Separate XML read & write activity into another function.
%

% History:
%    XX/XX/18  MS   Minghao Shen, VISTALAB, 2018
%    04/05/19  JNM  Documentation pass. Remove trafficFlowDensity optional
%                   parameter(unused) and add in pedestrian. Add Windows
%                   SUMO_HOME support.
%    04/19/19  JNM  Merge with master (resolve conflicts)

%% SUMO_HOME environment variable
% This needs to be generalized!
if ismac
    setenv('SUMO_HOME', '/Users/zhenyiliu/Documents/sumo/sumo-1.0.0');
    sumohome = getenv('SUMO_HOME');
elseif isunix
    [~, sumohome] = system("source ~/.bashrc;echo $SUMO_HOME");
    sumohome = sumohome(1:length(sumohome)-1);
elseif ispc
    [~, sumohome] = system("set SUMO_HOME");
    sumohome = erase(sumohome, "SUMO_HOME=");
else
    [~, sumohome] = system("echo $SUMO_HOME");
    sumohome = sumohome(1:length(sumohome)-1);
end

if length(sumohome)<2
    error(sprintf("Please add SUMO_HOME to your system path.\n") +...
        "Refer to http://sumo.dlr.de/wiki/Basics/Basic_Computer_Skills");
end

%% Parameter Definition
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.addParameter('generationTime', 180);
p.addParameter('iterMax', 1);
p.addParameter('pedestrian', true);

p.parse(varargin{:});
inputs = p.Results;
generationTime = inputs.generationTime;
iterMax = inputs.iterMax;
% density : 'low' 'medium' 'high'

% original
% vTypes = {'pedestrian', 'passenger', 'bus', 'truck'};
% probs = [1, 2, 10, 20];

vType_interval = road.vTypes;
vTypes = keys(vType_interval);
% interval = values(vType_interval);

%% Define a Path for sumo output by given scenetype and roadtype.
netfileName = road.name;
netPath = fullfile(piRootPath, 'data', 'sumo_input', netfileName, ...
    strcat(netfileName, '.net.xml'));
outputPath = fullfile(piRootPath, 'local');
chdir(outputPath);
if ~exist('sumo_output', 'dir'), mkdir('sumo_output');end
chdir('sumo_output');
% Name with current time
currentTime = datestr(now, 'yy_mm_dd_HH_MM_SS');
mkdir(currentTime);
outputPath = fullfile(outputPath, 'sumo_output', currentTime);
chdir(outputPath);

%% Sumo Commands Definition: vehicle type/pedestrian/ simulation parameters
tic
randomTrips = ...
    fullfile(piRootPath, 'data', 'sumo_input', 'generateTrips.py');
duaIterate = strcat(" ", sumohome, '/tools/assign/duaIterate.py');
pycmd = "python ";
netcfg = strcat(' -n', " ", netPath);
outSymbol = strcat(' -o');

vTypes = keys(vType_interval);
route_collect = '';
for ii = 1:vType_interval.Count
    % store trips/routes for different types of vehicles in different
    % directorys
    if ~isequal(vType_interval(vTypes{ii}), 0)
        fullfilePath = fullfile(pwd, vTypes{ii});
        if ~exist(fullfilePath, 'dir'), mkdir(fullfilePath); end
        chdir(vTypes{ii});

        %randomTrips
        probcfg = strcat(' -p', " ", num2str(vType_interval(vTypes{ii})));
        timecfg = strcat(' -e', " ", num2str(generationTime));
        outcfg = strcat(outSymbol, " ", vTypes{ii});
        if strcmp(vTypes{ii}, 'pedestrian')
            vehcfg = ' --pedestrians';
        else
            vehcfg = strcat(' --vehicle-class', " ", vTypes{ii});
        end
        tripsCmd = strcat(pycmd, randomTrips, netcfg, timecfg, outcfg, ...
            probcfg, vehcfg);
        system(tripsCmd);

        % modify .trips.xml file
        % expression = '(?< = id = ")(\w*)(? = " type = "\w*")';

        % duaIterate
        tripscfg = strcat(' -t', " ", vTypes{ii}, ".trips.xml");
        outfilecfg = strcat(' -o', " ", vTypes{ii}, "_000.rou.xml");
        itercfg = strcat(' -l', " ", num2str(iterMax));
        % duaCmd = strcat(pycmd, duaIterate, netcfg, tripscfg, itercfg);
        duaCmd = strcat(...
            'duarouter', netcfg, tripscfg, outfilecfg, itercfg);

        system(duaCmd);

        % because duaIterate generates vehicle id from 0 to end; so
        % vehicles share the same id if you run duaIterate multiple times;
        % separating id among vehicle types is needed;
        if ~isempty(route_collect)
            route_collect = strcat(route_collect, ", ");
        end
        route_collect = strcat(route_collect, vTypes{ii}, '/', ...
            vTypes{ii}, '_', sprintf("%03d", iterMax-1), '.rou.xml');

        route_name = strcat(vTypes{ii}, '_', ...
            sprintf("%03d", iterMax-1), '.rou.xml');
        route_file = fileread(route_name);
        expression = '(?< = id = ")(\w*)(? = " type = "\w*")';
        replace = strcat('$1_', vTypes{ii});
        route_append_file = regexprep(route_file, expression, replace);
        routeid = fopen(route_name, 'wt+');
        fprintf(routeid, route_append_file);
        fclose(routeid);

        % Return to original directory
        chdir('..');
    end
end

%% Write .add.xml
writeIntersection = ...
    fullfile(piRootPath, 'data', 'sumo_input', 'writeIntersection.py');
addcfg = strcat(" -o ", convertCharsToStrings(netfileName));
addCmd = strcat(pycmd, writeIntersection, netcfg, addcfg);
system(addCmd);

%% Write .sumocfg
cfgid = fopen(strcat(netfileName, '.sumocfg'), 'wt');
fprintf(cfgid, '<configuration>\n    <input>\n');
fprintf(cfgid, strcat('        <net-file value = "', netPath, '"/>\n'));
fprintf(cfgid, strcat('        <route-files value = "', ...
    route_collect, '"/>\n'));
addcheck = dir('*.add.xml');
if ~isempty(addcheck)
% if ~isempty(intersections)
    fprintf(cfgid, strcat('        <additional-files value = "', ...
        netfileName, '.add.xml"/>\n'));
end
fprintf(cfgid, '    </input>\n');
fprintf(cfgid, '    <time>\n');
fprintf(cfgid, '        <begin value = "0"/>\n');
fprintf(cfgid, strcat('        <end value = "', ...
    num2str(2 * generationTime), '"/>\n'));
fprintf(cfgid, '    </time>\n');
fprintf(cfgid, '</configuration>');
fclose(cfgid);

%% run sumo-simulation to generate a trafficflow .xml file
sumocmd = strcat(sumohome, '/bin/sumo -c', " ", netfileName, ...
    '.sumocfg --fcd-output', " ", netfileName, '_state.xml');
system(sumocmd);
if ~isempty(addcheck)
    trafficflow = piSumoRead('flowfile', ...
        strcat(netfileName, '_state.xml'), 'lightfile', ...
        strcat(netfileName, '_traffic_light.xml'));
else
    trafficflow = piSumoRead('flowfile', ...
        strcat(netfileName, '_state.xml'));toc
end

end