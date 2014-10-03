function [counter, listofimages] = HandleImgFolder(pth)
%
% read all images - and find problematic ones
%
% Usage:
% counter = HandleImgFolder( pth )
%
% Inputs:
% pth - full path on local disk where LM (or SUN) images are.
% this should be the same path as "destImages" used in SUNinstall function
%
% Outputs:
% counter - number of problematic images encountered and deleted
%
% Note: problematic images will be deleted, their names (full path) will be
% printed to stdout.
%
% written by: Shai Bagon, Oct 2012.
%
% modified by Torralba to return a list of problematic images
%

counter = 0;
listofimages  = {};

fls = dir(fullfile(pth,'*'));

imgfrmt = imformats();

for fi=3:numel(fls) % skip first '.' and '..'
    fnm = fullfile(pth, fls(fi).name);
    % process sub folder
    if fls(fi).isdir
        disp(fls(fi))
        [c,l] = HandleImgFolder( fnm );
        counter = counter + c;
        listofimages = [listofimages l];
        continue;
    end
    
    % process image file
    try
        fbit = arrayfun( @(x) x.isa(fnm), imgfrmt);
        if any( fbit )
            % switch off warnings
            lastwarn('');
            imgfrmt(fbit).read( fnm );
            [wm wi] = lastwarn();
            if ~isempty(wi)
                lastwarn(''); % clear warning
                error('LMVerifyDownload:HandleFolder:warn',...
                    'Got warning %s\nthrowing a custom error', wm);
            end
        end
    catch em
        fprintf(1, '\tProblematic image %s \n', fnm);
        %delete(fnm);
        counter = counter + 1;
        listofimages{counter} = fnm;
    end
end
