% Make the CornellBox_BunnyChart recipe that has a light and is clean
%

% The default has no light and some unwanted assets
thisR = piRecipeDefault('scene name','cornellboxbunnychart','load recipe',false);

% Add a disant light.  By default this is at the position of the
% camera and facing towards the Cornell Box
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
% This doesn't work yet.  Solve it!
%
% thisR = piRecipeRectify(thisR);
% piAssetGeometry(thisR);
%

thisR.set('asset','Default_B','name','Bunny_B');
thisR.set('asset','001_Default_O','name','001_Bunny_O');

% If we rectify first,tnen all these numbers have to change.
thisR.set('asset','001_USAF_O','world position',[12 18.00 -2.69]);

thisR.set('asset','001_MCC_O','world position',[12 25.00 6.00]);
thisR.set('asset','001_MCC_O','world rotate',[-2 0 2]);
thisR.set('film resolution',[160 160]);


%%
piWRS(thisR);


%%
thisR.save;

%% END
