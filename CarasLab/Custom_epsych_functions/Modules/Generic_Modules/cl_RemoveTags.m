function tags = cl_RemoveTags(tags)
%tags = cl_RemoveTags(tags)
%
%Custom function for Caras Lab
%
%This function removes OpenEx/TDT proprietary parameter tags from a cell
%array of tag names
%
%Written by ML Caras 8.1.2016
%Updated by KP 11.05.2016 (keep fileID tags associated with buffers);
%              04.11.2017 (when more than one data buffer)
%Updated by ML Caras 10.19.2019


%Find any tags the refer to the File ID of a buffer parameter, and save
%them from being removed from the DATA structure.
ibuf = find(~cellfun('isempty',regexp(tags,'~.+_ID')));     %kp
if sum(ibuf)>1
    for ib=ibuf'
        tags{ib} = tags{ib}(2:end);
    end
end
tags(~cellfun('isempty',strfind(tags,'~'))) = []; %#ok<*STRCL1>
tags(~cellfun('isempty',strfind(tags,'%'))) = [];
tags(~cellfun('isempty',strfind(tags,'\'))) = [];
tags(~cellfun('isempty',strfind(tags,'/'))) = [];
tags(~cellfun('isempty',strfind(tags,'|'))) = [];
tags(~cellfun('isempty',strfind(tags,'#'))) = [];
tags(~cellfun('isempty',strfind(tags,'!'))) = [];

tags(cellfun(@(x) x(1) == 'z', tags)) = [];


