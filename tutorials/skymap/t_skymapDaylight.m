%% t_skymapDaylight
%
% Starting with an RGB value, calculate an equivalent daylight
% spectral power distribution.  
%
% This tutorial calculates the same thing two ways - that come to the
% same conclusion - about how this might work.
%
% One way is by matching the XYZ values of the RGB on a display with
% a daylight from the daylight basis of the CIE.
%
% A second way is using the CIE recommended method for spectral power
% distribution from a correlated color temperature.
%
% Dependencies: ISETCam
%
% Wandell, July 2019
%
% See also
%  spd2cct, cct2sun, displayCreate
%

%%
ieInit
redSky  = [.75 .5 .3];
blueSky = [.5 .5 .7];

%% Choose a display model for the calculation

thisDisplay = displayCreate('LCD-Apple');
wave = displayGet(thisDisplay,'wave');

primaries = displayGet(thisDisplay,'spd primaries');
rgb2xyz = displayGet(thisDisplay,'rgb2xyz');

%{
ieNewGraphWin;
plot(wave,primaries);
xlabel('wave'), ylabel('energy'), grid on
%}

%% Set up to convert display XYZ values to daylight basis weights

dayBasis  = ieReadSpectra('cieDaylightBasis',wave);
XYZEnergy = ieReadSpectra('XYZEnergy',wave);

day2XYZ = XYZEnergy'*dayBasis;
XYZ2day = inv(day2XYZ);

%{
ieNewGraphWin;
plot(wave,dayBasis);
xlabel('wave'), ylabel('energy'), grid on
%}

%% Example 1:  Bluish light

displaySPD = primaries*blueSky(:);
displaySPD = ieScale(displaySPD,1);

XYZ = blueSky(:)' * rgb2xyz;
wgts = day2XYZ\XYZ(:);   % The inverse takes us from XYZ 2 day

daySPD = dayBasis*wgts;
daySPD = ieScale(daySPD,1);

ieNewGraphWin;
plot(wave,daySPD,'k-',wave,displaySPD,'b-');
xlabel('wave'), ylabel('energy'), grid on
title('Blue sky, linear model');

%% Reddish sunset

displaySPD = primaries*redSky(:);
displaySPD = ieScale(displaySPD,1);

XYZ = redSky(:)' * rgb2xyz;
wgts = day2XYZ\XYZ(:);   % The inverse takes us from XYZ 2 day
daySPD = dayBasis*wgts;
daySPD = ieScale(daySPD,1);

ieNewGraphWin;
plot(wave,daySPD,'k-',wave,displaySPD,'b-');
xlabel('wave'), ylabel('energy'), grid on
title('Red sky, linear model');

%% Convert rgb to spectrum, then built in correlated color temperature routines

displaySPD = primaries*blueSky(:);
displaySPD = ieScale(displaySPD,1);

thisCCT = spd2cct(wave,displaySPD);
fprintf('CCT %.1f\n',thisCCT);

sunSPD  = cct2sun(wave,thisCCT);
sunSPD = ieScale(sunSPD,1);

ieNewGraphWin;
plot(wave,sunSPD,'k-',wave,displaySPD,'b-');
xlabel('wave'), ylabel('energy'), grid on
title('Blue sky, CCT');


%% Convert rgb to spectrum, then built in correlated color temperature routines

displaySPD = primaries*redSky(:);
displaySPD = ieScale(displaySPD,1);

thisCCT = spd2cct(wave,displaySPD);
fprintf('CCT %.1f\n',thisCCT);

sunSPD  = cct2sun(wave,thisCCT);
sunSPD = ieScale(sunSPD,1);

ieNewGraphWin;
plot(wave,sunSPD,'k-',wave,displaySPD,'b-');
xlabel('wave'), ylabel('energy'), grid on
title('Red sky, CCT');
legend({'sun spd','display spd'})

%% END




