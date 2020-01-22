function piFluorescentDivision(varargin)
%% Use the selected algorithm for pattern generation
%
%   piFLuorescentDivision
% 
% Description:
%   Switch among possible algorithms for pattern generation.
%
% Inputs:
%   thisR               - scene recipe
%   indices             - triangle meshes in the scene
%   indicesSplit        - contains full pbrt geometry file format info
%   txtLines            - geometry file text lines
%   childGeometryPath   - path to the file
%   base                - reference material
%   algorithm           - method of how to generate pattern
% Outputs:
%   None
%
% TODO:
%   Implement more algorithms
%
% Authors:
%   ZLY, BW, 2020
%
% See also:
%   t_piFluorescentPattern, piFluorescentPattern, piFluorescentHalfDivision

%% parse the input
p = inputParser;

p.addParameter('thisR', []);
p.addParameter('indices',{});
p.addParameter('indicesSplit',{});
p.addParameter('txtLines',{});
p.addParameter('childGeometryPath','');
p.addParameter('base','');
p.addParameter('algorithm','half split');


p.parse(varargin{:});

thisR             = p.Results.thisR;
indices           = p.Results.indices;
childGeometryPath = p.Results.childGeometryPath;
indicesSplit      = p.Results.indicesSplit; 
algorithm         = ieParamFormat(p.Results.algorithm);
txtLines          = p.Results.txtLines; 
base              = p.Results.base;

%% Switch algorithm

% Currently only half split are available
switch algorithm
    case 'halfsplit'
        piFluorescentHalfDivision(thisR, indices, childGeometryPath,...
                                  indicesSplit, txtLines, base);
    otherwise
        error('Unknown algorithm: %s, maybe implement it in the future. \n', algorithm);
    
end

end