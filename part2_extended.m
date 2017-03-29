%Partially obtained from : http://in.mathworks.com/help/vision/examples/face-detection-and-tracking-using-the-klt-algorithm.html
run('vlfeat/toolbox/vl_setup');
for tau = [0.1:0.1:1],
	nf = 0; tf = 0;
	for dataset_number = [1:5],
		% dataset_number = 1;
		names = dir(['videos/',num2str(dataset_number),'/img/*.jpg']);
		ground_truths = csvread(['videos/',num2str(dataset_number),'/groundtruth_rect.txt']);

		bounding_box = ground_truths(1,:);

		img = imread([names(1).folder,'/',names(1).name]);
		if(dataset_number == 5),
			img2 = rgb2gray(img);
		else
			img2 = img;
		end

		% points = detectHarrisFeatures(img2, 'ROI',bounding_box);
		% points = points.Location;
		img2 = single(img2);
		[f,d] = vl_sift(imcrop(img2, bounding_box));
		points = f(1:2,:);
		points = points';
		points = points + bounding_box(1:2);

		pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
		initialize(pointTracker, points, img);
		old_points = points;
		ious = zeros(length(names),1);

		for i=2:length(names),
			img = imread([names(i).folder,'/',names(i).name]);
			[points, isFound] = step(pointTracker, img);
			visiblePoints = points(isFound, :);
		    oldInliers = old_points(isFound, :);
		    if(length(oldInliers)<10 || length(visiblePoints)<10),
		    	fprintf('R');
		    	bounding_box = ground_truths(i,:);
		    	% img2 = single(img);
		    	subimg = single(imcrop(img, bounding_box));
		    	class(subimg);
		    	try
					[f,d] = vl_sift(subimg);
				catch ME
					old_points = points;
					continue;
				end
				points = f(1:2,:);
				points = points';
				points = points + bounding_box(1:2);
		    	pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
				initialize(pointTracker, points, img);
				old_points = points;
		    	continue;
		    end
		    [tform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'affine');
			points;
			bounding_box(1:2) = transformPointsForward(tform, bounding_box(1:2));
		%Uncomment the following to show images
			img = insertShape(img,'Rectangle',[bounding_box]);
			imshow(img);
			drawnow;
			
			old_points = visiblePoints;
			setPoints(pointTracker, old_points);
			ious(i,1) = bboxOverlapRatio(bounding_box, ground_truths(i,:));
			if(ious(i,1)>tau)
				nf = nf + 1;
			end
			tf = tf + 1;
		end

		fprintf('\nDataset: %d Mean IOU: %f\n',dataset_number,mean(ious));
	end
	fprintf('Tau: %d , NF: %d, TF: %d, S: %f\n',tau,nf,tf, nf/tf);
end