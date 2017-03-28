names = dir('videos/1/img/*.jpg');
ground_truths = csvread('videos/1/groundtruth_rect.txt');
bounding_box = ground_truths(1,:);
img = imread([names(1).folder,'/',names(1).name]);
points = detectHarrisFeatures(img, 'ROI',bounding_box);
points = points.Location;
% points = ceil(points);
opticFlow = opticalFlowLK('NoiseThreshold',0.009);
flow = estimateFlow(opticFlow,img);
for i=2:length(names),
	img = imread([names(i).folder,'/',names(i).name]);
	% frameGray = rgb2gray(img);
	flow = estimateFlow(opticFlow,img);
	% temp_points = points;
	% points = ceil(points);
	for j = 1:size(points,1),
		points(j,:) = [ points(j,1) + flow.Vx(ceil(points(j,1)), ceil(points(j,2))), points(j,2) + flow.Vy(ceil(points(j,1)), ceil(points(j,2)))] ;
	end
	% points = temp_points;
	% points = ceil(points);
	points
	[bounding_box(1) bounding_box(2) bounding_box(3) bounding_box(4)] = computeBoundingBox(points);
	bounding_box
    imshow(insertShape(img,'rectangle',ceil(bounding_box)));
    % hold on
    % plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    % hold off
	drawnow;
	fprintf('.');
end