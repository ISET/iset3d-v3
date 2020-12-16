%% Create a new material

mat.name
mat.type
mat.kd.type
mat.kd.value

thisR.get('material', MATNAME);
thisR.get('material', MATNAME, 'name')
thisR.get('material', MATNAME, 'type')
thisR.get('material', MATNAME, 'kd')
thisR.get('material', MATNAME, 'kd type')
thisR.get('material', MATNAME, 'kd value')

thisR.set('material', MATNAME, key -'kd spectrum', val - [400 1 800 1]);

