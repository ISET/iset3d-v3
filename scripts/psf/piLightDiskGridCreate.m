function lights = piLightDiskGridCreate(varargin)
% Create a grid of disk area light sources  at a given depth and given
% spacing
%
% Se also piLightDiskCreate
p = inputParser;
p.addParameter('depth', @isnumeric);
p.addParameter('center', [0 0], @isnumeric);
p.addParameter('diskradius', @isnumeric)
p.addParameter('spacing', @isnumeric);
p.addParameter('grid',[0 0], @isnumeric);
p.parse(varargin{:});


depth_meters= p.Results.depth;
center_meters= p.Results.center;
radius_meters= p.Results.diskradius;
grid= p.Results.grid;
spacing_meters= p.Results.spacing;

%makeDisk('position',[center_meters(1:2) depth_meters],'radius',radius_meters);
lights={};

% Calculate top left corner
topleft=center_meters - ((grid-1)/2)*spacing_meters;

for col = [0:(grid(2)-1)]
    for row=[0:(grid(1)-1)]
        position = topleft +spacing_meters*[col row];
        lights{end+1}=piLightDiskCreate('position',[position depth_meters],'radius',radius_meters);
    end
end


end

