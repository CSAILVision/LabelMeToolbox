function [newannotation,img,jo] = VLMgetvideoframe(annotation, f, HOMEVIDEOS)
%
% Returns the annotation for frame number 'f' as if it is was the
% annotation of a single image. If the video contains tracks it returns the
% coordinates of the tracks for the current frame.
%
% [newannotation,img,jo] = VLMgetvideoframe(annotation, f, HOMEVIDEOS)



newannotation = annotation;
jo = [];
img = [];

if isfield(annotation, 'object')
    newannotation = rmfield(newannotation, 'object');
    Nobjects = length(annotation.object);
    m = 0;
    for n = 1:Nobjects
        %[X,Y,t] = getLMpolygon(annotation.object(n).polygon);
        [X,Y,jc,t] = LMobjectpolygon(annotation, n);

        i = find(t+1==f);
        
        if ~isempty(i)
            m = m+1;
            obj = annotation.object(n);
            obj = rmfield(obj, 'polygon');
            obj.polygon.x = X(:,i);
            obj.polygon.y = Y(:,i);
            obj.polygon.t = t(i);
            newannotation.object(m) = obj;
            jo(m) = n;
        end
    end
end

% Extract track
if isfield(newannotation, 'tracks')
    Nframes = length(newannotation.tracks.track);
    t = []; kk = 0;
    for k = 1:Nframes
        d = newannotation.tracks.track(k).duration;
        ff = f-d(1)+1;
        if ff>0 && ff<length(newannotation.tracks.track(k).x)
            kk = kk+1;
            t.track(kk).x = newannotation.tracks.track(k).x(ff);
            t.track(kk).y = newannotation.tracks.track(k).y(ff);
            t.track(kk).v = newannotation.tracks.track(k).v;
            t.track(kk).duration = [1 1];
        end
    end
    newannotation.tracks = t;
end

% Read frame
if nargout > 1 && nargin == 3
    v.annotation = annotation;
    img = VLMvideoread(v, 1, f, HOMEVIDEOS);
end


