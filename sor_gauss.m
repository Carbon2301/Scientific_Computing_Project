clear;  % Xóa tất cả các biến trong workspace
clc;    % Xóa cửa sổ lệnh

% Tổng số virus cần đạt được
n = 1000;

% Số virus hiện có
nVirus = 100;

% Kích thước ma trận
size = 50;

% Mảng biểu thị năng lượng thức ăn, khởi tạo tất cả các giá trị bằng 0
C_sor = zeros(size);
C_gauss = zeros(size);

% Tham số hiệu chỉnh cho SOR
w = 1.89;

% Tham số trong công thức xác suất, khởi tạo bằng 0
p = 0;

% Mảng đánh dấu vị trí các virus đã xuất hiện, khởi tạo tất cả các giá trị bằng 0
grow_sor = zeros(size);
grow_gauss = zeros(size);

% Đặt virus đầu tiên tại vị trí mới (10, 10)
initial_x = 10;
initial_y = 10;
grow_sor(initial_x, initial_y) = 1;
grow_gauss(initial_x, initial_y) = 1;

% Với phương pháp lặp, tính tại bước k+1 sẽ có giá trị của bước k+1
% tại vị trí (i-1,j) và (i,j-1)
for i = 2:(size-1)
  for j = 2:(size-1)
    C_sor(i,j) = 1;  % Đặt tất cả các giá trị bên trong ma trận C_sor thành 1
    C_gauss(i,j) = 1;  % Đặt tất cả các giá trị bên trong ma trận C_gauss thành 1
  end
end

% Đặt virus đầu tiên tại vị trí mới
C_sor(initial_x, initial_y) = 0;
C_gauss(initial_x, initial_y) = 0;

% Lưu trữ số lượng virus trước khi cập nhật
prevNVirus_sor = nVirus;
prevNVirus_gauss = nVirus;

% Mảng tạm để đánh dấu các vị trí có thể phát triển virus
candidate_sor = zeros(size);
candidate_gauss = zeros(size);

% Tạo lưới tọa độ X, Y cho việc vẽ đồ thị
x = 1:size; 
y = 1:size;
[X,Y] = meshgrid(x,y);

% Hàm cập nhật SOR
function C = update_sor(C, w, size)
    for i = 2:(size-1)
        for j = 2:(size-1)
            if C(i,j) ~= 0
                C(i,j) = (w/4) * (C(i+1,j) + C(i-1,j) + C(i,j+1) + C(i,j-1)) + (1-w) * C(i,j);
            end
        end
    end
end

% Hàm cập nhật Gauss-Seidel
function C = update_gauss(C, size)
    for i = 2:(size-1)
        for j = 2:(size-1)
            if C(i,j) ~= 0
                C(i,j) = (1/4) * (C(i+1,j) + C(i-1,j) + C(i,j+1) + C(i,j-1));
            end
        end
    end
end

