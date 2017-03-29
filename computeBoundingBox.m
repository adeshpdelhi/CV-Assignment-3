function [x, y] = computeBoundingBox(points),
	x = min(points(:,1));
	maxX = max(points(:,1));
	y = min(points(:,2));
	maxY = max(points(:,2));
end