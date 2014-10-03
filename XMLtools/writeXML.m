function writeXML(filename, v)
%
% Transforms a struct or struct array into an XML file
%
% filename = name of the XML file
% v = struct variable containing fields of type char or numeric
%
% xml.tag.object ='foo'
% xml.tag.property(1) = {'foobar1'}
% xml.tag.property(2) = {'foobar2'}
% xml.tag.childrens(1).name ='Pedro'
% xml.tag.childrens(1).age ='12'
% xml.tag.childrens(2).name ='Juan'
% xml.tag.childrens(2).age ='15'
%
% writeXML(filename, xml) will generate a .xml file that contains:
%
% <tag>
%   <object>
%       foo
%   </object>
%   <property>
%       foobar1
%   </property>
%   <property>
%       foobar2
%   </property>
%   <childrens>
%      <name>
%        Pedro2175244
%      </name>
%      <age>
%        12
%      </age>
%   </childrens>
%   <childrens>
%      <name>
%        Juan
%      </name>
%      <age>
%        15
%      </age>
%   </childrens>
% </tag>
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand polygon for compatibility
if isfield(v.annotation, 'object')
    Nobjects = length(v.annotation.object);
    for m = 1:Nobjects
        if isfield(v.annotation.object(m), 'polygon')
            if isfield(v.annotation.object(m).polygon, 'x')
                [x,y] = LMobjectpolygon(v.annotation);
                
                % Compact polygons
                v.annotation.object(m).polygon = rmfield(v.annotation.object(m).polygon, 'x');
                v.annotation.object(m).polygon = rmfield(v.annotation.object(m).polygon, 'y');
                for j = 1:length(x{m})
                    v.annotation.object(m).polygon.pt(j).x = num2str(x{m}(j));
                    v.annotation.object(m).polygon.pt(j).y = num2str(y{m}(j));
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


xml = struct2xml(v);

% Open file
fid = fopen(filename,'w');
fwrite(fid, xml, 'char');
%fprintf(fid, xml);
% Close file
fclose(fid);

