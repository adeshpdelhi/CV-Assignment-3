function [x, y, width, height] = computeBoundingBox(points),
	x = min(points(:,1));
	maxX = max(points(:,1));
	y = min(points(:,2));
	maxY = max(points(:,2));
	width = maxX - x;
	height = maxY - y;
end