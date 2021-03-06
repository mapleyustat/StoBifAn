function para_match = parameter_continuation(ind, bound, check_fcn, check_para)
% PARAMETER_CONTINUATION Search for the grid points that satisfy the
% criteria defined in the function, check_fcn, and are connected to the
% initial point, given by the ROW vector, ind. check_para include
% parameters for the check function. 
% 
% bound, is a matrix, of which the first column contains the lower bound
% for all parameter indices, and the second column contains the upper
% bounds.
%
% 
% ------------------------------
% StoBifan 1.0, 2014
%
% This is Stochastic Bifurcation Analyser, written by Shuohao Liao
% Mathematical Institute, University of Oxford
% webpage: http://maths.ox.ac.uk/liao
%
% For all questions, bugs and suggestions please email
% liao@maths.ox.ac.uk
% -----------------------------


n_par = length(ind); % number of parameters

n_point = 3^n_par;   % total number of surrounding parameter points (including itself)

% a matrix storing the shift vector that loop through all surrounding
% grid points
pos = zeros(n_point, n_par);

rec = [-1, 0, 1];

for i = 1 : n_par
    
    s_rec = i-1;
    
    l_rec = n_par - i;
    
    vec_shift = kron(ones(1,3^s_rec), kron(rec, ones(1,3^l_rec)))';
    
    pos(:,i) = vec_shift;
    
end


check_stop = 0;
para_match = ind;
para_center = ind;
para_loop = ind;
para_index = 1;
check_close = 0;

% continuation states
while check_stop == 0
    
    for i = 1 : n_point % loop through all the surrounding points
        
        if i ~= (n_point + 1)/2 % check if the poin is the center point
            
            % the current grid points
            para_current = para_center + pos(i,:);
            
            if_cross = 0;
            
            for j = 1 : n_par % check if the point is over the boundary
                
                if (para_current(j) > bound(j,2)) || (para_current(j) < bound(j,1))
                    
                    if_cross = if_cross + 1;
                    
                end
                
            end
            
            if if_cross == 0 % within the boundary
                
                % check if the current point has alrdy been looped through
                if_repeat = find(ismember(para_loop, para_current, 'rows'), 1);
                
                if isempty(if_repeat) % has not looped yet.
                    
                    % add current points to history
                    para_loop = [para_loop; para_current];
                    
                    % check if the grid point satisfy certain criteria
                    check_value = check_fcn(para_current, check_para);
                    
                    if check_value == 1 % satisfied
                        
                        % add current grid index
                        para_match = [para_match; para_current];
                        
                        % set current grid points to 0, (this means the grid point
                        % will be used as a center point to search its surrounding
                        % points.
                        check_close = [check_close; 0];
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    % close the center point
    check_close(para_index) = 1;
    
    % check if there are some repeated points; if yes, delete them.
    [para_match, ia, ~] = unique(para_match,'rows');
    
    check_close = check_close(ia);
    
    % locate the next searching points:
    para_index = find(check_close == 0, 1);
    
    % check if the searching is complete
    if isempty(para_index)
        
        check_stop = 1; % stop the iteration
        
    else
        
        para_center = para_match(para_index,:); % reset the center point
        
    end
    
end


end