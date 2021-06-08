%% t_slantedBarMTFCam
%
% Example of using the slanted bar and ISETCam for deriving the MTF.  
%
% Under development.
%
% See also
%   t_slantedBarMTF (uses ISETBio)
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Show that we have a reasonable scene

thisR = piRecipeDefault('scene name','slantedbar');
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);

% These are the materials and assets
thisR.show('assetsmaterials');

%%  Add a lens and compute the OI

% Not sure we have the focus set well.  We need to check.  
% We can render at a couple of different distances (camera positions).
lensname = 'dgauss.22deg.6.0mm.json';
c = piCameraCreate('omni','lens file',lensname);
thisR.set('camera',c); 

% More than 200 samples per degree.
thisR.set('fov',3);
thisR.set('spatial samples',[640,640]);

% The geometry looks wrong
% piAssetGeometry(thisR)

piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);

%% Image through a sensor

% The pixel size is not the limit!
sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
sensor = sensorSet(sensor,'fov',4,oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Image process

ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%%  Select the rectangle and calculate the MTF

% For the small image, this was an OK selection
% positions = [108    69   148   195]

% But if you want to choose by hand, do this.  The rect needs to be taller
% than wide.
[locs,rect] = ieROISelect(ip);
positions = round(rect.Position);

mtfData = ieISO12233(ip,sensor,'all',positions);
ieDrawShape(ip,'rectangle',positions);

%% END
