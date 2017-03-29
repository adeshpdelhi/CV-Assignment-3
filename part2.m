%Partially obtained from : http://in.mathworks.com/help/vision/examples/face-detection-and-tracking-using-the-klt-algorithm.html
for tau = [0.1:0.1:1],
	nf = 0; tf = 0;
	for dataset_number = [1:5],
		% dataset_number = data;
		names = dir(['videos/',num2str(dataset_number),'/img/*.jpg']);
		ground_truths = csvread(['videos/',num2str(dataset_number),'/groundtruth_rect.txt']);

		bounding_box = ground_truths(1,:);
		bounding_box;
		img = imread([names(1).folder,'/',names(1).name]);
		if(dataset_number == 5),
			% fprintf('Converting to grayscale\n');
			img2 = rgb2gray(img);
		else
			img2 = img;
		end
		points = detectHarrisFeatures(img2, 'ROI',bounding_box);
		points = points.Location;
		pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
		% opticFlow = opticalFlowLK('NoiseThreshold',0.009);
		bounding_boxes = [];
		% flow = estimateFlow(opticFlow,img);
		initialize(pointTracker, points, img);
		old_points = points;
		ious = zeros(length(names),1);
		for i=2:length(names),
			img = imread([names(i).folder,'/',names(i).name]);
			% flow = estimateFlow(opticFlow,img);
			size(points, 1);
			% points
			[points, isFound] = step(pointTracker, img);
			size(old_points, 1);
			size(isFound, 1);
			visiblePoints = points(isFound, :);
		    % fprintf('here1\n');
		    oldInliers = old_points(isFound, :);
		    % fprintf('here2\n');
		    if(length(oldInliers)<3 && length(visiblePoints)<3),
		    	continue;
		    end
		    [tform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'affine');
		    % fprintf('here3\n');

			% points
			% isFound
			% for j = 1:size(points,1),
			% 	points(j,:) = [ points(j,1) + flow.Vx(ceil(points(j,1)), ceil(points(j,2))), points(j,2) + flow.Vy(ceil(points(j,1)), ceil(points(j,2)))] ;
			% end

			% temp_points = [];
			% temp_old_points = [];
			% for i=1:size(points, 1),
			% 	if(isFound(i) == true),
			% 		temp_points = [temp_points; points(i,1) points(i,2)];
			% 		temp_old_points = [temp_old_points; old_points(i,1) old_points(i,2)];
			% 	end
			% end
			% minimum_length = min(size(old_points,1), size(points,1));
			% points = points(isFound == true, : );
			% old_points = old_points(isFound == true, :);
			% fprintf('crashin');
			% tform = estimateGeometricTransform(old_points(1:minimum_length,:),points(1:minimum_length,:),'affine');

			% points = temp_points;
			% points
			% [bounding_box(1) bounding_box(2)] = computeBoundingBox(points);
			% bounding_box = reshape(bounding_box', 1, []);
			bounding_box;
			bounding_box(1:2) = transformPointsForward(tform, bounding_box(1:2));
			% bounding_box(3:4) = transformPointsForward(tform, bounding_box(1:2) + bounding_box(3:4));
			% bounding_box(3:4) = bounding_box(3:4) - bounding_box(1:2);
			bounding_box;
			

		%Uncomment the following to show images
			img = insertShape(img,'Rectangle',[bounding_box]);
		 	imshow(img);
			drawnow;
			

			% fprintf('.');
			% bounding_boxes = [bounding_boxes]
			old_points = visiblePoints;
			setPoints(pointTracker, old_points);
			ious(i,1) = bboxOverlapRatio(bounding_box, ground_truths(i,:));
			if(ious(i,1)>tau)
				nf = nf + 1;
			end
			tf = tf + 1;
		end

		fprintf('Dataset: %d Mean IOU: %f\n',dataset_number,mean(ious));
	end
	fprintf('Tau: %d , NF: %d, TF: %d, S: %f\n',tau,nf,tf, nf/tf);
end