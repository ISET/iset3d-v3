close all


clear


%% Isetlens setup
filmdistance_mm=36.890;

lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane=outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);


%% Object distances with different reference ponts


objectFromFront = 3000;   % For zemax, measures from first lens vertex
objectFromRear= objectFromFront+lensThickness; % For isetlens
objectFromFilm= objectFromRear+filmdistance_mm; 


%% Zemax input and outputs

zemaxOrigin = [0 -1.0991706288e3  -objectFromRear]; %Measured from rear surface to emable comparison with isetlens
zemaxDirection = [0 sind(20) cosd(20)];
zemaxInput = [[zemaxOrigin] [zemaxDirection]];
zemaxOutput = [[0 1.8378822070e1 filmdistance_mm] [0 0.3014354926 0.9534865724]]



%% Define ray in isetlens and trace


[arrival_pos,arrival_dir]=rayTraceSingleRay(lens,zemaxOrigin,zemaxDirection);
%xlim([-objectDistance_fromrear 4]);
%axis equal
isetLensOutput= [arrival_pos arrival_dir]
 
%%  About 8 decimal points precision. This is about the accuracy we indeed have zemax
error = isetLensOutput-zemaxOutput
normerr = norm(error)/norm(zemaxOutput)


%% Trace in PBRT
% Remember in PBRT we start tracing from the film plane
% i have reverse traced the arriving ray on film 

% The direciton of the ray on object side is
pbrtObjectDirection = [0 -0.342020363 0.939692497]; %Sign diffrence

relerrPBRT=norm(zemaxDirection-abs(pbrtObjectDirection))/norm(zemaxDirection)
% Good up tol 7 decimal places