% Vòng lặp chính để mô phỏng sự phát triển của virus
while 1
  sumOfChance_sor = 0;  % Tổng xác suất của các vị trí có thể phát triển cho SOR
  sumOfChance_gauss = 0;  % Tổng xác suất của các vị trí có thể phát triển cho Gauss
  
  % Tính toán SOR
  C_sor = update_sor(C_sor, w, size);

  % Tính toán Gauss-Seidel
  C_gauss = update_gauss(C_gauss, size);

  % Tìm các vị trí có thể phát triển virus (candidates) cho SOR
  for i = 2:(size-1)
    for j = 2:(size-1)
      if grow_sor(i,j) == 1
        C_sor(i,j) = 0;
        if grow_sor(i-1,j) == 0 && candidate_sor(i-1,j) == 0
          candidate_sor(i-1,j) = 1;
        end
        if grow_sor(i+1,j) == 0 && candidate_sor(i+1,j) == 0
          candidate_sor(i+1,j) = 1;
        end
        if grow_sor(i,j-1) == 0 && candidate_sor(i,j-1) == 0
          candidate_sor(i,j-1) = 1;
        end
        if grow_sor(i,j+1) == 0 && candidate_sor(i,j+1) == 0
          candidate_sor(i,j+1) = 1;
        end 
      end
    end
  end

  % Tìm các vị trí có thể phát triển virus (candidates) cho Gauss-Seidel
  for i = 2:(size-1)
    for j = 2:(size-1)
      if grow_gauss(i,j) == 1
        C_gauss(i,j) = 0;
        if grow_gauss(i-1,j) == 0 && candidate_gauss(i-1,j) == 0
          candidate_gauss(i-1,j) = 1;
        end
        if grow_gauss(i+1,j) == 0 && candidate_gauss(i+1,j) == 0
          candidate_gauss(i+1,j) = 1;
        end
        if grow_gauss(i,j-1) == 0 && candidate_gauss(i,j-1) == 0
          candidate_gauss(i,j-1) = 1;
        end
        if grow_gauss(i,j+1) == 0 && candidate_gauss(i,j+1) == 0
          candidate_gauss(i,j+1) = 1;
        end 
      end
    end
  end
  
  % Tính mẫu của P (sum of chances) cho SOR
  for i = 2:(size-1)
    for j = 2:(size-1)
      if candidate_sor(i,j) == 1
        sumOfChance_sor = sumOfChance_sor + (C_sor(i,j))^p;
      end
    end
  end

  % Tính mẫu của P (sum of chances) cho Gauss-Seidel
  for i = 2:(size-1)
    for j = 2:(size-1)
      if candidate_gauss(i,j) == 1
        sumOfChance_gauss = sumOfChance_gauss + (C_gauss(i,j))^p;
      end
    end
  end
  
  % Phát triển virus ngẫu nhiên từ các vị trí candidate cho SOR
  for i = 2:(size-1)
    for j = 2:(size-1)
      if candidate_sor(i,j) == 1
        randPos = rand()/2;
        curChance = (C_sor(i,j)^p) / sumOfChance_sor;
        if (randPos < curChance) && (nVirus < n)
          grow_sor(i,j) = 1;
          candidate_sor(i,j) = 0;
          nVirus = nVirus + 1;
        end
      end
    end
  end

  % Phát triển virus ngẫu nhiên từ các vị trí candidate cho Gauss-Seidel
  for i = 2:(size-1)
    for j = 2:(size-1)
      if candidate_gauss(i,j) == 1
        randPos = rand()/2;
        curChance = (C_gauss(i,j)^p) / sumOfChance_gauss;
        if (randPos < curChance) && (nVirus < n)
          grow_gauss(i,j) = 1;
          candidate_gauss(i,j) = 0;
          nVirus = nVirus + 1;
        end
      end
    end
  end
  
  % Đảm bảo ít nhất 1 virus phát triển mỗi lần lặp cho SOR
  if prevNVirus_sor == nVirus
    outLoop = 0;
    for i = 2:(size-1)
      for j = 2:(size-1)
        if candidate_sor(i,j) == 1
          randPos = rand()/100;
          curChance = (C_sor(i,j)^p) / sumOfChance_sor;
          if (randPos < curChance) && (nVirus < n)
            grow_sor(i,j) = 1;
            candidate_sor(i,j) = 0;
            nVirus = nVirus + 1;
            outLoop = 1;
            break;
          end
        end
      end
      if outLoop == 1
        break;
      end
    end
  end

  % Đảm bảo ít nhất 1 virus phát triển mỗi lần lặp cho Gauss-Seidel
  if prevNVirus_gauss == nVirus
    outLoop = 0;
    for i = 2:(size-1)
      for j = 2:(size-1)
        if candidate_gauss(i,j) == 1
          randPos = rand()/100;
          curChance = (C_gauss(i,j)^p) / sumOfChance_gauss;
          if (randPos < curChance) && (nVirus < n)
            grow_gauss(i,j) = 1;
            candidate_gauss(i,j) = 0;
            nVirus = nVirus + 1;
            outLoop = 1;
            break;
          end
        end
      end
      if outLoop == 1
        break;
      end
    end
  end
  prevNVirus_sor = nVirus;
  prevNVirus_gauss = nVirus;
  
  % Hiển thị số lượng virus hiện có
  nVirus; 
  
  % Vẽ đồ thị 3D biểu diễn sự phát triển của virus cho SOR
  subplot(1,2,1);
  surf(X,Y,grow_sor); 
  title('SOR Method');
  xlim([1 size]); 
  ylim([1 size]);
  zlim([0 80]); 
  colormap jet;
  pause(0.1);

  % Vẽ đồ thị 3D biểu diễn sự phát triển của virus cho Gauss-Seidel
  subplot(1,2,2);
  surf(X,Y,grow_gauss); 
  title('Gauss-Seidel Method');
  xlim([1 size]); 
  ylim([1 size]);
  zlim([0 80]); 
  colormap jet;
  pause(0.1);

  % Dừng lại khi đạt đến số lượng virus mong muốn
  if nVirus == n
    break
  end
end
