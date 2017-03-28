function histogram = getHistogram(C, I),
	% threshold = 250;
	C = C';
	histogram = zeros(size(C, 2),1);
	I = single(rgb2gray(I));
	[f,d] = vl_sift(I) ; %C : 128xsomething
	d = double(d);
	% fprintf('d then C \n');
	% size(d)
	% size(C)
	for i = 1:size(d,2), %d : 128xsomething
		idx = 1;
		min_distance = norm(d(:,i) - C(:,1));
		for j=1:size(C,2),
			if(norm(d(:,i) - C(:,j)) < min_distance),
				idx = j;
				min_distance = norm(d(:,i) - C(:,j));
			end
		end
		% if(min_distance < threshold),
			histogram(idx) = histogram(idx) + 1;
		% end
		% fprintf('min_distance: %f\n', min_distance);
	end
	if(norm(histogram)~= 0)
		histogram = histogram/norm(histogram);
	end
end
