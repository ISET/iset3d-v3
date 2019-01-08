function status = piRunExamplesAll
%% Run all the examples in the iset3d tree
%
% Syntax:
%     piRunExamplesAll
%
% Description:
%     Run all the examples in the iset3d tree,
%     excepthose that contain a line of the form
%     "% ETTBSkip"
%
% Inputs:
%    None.
%
% Outputs:
%    status    - 1 if all examples run OK, 0 otherwise.
%
% Optional key/value pairs:
%    None.
%
% See also:
%   ieValidateFullAll, ieRunTutorialsAll

% History:
%   01/08/19  dhb  Wrote it.

[~, functionStatus] = ExecuteExamplesInDirectory(piRootPath,'verbose',false);
status = all(functionStatus ~= -1);