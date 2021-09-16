function pointsource = piLightDiskCreate(varargin)
% Create a diffuse Area source in the shape of disk
% By default the normal vector on the disk is pointing in the z-direction

p = inputParser;
p.addParameter('position', @isnumeric);
p.addParameter('radius', @isnumeric)
p.parse(varargin{:});

position_meters= p.Results.position;
radius_meters= p.Results.radius;

pointsource =  piLightCreate('diffuse disk source',...
    'type','area');
    
pointsource.translation.value = {[position_meters]};
shape.radius=radius_meters;
shape.meshshape='disk';
pointsource.shape.value=shape;

end

