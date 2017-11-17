%% piDockerTest
%
% If piDockerTest has run, this should work

%%
disp('Running the hello-world docker test')
[status, result] = system('docker run --rm hello-world');

if status,     disp(result);
else,          disp('hello-world seems to have run');
end

%%