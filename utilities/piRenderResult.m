function [lensFilm, infocusDistance] = piRenderResult(result)
% Return critical optics parameters from the piRender result
%
% Syntax:
%  [lensFilm, infocusDistance] = piRenderResult(result)
%
% Input:
%   result - the text returned as the second argument by piRender
% 
% Optional key/value pairs
%   N/A
%
% Output:
%  lensFilm        - Distance from the back of the lens to the film in
%                    (meters)
%  infocusDistance - In focus distance in the scene through the lens
%                    (meters)
%
% Description
%   PBRT calculates the distance from the film to the back of the lens
%   and the infocus distance in the scene (both in meters).  These are
%   printed in the 'result' string that is returned from piRender.
%   This routine parses the result text and extracts those values.
%
%   If the printed result from PBRT ever changes, this routine will
%   have to change.  That is because it searches for critical text in
%   the printed result to find these two parameters.
%
% Wandell
%
% See also
%  piRender

% First variable
txtLensFilm = 'film to back of lens: ';
pos = strfind(result,txtLensFilm);
if isempty(pos)
    warning('Key text for lensFilm not found.')
else
    pos = pos + length(txtLensFilm);
    C = textscan(result(pos:(pos+10)),'%f');
    lensFilm = C{1};
end

% Second variable
txtInfocus = 'Focus distance in scene: ';
pos = strfind(result,txtInfocus);
if isempty(pos)
    warning('Key text for infocusDistance not found.')
else
    pos = pos + length(txtInfocus);
    C = textscan(result(pos:(pos+10)),'%f');
    infocusDistance = C{1};
end

end

