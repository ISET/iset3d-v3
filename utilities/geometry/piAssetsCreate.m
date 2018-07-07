function obj = piAssetsCreate(filename)
if ~exist(filename,'file'), error('File not found'); end
% Warnings may appear about filter and Renderer
thisR = piRead(filename,'version',3);
piMaterialGroupAssign(thisR);
geometry = piGeometryRead(thisR);
obj.material =thisR.materials.list;
obj.geometry = geometry;
end