run('vlfeat/toolbox/vl_setup')

names = dir('vehicles/*/*.png');
% names = names(1:1000);
vimages = {};
for i = 1:length(names),
	if rem(i,100) == 0,
		fprintf('Loading vehicle image %d\n',i);
	end	
	 vimages{i} = imread([names(i).folder,'/',names(i).name]);
end



names = dir('non-vehicles/*/*.png');
% names = names(1:1000);
nvimages = {};
for i = 1:length(names),
	if rem(i,100) == 0,
		fprintf('Loading non-vehicle image %d\n',i);
	end	
	 nvimages{i} = imread([names(i).folder,'/',names(i).name]);
end

perm = randperm(length(vimages));
training_perm = perm(1:ceil(0.8*length(vimages)));
testing_perm = perm((ceil(length(vimages)*0.8)+1):length(vimages));
testing_vimages = vimages(testing_perm);
vimages = vimages(training_perm);


perm = randperm(length(nvimages));
training_perm = perm(1:ceil(0.8*length(nvimages)));
testing_perm = perm((ceil(length(nvimages)*0.8)+1):length(nvimages));
testing_nvimages = nvimages(testing_perm);
nvimages = nvimages(training_perm);

ds = [];
k = 0;
for i=1:length(vimages),
	if rem(i,100) == 0,
		fprintf('Extracting features vehicle image %d\n',i);
	end	
	I = vimages{i};
	I = single(rgb2gray(I));
	[f,d] = vl_sift(I) ;
	for j = 1:size(d,2),
		k = k + 1;
		ds{k} = d(:,j);
	end
end

for i=1:length(nvimages),
	if rem(i,100) == 0,
		fprintf('Extracting features non-vehicle image %d\n',i);
	end	
	I = nvimages{i};
	I = single(rgb2gray(I));
	[f,d] = vl_sift(I) ;
	for j = 1:size(d,2),
		k = k + 1;
		ds{k} = d(:,j);
	end
end

temp_ds = zeros(128, length(ds));

for i =1:length(ds),
	temp_ds(:,i) = ds{i};
end

ds = temp_ds;
ds = ds';

[idx, C] = kmeans(ds, 200, 'MaxIter',200);

vhistograms = {};
for i=1:length(vimages),
	if rem(i,100) == 0,
		fprintf('Creating histogram vehicle image %d\n',i);
	end	
	vhistograms{i} = getHistogram(C, vimages{i});
end

nvhistograms = {};
for i=1:length(nvimages),
	if rem(i,100) == 0,
		fprintf('Creating histogram non-vehicle image %d\n',i);
	end	
	nvhistograms{i} = getHistogram(C, nvimages{i});
end

incorrect_v_classification = 0;
correct_v_classification = 0;
for i = 1:length(testing_vimages),
	if rem(i,100) == 0,
		fprintf('Classifying vehicle image %d. Correct: %d Incorrect: %d\n',i,correct_v_classification, incorrect_v_classification);
	end	
	histogram = getHistogram(C,testing_vimages{i});
	[vvalue, vNN] = getNearestNeighbour(vhistograms, histogram);
	[nvvalue, nvNN] = getNearestNeighbour(nvhistograms, histogram);
	if(vvalue > nvvalue)
		correct_v_classification = correct_v_classification + 1;
		% fprintf('Vehicle: Correct classification nvvalue: %f vvalue:%f\n',nvvalue,vvalue);
	else
		incorrect_v_classification = incorrect_v_classification + 1;
		% fprintf('Vehicle: Incorrect classification nvvalue: %f vvalue:%f\n',nvvalue,vvalue);

	end
end
fprintf('Accuracy for vehicle classification : %f\n',correct_v_classification/(correct_v_classification+incorrect_v_classification));



incorrect_nv_classification = 0;
correct_nv_classification = 0;
for i = 1:length(testing_nvimages),
	if rem(i,100) == 0,
		fprintf('Classifying non-vehicle image %d. Correct: %d Incorrect: %d\n',i,correct_nv_classification, incorrect_nv_classification);
	end	
	histogram = getHistogram(C,testing_nvimages{i});
	[vvalue,vNN] = getNearestNeighbour(vhistograms, histogram);
	[nvvalue,nvNN] = getNearestNeighbour(nvhistograms, histogram);
	if(nvvalue >= vvalue)
		correct_nv_classification = correct_nv_classification + 1;
		% fprintf('Non-vehicle: Correct classification nvvalue: %f vvalue:%f\n',nvvalue,vvalue);
	else
		incorrect_nv_classification = incorrect_nv_classification + 1;
		% fprintf('Non-vehicle: Incorrect classification nvvalue: %f vvalue:%f\n',nvvalue,vvalue);
	end
end
fprintf('Accuracy for non-vehicle classification : %f\n',correct_nv_classification/(correct_nv_classification+incorrect_nv_classification));

fprintf('Total Accuracy: %f\n', (correct_v_classification + correct_nv_classification)/(correct_v_classification + correct_nv_classification + incorrect_v_classification + incorrect_nv_classification));

% i = 2580;
% I = vimages{i};
% image(I);
% I = single(rgb2gray(I));
% [f,d] = vl_sift(I) ;
% h1 = vl_plotframe(f(:,:)) ;
% h2 = vl_plotframe(f(:,:)) ;
% h3 = vl_plotsiftdescriptor(d(:,:),f(:,:)) ;
% set(h3,'color','g') ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;