function results = cdf_100(x)
epsilon = 1e-8;
f = [1,0];add_length = 1;
while  f(end) <= 1-epsilon
    add_length = add_length*10;
    interval = (max(x)- min(x) + 2*add_length)/1000;
    pts = (min(x) - add_length):interval:(max(x)+add_length);
    [f,xi,bw] = ksdensity(x,pts,'Support','unbounded','Function','cdf');
end
end_ind = find(f > 1 - epsilon, 1,"first");

%discard some values
pts = pts(1:end_ind);
f = f(1:end_ind);

rand_ys = rand(1,100,"double");
results = zeros(1,100);

for i = 1:100
    results(1,i) = pts(find(f >= rand_ys(1,i), 1, "first"));
end

end
