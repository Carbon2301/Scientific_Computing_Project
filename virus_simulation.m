function virus_simulation_ui
    % Tạo giao diện người dùng
    fig = uifigure('Position', [100 100 600 500], 'Name', 'Virus Simulation UI');
    
    % Thêm tiêu đề
    lbl_title = uilabel(fig, 'Position', [200 450 200 30], 'Text', 'Virus Simulation Parameters', ...
                        'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Hộp văn bản cho số lượng virus tối đa
    lbl_n = uilabel(fig, 'Position', [50 380 150 22], 'Text', 'Max Number of Viruses:');
    txt_n = uieditfield(fig, 'numeric', 'Position', [220 380 100 22], 'Value', 1000);
    
    % Slider cho tham số điều chỉnh SOR
    lbl_w = uilabel(fig, 'Position', [50 320 150 22], 'Text', 'SOR Parameter w:');
    sld_w = uislider(fig, 'Position', [220 330 200 3], 'Limits', [1 2], 'Value', 1.89);
    lbl_w_value = uilabel(fig, 'Position', [430 320 50 22], 'Text', '1.89');
    sld_w.ValueChangedFcn = @(sld, event) updateLabelDecimal(sld, lbl_w_value);
    
    % Slider cho tham số xác suất
    lbl_p = uilabel(fig, 'Position', [50 260 150 22], 'Text', 'Probability Parameter p:');
    sld_p = uislider(fig, 'Position', [220 270 200 3], 'Limits', [0 2], 'Value', 0);
    lbl_p_value = uilabel(fig, 'Position', [430 260 50 22], 'Text', '0');
    sld_p.ValueChangedFcn = @(sld, event) updateLabelDecimal(sld, lbl_p_value);
    
    % Hộp văn bản cho kích thước lưới
    lbl_size = uilabel(fig, 'Position', [50 200 150 22], 'Text', 'Grid Size:');
    txt_size = uieditfield(fig, 'numeric', 'Position', [220 200 100 22], 'Value', 50);
    
    % Hộp văn bản cho vị trí virus ban đầu (X)
    lbl_initial_x = uilabel(fig, 'Position', [50 140 150 22], 'Text', 'Initial Virus Position X:');
    txt_initial_x = uieditfield(fig, 'numeric', 'Position', [220 140 100 22], 'Value', 25);
    
    % Hộp văn bản cho vị trí virus ban đầu (Y)
    lbl_initial_y = uilabel(fig, 'Position', [50 80 150 22], 'Text', 'Initial Virus Position Y:');
    txt_initial_y = uieditfield(fig, 'numeric', 'Position', [220 80 100 22], 'Value', 25);
    
    % Nút chạy mô phỏng
    btn_run = uibutton(fig, 'Position', [250 30 100 30], 'Text', 'Run Simulation', ...
                       'ButtonPushedFcn', @(btn, event) run_simulation(txt_n.Value, sld_w.Value, sld_p.Value, txt_size.Value, txt_initial_x.Value, txt_initial_y.Value));
end

function updateLabelDecimal(sld, lbl)
    lbl.Text = num2str(sld.Value, '%.2f');
end

function run_simulation(n, w, p, size, initial_x, initial_y)
    n = round(n);
    size = round(size);
    initial_x = round(initial_x);
    initial_y = round(initial_y);
    
    % Số virus hiện có
nVirus = 1;

% Mảng biểu thị năng lượng thức ăn, khởi tạo tất cả các giá trị bằng 0
C_sor = zeros(size);
C_gauss = zeros(size);

% Mảng đánh dấu vị trí các virus đã xuất hiện, khởi tạo tất cả các giá trị bằng 0
grow_sor = zeros(size);
grow_gauss = zeros(size);

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
end