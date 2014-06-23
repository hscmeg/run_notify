% SETUP
% Adds required paths for runnotify to the MATLAB path
%
% Simeon Wong
% 2014 May 28

%%
% Get base directory
currentpath = mfilename('fullpath');
[currdir,~,~] = fileparts(currentpath);

addpath(currdir)

clear currentpath currdir
