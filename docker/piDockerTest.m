%% piDockerTest
% If piDockerTest has run, this should work
%
% Syntax:
%   piDockerTest;
%
% Description:
%    The test should pass if Docker has previously been configured.
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

%%
disp('Running the hello-world docker test')
[status, result] = system('docker run --rm hello-world');
if status, disp(result); else, disp('hello-world seems to have run'); end

%%