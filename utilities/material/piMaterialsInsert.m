function [thisR, materialNames] = piMaterialsInsert(thisR)
% Insert default materials into a recipe
%
% Synopsis
%  [thisR. materialNames] = piMaterialsInsert(thisR)
%
% Brief description
%   Makes it easy to add a collection of materials to use for the scene
%   objects. 
%
% Input
%   thisR - Recipe
%
% Output
%   thisR - Recipe now has additional materials attached
%   materialNames - cell array, but use thisR.get('print  materials')
%
% Description
%   We add materials with textures, colors, some plastics.  This will need
%   to be completely changed for V4.  But it gives a list of materials that
%   we are likely to want.
%
%   For a while, I used piTexturesInsert also.  But instead, I insert the
%   textures for the materials here.  Mostly the user will want to create a
%   material and that material might need a texture.
%
% See also
%   piTexturesInsert (deprecated)

%% Need variable checking

materialNames = {};

%% Simple materials

% Turn the letter A to Glass material
thisMaterialName = 'glass'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'glass');
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

thisMaterialName = 'Red'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'uber');
thisMaterial = piMaterialSet(thisMaterial,'kd',[1 0.3 0.3]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

thisMaterialName = 'Red_plastic'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'plastic');
thisMaterial = piMaterialSet(thisMaterial,'kd',[1 0.3 0.3]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

thisMaterialName = 'White'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'uber');
thisMaterial = piMaterialSet(thisMaterial,'kd',[1 1 1]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

thisMaterialName = 'White_plastic'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'plastic');
thisMaterial = piMaterialSet(thisMaterial,'kd',[1 1 1]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Make a new material like White, but color it gray
thisMaterialName = 'Gray'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'uber');
thisMaterial = piMaterialSet(thisMaterial,'kd',[0.2 0.2 0.2]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Make a new material like White, but color it gray
thisMaterialName = 'Gray_plastic'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'plastic');
thisMaterial = piMaterialSet(thisMaterial,'kd',[0.2 0.2 0.2]);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Make a new material like White, but make it specular/shiny
thisMaterialName = 'Shiny'; 
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'plastic');
thisMaterial = piMaterialSet(thisMaterial,'kd',[0.7 0.7 0.7]);
thisMaterial = piMaterialSet(thisMaterial,'ks',[1 1 1]);
thisMaterial = piMaterialSet(thisMaterial,'roughness',1);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

thisMaterialName = 'mirror';
thisMaterial = piMaterialCreate(thisMaterialName, 'type', 'mirror');
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

%% Materials based on textures

% Wood grain (light, large grain)
thisMaterialName = 'wood001';
thisTexture = piTextureCreate(thisMaterialName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'woodgrain001.png');
thisR.set('texture', 'add', thisTexture);
thisMaterial = piMaterialCreate(thisMaterialName,'type','uber','kd val',thisMaterialName);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Wood grain (light, large grain)
thisMaterialName = 'wood002';
thisTexture = piTextureCreate(thisMaterialName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'woodgrain002.exr');
thisR.set('texture', 'add', thisTexture);
thisMaterial = piMaterialCreate(thisMaterialName,'type','uber','kd val',thisMaterialName);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Mahogany 
thisMaterialName = 'mahogany';
thisTexture = piTextureCreate(thisMaterialName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'mahoganyDark.exr');
thisR.set('texture', 'add', thisTexture);
thisMaterial = piMaterialCreate(thisMaterialName,'type','plastic','kd val',thisMaterialName);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Brick wall
thisMaterialName = 'brickwall';
thisTexture = piTextureCreate(thisMaterialName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'brickwall001.png');
thisR.set('texture', 'add', thisTexture);
thisMaterial = piMaterialCreate(thisMaterialName,'type','uber','kd val',thisMaterialName);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

% Marble
thisMaterialName = 'marbleBeige';
thisTexture = piTextureCreate(thisMaterialName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', 'marbleBeige.exr');
thisR.set('texture', 'add', thisTexture);
thisMaterial = piMaterialCreate(thisMaterialName,'type','uber','kd val',thisMaterialName);
thisR.set('material', 'add', thisMaterial);
materialNames{end+1} = thisMaterialName;

if true
    thisR.get('print materials');
end

end