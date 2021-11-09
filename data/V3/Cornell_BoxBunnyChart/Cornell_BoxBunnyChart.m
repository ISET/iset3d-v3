% Make the CornellBox_BunnyChart recipe 
%
%  We edited out some unnecessary assets, add a light and rename the
%  bunny properly.
%
% BW/ZLy

%%
% The default has no light and some unwanted assets
thisR = piRecipeDefault('scene name','cornellboxbunnychart','load recipe',false);

%% Add a disant light.  

% By default this is at the position of the camera and facing towards
% the Cornell Box
distantLight = piLightCreate('lamp', 'type', 'distant');
thisR.set('light','add',distantLight);

%%
thisR.set('asset','001_Area Light_O','delete');
thisR.set('asset','Area Light_B','delete');
thisR.set('asset','Box_O','delete');

thisR.set('asset','001_EIA_O','delete');
thisR.set('asset','EIA_B','delete');

%% Get everybody aligned.
%
% Rectification places 'from' at 000 and the 'to' at 001.
% Other objects are appropriately rotated.
%
thisR = piRecipeRectify(thisR);
% piAssetGeometry(thisR);
%

thisR.set('asset','Default_B','name','Bunny_B');
thisR.set('asset','001_Default_O','name','001_Bunny_O');

%% Adjust some positions
%
% thisR.show('objects');
%

% If we rectify first,tnen all these numbers have to change.
% 2.69 -11.00 69.66
thisR.set('asset','001_USAF_O','world position',[2.69 0.00 69.66]);

% 6.89 -11.00 46.50
thisR.set('asset','001_MCC_O','world position',[-12 10.00 69]);

% Orient the MCC towards the camera.  
% thisR.set('asset','001_MCC_O','world rotate',[0 -1 0]);
thisR.set('film resolution',[160 160]);


%%
piWRS(thisR);


%%
thisR.save;

%% END
