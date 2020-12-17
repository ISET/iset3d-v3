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
matName = 'Mat';
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene)

%% Get function
thisMat = thisR.get('material', matName);
nameCheck = thisR.get('material', matName, 'name');
kd = thisR.get('material', matName, 'kd');
kdType = thisR.get('material', matName, 'kd type');
kdVal = thisR.get('material', matName, 'kd value');
thisR.get('materials print');

%% Set function
thisR.set('material', matName, 'kd value', [400 1 800 1]);
thisR.set('material', mat.name, 'kd value', [1 1 1]);
thisR.set('material', 2, mat);

%% Add and delete
mat = piMaterialCreate('new material');
thisR.set('material', 'add', mat);
thisR.set('material', 'delete', mat.name)

