clear all;
close all;

fprintf("\n");
fprintf("\n");

% list all packages loaded by default
% all packages are listed
% packages already loaded are indicated with *
fprintf("\n");
fprintf("List of all packages");
fprintf("\n");
pkg list
% load all packages
fprintf("\n");
fprintf("Load all packages");
fprintf("\n");
pkg load all
% display again all packages
fprintf("\n");
fprintf("All packages now loaded");
fprintf("\n");
pkg list

% check that the right packages are present
fprintf("\n");
fprintf("Package required for communications: instrument-control");
fprintf("\n");
