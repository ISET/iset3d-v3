function pointsource = makeDisk(varargin)

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

