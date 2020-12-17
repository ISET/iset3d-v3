%% Create a new material

%{
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
%}

%% Create recipe
thisR = piRecipeDefault;

piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene)

%% Get function
matName = 'Patch01Material';
thisMat = thisR.get('material', matName);
nameCheck = thisR.get('material', matName, 'name');
kd = thisR.get('material', matName, 'kd');
kdType = thisR.get('material', matName, 'kd type');
kdVal = thisR.get('material', matName, 'kd value');
thisR.get('materials print');

%% Set function
thisR.set('material', matName, 'kd value', [0 1 0]);
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene)

%% Add and delete
mat = piMaterialCreate('new material');
thisR.set('material', 'add', mat);
thisR.set('material', 'delete', mat.name);

