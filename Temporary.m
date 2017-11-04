% Temporary
%
% These were the parameters that seemed to run pretty well through the lens.  I
% think.  The newer settings should match this.
%
thisROrig = piRead(fname);

newCamera = piCameraCreate('realistic');
opticsType = 'lens';
thisROrig.camera.aperture_diameter.value = 20;

% Update the camera
thisROrig.camera = newCamera;

% This could probably be a function since we change it so often. 
thisROrig.film.xresolution.value = 576*2;
thisROrig.film.yresolution.value = 576*2;
thisROrig.sampler.pixelsamples.value = 256;

% We need to move the camera to a distance that is far enough away so we can
% get a decent focus. When the object is too close, we can't focus.
diff = thisROrig.lookAt.from - thisROrig.lookAt.to;
diff = 10*diff;
thisROrig.lookAt.from = thisROrig.lookAt.to + diff;

% Good function needed to find the object distance
objDist = sqrt(sum(diff.^2));
[p,flname,~] = fileparts(thisROrig.camera.specfile.value);
focalLength = load(fullfile(p,[flname,'.FL.mat']));
focalDistance = interp1(focalLength.dist,focalLength.focalDistance,objDist);
% For an object at 125 mm, the 2ElLens has a focus at 89 mm.  We should be able
% to look this up from stored data about each lens type.
thisROrig.camera.filmdistance.value = focalDistance;



%%  Check the fields here with the fields produced in s_piReadRenderLens.m

isequal(thisR.camera,thisROrig.camera)
names = fieldnames(thisR.camera);
for ii=1:length(names)
    if ~isequal(thisR.camera.(names{ii}), thisROrig.camera.(names{ii}))
        names{ii}
    end
end

isequal(thisR.camera.filmdistance,thisROrig.camera.filmdistance)

