function [max_value, NN] = getNearestNeighbour(histograms, image_histogram)
	max_value = histograms{1}'*image_histogram;
	NN = histograms{1};
	for i=1:length(histograms),
		if(histograms{i}'*image_histogram > max_value)
			max_value = histograms{i}'*image_histogram;
			NN = histograms{i};
		end
	end
end