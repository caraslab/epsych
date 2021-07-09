function dprime_and_fa(Data, Info)

    dataTable = struct2table(Data);
    ams_used = unique(dataTable.AMdepth);
    if length(ams_used) > 2
        for am_idx=1:length(ams_used)
            cur_am = ams_used(am_idx);
            if round(cur_am,2) == 0
                continue
            end
            dataTable = dataTable(dataTable.Reminder == 0,:);
            temp_struct = table2struct(dataTable((dataTable.AMdepth == 0) | (dataTable.AMdepth == cur_am), :));
            
            dprime_and_fa(temp_struct, Info)
            
        end
        else
        hr = sum(bitget([Data.ResponseCode], Info.Bits.hit)) /...
            (sum(bitget([Data.ResponseCode], Info.Bits.hit)) + sum(bitget([Data.ResponseCode], Info.Bits.miss)));


        fa = sum(bitget([Data.ResponseCode], Info.Bits.fa)) / ...
            (sum(bitget([Data.ResponseCode], Info.Bits.fa)) + sum(bitget([Data.ResponseCode], Info.Bits.cr)));

        fprintf('false alarm rate=%4.4f\n', fa*100)
        %Adjust floor
        if hr <0.05
            hr = 0.05;
        end

        %adjust ceiling
        if hr >0.95
            hr = 0.95;
        end

        %Correct floor
        if fa <0.05
            fa = 0.05;
        end

        %Correct ceiling
        if fa >0.95
            fa = 0.95;
        end

        dp = norminv(hr) - norminv(fa);
        
        temp = struct2table(Data);
        cur_am = unique(temp.AMdepth);
        cur_am = cur_am(cur_am~=0);
        fprintf('Warn trials=%4.4f\n', sum([Data.TrialType] == 0))
        fprintf('d=%4.4f for %4.4f\n', dp, cur_am)
    end
end