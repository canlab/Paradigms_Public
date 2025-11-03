function [scan_time, TRn] = TRn_calculation_mpa2(ts)

TR = 460;
before_start = 10; %in seconds
scanner_ready = 7; %in seconds

%ts = generate_ts_mpa2_part1;

t = zeros(1,7);
for i = 1:7
    for j = 1:numel(ts{i})
        t(i) = t(i) + ...
            str2double(ts{i}{j}{3}) + str2double(ts{i}{j}{6}) + ...
            str2double(ts{i}{j}{7});
    end
end

t2 = t + before_start;
t3 = t2 + scanner_ready;
%(t2*1000)/473
TRn = max(ceil((t2*1000)/TR));
scan_time = max(t3/60);
% fprintf('\n# TR = %d, Total time = %f minutes\n', tr2, tt2);

% fprintf('\n# TR = %d, Total time = %f minutes', max(tr), max(tt));
fprintf('\n# TR = %d, Total time = %f minutes\n', max(TRn), max(scan_time));
