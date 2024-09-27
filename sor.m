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

    % Mảng biểu thị năng lượng thức ăn
    C = zeros(size);

    % Mảng grow đánh dấu vị trí các virus đã xuất hiện
    grow = zeros(size);
    grow(initial_x, initial_y) = 1;

    % Vòng lặp để thiết lập các ô trong lưới
    for i = 2:(size-1)
        for j = 2:(size-1)
            C(i,j) = 1;
        end
    end

    % Đặt virus đầu tiên tại vị trí ban đầu
    C(initial_x, initial_y) = 0;

    prevNVirus = nVirus;
    candidate = zeros(size);

    x = 1:size; y = 1:size;
    [X, Y] = meshgrid(x, y);

    while 1
        sumOfChance = 0;

        % Tính SOR
        for i = 2:(size-1)
            for j = 2:(size-1)
                if C(i,j) ~= 0
                    C(i,j) = (w/4)*(C(i+1,j) + C(i-1,j) + C(i,j+1) + C(i,j-1)) + (1-w)*C(i,j);
                end
            end
        end

        % Tìm các vị trí candidate
        for i = 2:(size-1)
            for j = 2:(size-1)
                if grow(i,j) == 1
                    C(i,j) = 0;
                    if grow(i-1,j) == 0 && candidate(i-1,j) == 0
                        candidate(i-1,j) = 1;
                    end
                    if grow(i+1,j) == 0 && candidate(i+1,j) == 0
                        candidate(i+1,j) = 1;
                    end
                    if grow(i,j-1) == 0 && candidate(i,j-1) == 0
                        candidate(i,j-1) = 1;
                    end
                    if grow(i,j+1) == 0 && candidate(i,j+1) == 0
                        candidate(i,j+1) = 1;
                    end
                end
            end
        end

        % Tính xác suất cho các vị trí candidate
        for i = 2:(size-1)
            for j = 2:(size-1)
                if candidate(i,j) == 1
                    sumOfChance = sumOfChance + (C(i,j)).^(p);
                end
            end
        end

        % Random grow
        for i = 2:(size-1)
            for j = 2:(size-1)
                if candidate(i,j) == 1
                    randPos = rand() / 2;
                    curChance = ((C(i,j)).^(p)) / sumOfChance;
                    if (randPos < curChance) && (nVirus < n)
                        grow(i,j) = 1;
                        candidate(i,j) = 0;
                        nVirus = nVirus + 1;
                    end
                end
            end
        end

        % Đảm bảo ít nhất 1 virus mọc thêm mỗi lần lặp
        if prevNVirus == nVirus
            outLoop = 0;
            for i = 2:(size-1)
                for j = 2:(size-1)
                    if candidate(i,j) == 1
                        randPos = rand() / 100;
                        curChance = ((C(i,j)).^(p)) / sumOfChance;
                        if (randPos < curChance) && (nVirus < n)
                            grow(i,j) = 1;
                            candidate(i,j) = 0;
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
        prevNVirus = nVirus;

        % Hiển thị kết quả
        surf(X, Y, grow);
        xlim([1 size]);
        ylim([1 size]);
        zlim([0 80]);
        colormap jet;
        pause(0.1);

        if nVirus == n
            break
        end
    end
end