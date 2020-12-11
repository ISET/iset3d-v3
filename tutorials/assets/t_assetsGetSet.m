% t_assetsGetSet
% The desired style should be 
% thisR.set('asset object', 'name', 'material', 'value')
% thisR.set('asset light', 'name', 'field')
% thisR.set('asset branch', 'name', 'position', 'value')
% Leaves can be objects or lights, branches are place holder for
% transforms.
% Similarly for thisR.get('asset object', 'name', val, 'material')

%%
param = 'asset object';
[o, p] = ieParameterOtype(param);

[o, p] = ieParameterOtype('rays per pixel')