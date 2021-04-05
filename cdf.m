function res = cdf(x)
epsilon = 1e-8;
f = [1,0];add_length = 1;
while f(end) <= 1-epsilon
    add_length = add_length*10;
    interval = (max(x)- min(x) + 2*add_length)/1000;
    pts = (min(x) - add_length):interval:(max(x)+add_length);
    [f,xi,bw] = ksdensity(x,pts,'Support','unbounded','Function','cdf');
%     [f_plot,xi_plot,bw_plot] = ksdensity(x,pts,'Support','unbounded','Function','pdf');
end
% start_ind = find(f > epsilon, 1, "first");
end_ind = find(f > 1 - epsilon, 1,"first");
%discard some values
pts = pts(1:end_ind);
f = f(1:end_ind);

%Get one sample
rand_y = rand(1);  %sample along the y-axis
res = pts(find(f >= rand_y, 1, "first"));
% fprintf("Testing sample returned is %f\n", res);

%% Plot the distribution

% plot(xi_plot,f_plot);
% hold on;
% % title('Original curve');
% rand_ys = rand(1,200,"double");
% results = zeros(1,200);
% rand_ys = sort(rand_ys);
% for i = 1:200
%     results(1,i) = pts(find(f >= rand_ys(1,i), 1, "first"));
% end
% 
% [ff,xii,bww] = ksdensity(results,'Support','unbounded','Function','pdf');
% %results = sort(results);
% plot(xii,ff);
% % title('Testing curve');
% legend("Original","Testing");
% % plot(x,'o');
% hold off;

end
