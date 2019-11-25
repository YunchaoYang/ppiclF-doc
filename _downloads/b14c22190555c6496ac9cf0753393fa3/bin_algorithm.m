clear all;
close all;
clc

np     = 16; % Number of processors
dx_min = 1;  % Minimum box size
d      = 3;  % Dimension

binb = [-1 10; -1 10; -1 10];

% priority = [3;2;1]; % 1 = first, 2 = second, 3 = third, repeated number is equal priority
nx_user = 1; % default is 1
ny_user = 1; % default is 1
nz_user = 1; % default is 1

% Algorithm

% Initialize
finished = zeros(d,1);
n_bins = [nx_user, ny_user, nz_user];
bins_set = n_bins > 1;
bins_dx = zeros(d,1);
% priority_order = zeros(d,1);
total_bin = 1;
for i=1:d
    finished(i) = 0;
    bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);
    % Make sure exit_2 is not violated by user input
    if (bins_dx(i) < dx_min)
        while (bins_dx(i) < dx_min)
            n_bins(i) = max(n_bins(i) - 1,1);
            bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);
        end
    end
    % priority_order(i) = i;
    total_bin = total_bin*n_bins(i);
end

% Bubble sort priority
% for i=1:d
%     for j=1:d-1
%         if (priority(j+1) < priority(j))
%             % Swap
%             tmp = priority(j);
%             priority(j)   = priority(j+1);
%             priority(j+1) = tmp;
%             
%             k = priority_order(j);
%             priority_order(j)   = priority_order(j+1);
%             priority_order(j+1) = k;
%         end
%     end
% end

% Make sure exit_1 not violated by user input
count = 0;
while (total_bin > np)
    count = count + 1;
    k = mod((d-1)+count,d)+1; % repeats 1, ..., d
    % i = priority_order(k); % apply in priority_order'ing
    i = k;
    n_bins(i) = max(n_bins(i)-1,1);
    bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);
    total_bin = 1;
    for j=1:d
        total_bin = total_bin*n_bins(j);
    end
    if (total_bin <= np)
        break;
    end
end

% Now evaluate
exit_1_array = bins_set(1:d);
exit_1 = false; % total_bin > np (fatal)
exit_2_array = zeros(d,1); % dx(j) < dx_min
exit_2 = false;  % dx(*) < dx_min (fatal)

while (~exit_1 && ~exit_2)
%     [exit_1, exit_2]
    for i=1:d
%         i = priority_order(ii);
        if (exit_1_array(i) == 0)
           n_bins(i) = n_bins(i) + 1;
           bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);

            % Check conditions
            % Exit 1
            total_bin = 1;
            for k=1:d
                total_bin = total_bin*n_bins(k);
            end
            if (total_bin > np)
                exit_1_array(i) = 1;
                n_bins(i) = n_bins(i) - 1;
                bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);
                break;
            end

            % Exit 2
            if (bins_dx(i) < dx_min)
               exit_2_array(i) = 1;
               n_bins(i) = n_bins(i) - 1;
               bins_dx(i) = (binb(i,2) - binb(i,1))/n_bins(i);
               break;
            end   
        end
    end

    % Exit 1
    sum_value = 0;
    for k=1:d
        sum_value = sum_value + exit_1_array(k);
    end
    if (sum_value == d)
        exit_1 = true;
    end
    
    % Exit 2
    sum_value = 0;
    for k=1:d
        sum_value = sum_value + exit_2_array(k);
    end
    if (sum_value == d)
        exit_2 = true;
    end       
end

n_bins
bins_dx
total_bin = 1;
for k=1:d
    total_bin = total_bin*n_bins(k);
end
total_bin
