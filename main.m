%% 1
G = 6.6743e-11;         % m^3/(kg*s^2)
Tsim = 88*24*3600;      % 88 zile in secunde

names = ["Sun","Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune"];

% mase (kg)
m = [ ...
    1.98841e30;   % Sun
    3.302e23;     % Mercury
    4.8685e24;    % Venus
    5.97219e24;   % Earth
    6.4171e23;    % Mars
    1.89819e27;   % Jupiter
    5.6834e26;    % Saturn
    8.6813e25;    % Uranus
    1.02409e26    % Neptune
];

r0_km = [ ...
   -4.535009730392948E+05, -8.276240601849944E+05,  1.959795032855688E+04; % Sun
   -1.725638476578435E+07, -6.847116336943071E+07, -3.967235543816123E+06; % Mercury
    2.758094804453601E+07, -1.059763879135754E+08, -3.042557781955853E+06; % Venus
   -3.927646859820704E+07,  1.410593370461926E+08,  1.119207233132422E+04; % Earth
    6.098833276565664E+07, -2.046615209852258E+08, -5.758544734869510E+06; % Mars
   -2.592743523725272E+08,  7.349316451797373E+08,  2.753995766984075E+06; % Jupiter
    1.421472382755634E+09,  4.189136386443628E+07, -5.732507555609393E+07; % Saturn
    1.475056352186085E+09,  2.513771282272994E+09, -9.773633874493241E+06; % Uranus
    4.468290303502041E+09,  7.916612195644584E+07, -1.046065897679704E+08; % Neptune
];

v0_kms = [ ...
    1.240375092325877E-02,  3.873975780199613E-04, -2.356885107264090E-04; % Sun
    3.751067246681647E+01, -9.297052633695110E+00, -4.199349661701157E+00; % Mercury
    3.361486930895880E+01,  8.902510172636759E+00, -1.816786024333041E+00; % Venus
   -2.919513669277936E+01, -7.964631213612466E+00,  1.436626821936127E-03; % Earth
    2.412766725882330E+01,  9.075980874779180E+00, -4.013901140907534E-01; % Mars
   -1.247741310139767E+01, -3.726637890871185E+00,  2.946698029909107E-01; % Jupiter
   -8.163707792764154E-01,  9.634554989795502E+00, -1.351529553437127E-01; % Saturn
   -5.923737733388961E+00,  3.129100045039781E+00,  8.844125683836435E-02; % Uranus
   -1.316384688834186E-01,  5.466271211561168E+00, -1.102415019415171E-01; % Neptune
];

% conversie in SI
r0 = r0_km  * 1000;     % m
v0 = v0_kms * 1000;     % m/s

% vectorizare pentru Simulink (27x1)
Rvec0 = reshape(r0.', [], 1);
Vvec0 = reshape(v0.', [], 1);

%% 2
R = out.Rvec_out.Data;    % pozitiile
t = out.Rvec_out.Time;    % timpul
R = squeeze(R).';   % devine [52 x 27]

Nt = size(R,1);
Nbody = 9;   % Sun + 8 planete

Rmat = zeros(Nt,3,Nbody);

for k = 1:Nbody
    idx = (k-1)*3 + (1:3);
    Rmat(:,:,k) = R(:,idx);
end

figure;
hold on; grid on; axis equal;

for k = 1:Nbody
    plot(Rmat(:,1,k), Rmat(:,2,k), 'LineWidth', 1.3);
end

xlabel('X [m]')
ylabel('Y [m]')
title('Traiectoriile planetelor')
legend(names,'Location','bestoutside')

figure;
hold on; grid on; axis equal;

xlabel('X [m]')
ylabel('Y [m]')
title('Animația mișcării planetelor')

colors = lines(Nbody);
h = gobjects(Nbody,1);  % handle-uri grafice pentru animatie

% pozitii initiale
for k = 1:Nbody
    h(k) = plot(Rmat(1,1,k), Rmat(1,2,k), 'o', ...
        'Color', colors(k,:), ...
        'MarkerFaceColor', colors(k,:), ...
        'MarkerSize', 6);
end

% animatia
for i = 1:Nt
    for k = 1:Nbody
        set(h(k), ...
            'XData', Rmat(i,1,k), ...
            'YData', Rmat(i,2,k));
    end
    drawnow
end

%% 3
R_Sun = Rmat(:,:,1); 

% calculam distantele pentru fiecare planeta
distances = zeros(Nt, Nbody-1);

for k = 2:Nbody
    R_rel = Rmat(:,:,k) - R_Sun;
    distances(:,k-1) = sqrt(sum(R_rel.^2, 2));
end

% convertim timpul in zile
t_days = t / (24*3600);

% convertim distantele în AU (Astronomical Units) pentru o vizualizare mai clara
% 1 AU ≈ 1.496e11 m
AU = 1.496e11;
distances_AU = distances / AU;

figure('Position', [100, 100, 1000, 600]);
hold on; grid on;

planet_names = names(2:end);
colors = lines(Nbody-1);

for k = 1:Nbody-1
    plot(t_days, distances_AU(:,k), 'LineWidth', 1.5, ...
         'Color', colors(k,:), 'DisplayName', planet_names(k));
end

xlabel('Timp [zile]', 'FontSize', 12)
ylabel('Distanță până la Soare [AU]', 'FontSize', 12)
title('Distanța planetelor față de Soare', 'FontSize', 14)
legend('Location', 'eastoutside', 'FontSize', 10)
grid on
box on

% grafic separat pentru planetele interioare (vedem mai in detaliu)
figure('Position', [100, 100, 1000, 600]);
hold on; grid on;

for k = 1:4  % Mercury, Venus, Earth, Mars
    plot(t_days, distances_AU(:,k), 'LineWidth', 2, ...
         'Color', colors(k,:), 'DisplayName', planet_names(k));
end

xlabel('Timp [zile]', 'FontSize', 12)
ylabel('Distanță până la Soare [AU]', 'FontSize', 12)
title('Distanța planetelor interioare față de Soare', 'FontSize', 14)
legend('Location', 'best', 'FontSize', 11)
grid on
box on

% grafic separat pentru planetele exterioare
figure('Position', [100, 100, 1000, 600]);
hold on; grid on;

for k = 5:8  % Jupiter, Saturn, Uranus, Neptune
    plot(t_days, distances_AU(:,k), 'LineWidth', 2, ...
         'Color', colors(k,:), 'DisplayName', planet_names(k));
end

xlabel('Timp [zile]', 'FontSize', 12)
ylabel('Distanță până la Soare [AU]', 'FontSize', 12)
title('Distanța planetelor exterioare față de Soare', 'FontSize', 14)
legend('Location', 'best', 'FontSize', 11)
grid on
box on

% tabel cu statistici sa citim distantele
fprintf('\n=== Statistici distanțe planete-Soare ===\n');
fprintf('%-10s | %12s | %12s | %12s\n', 'Planetă', 'Min [AU]', 'Max [AU]', 'Medie [AU]');
fprintf('%s\n', repmat('-', 1, 55));
for k = 1:Nbody-1
    fprintf('%-10s | %12.4f | %12.4f | %12.4f\n', ...
        planet_names(k), ...
        min(distances_AU(:,k)), ...
        max(distances_AU(:,k)), ...
        mean(distances_AU(:,k)));
end

%% 4
R_Mercury = Rmat(:,:,2);
R_Earth = Rmat(:,:,4);

R_Mercury_Earth = R_Mercury - R_Earth;

x = R_Mercury_Earth(:,1);
y = R_Mercury_Earth(:,2);
z = R_Mercury_Earth(:,3);

r = sqrt(x.^2 + y.^2 + z.^2);

% convertim in coordonate ecliptice sferice
lambda = atan2(y, x);
beta = asin(z ./ r);

% convertim din radiani in grade pentru vizualizare
lambda_deg = rad2deg(lambda);
beta_deg = rad2deg(beta);

figure('Position', [100, 100, 1000, 700]);
plot(lambda_deg, beta_deg, 'b', 'LineWidth', 1.5, 'DisplayName', 'Traiectorie Mercur');
hold on;
grid on;

% marcam punctul initial si pe cel final pe desen
plot(lambda_deg(1), beta_deg(1), 'go', 'MarkerSize', 10, ...
     'MarkerFaceColor', 'g', 'DisplayName', 'Start');
plot(lambda_deg(end), beta_deg(end), 'ro', 'MarkerSize', 10, ...
     'MarkerFaceColor', 'r', 'DisplayName', 'Final');

legend('Location','best');
xlabel('Longitudine \lambda [grade]')
ylabel('Latitudine \beta [grade]')
title('Mișcarea aparentă a lui Mercur privită din perspectiva Pământului')
axis equal
grid on
box on

%% 5
% parametri pentru RK4
h = 600;
Tsim_short = 7*24*3600;  % o saptamana [s]
tspan_rk4 = 0:h:Tsim_short;
Nt_rk4 = length(tspan_rk4);

% functie pentru calculul acceleratiilor
function acc = compute_acc_nbody(R_vec, m, G, Nbody)
    acc = zeros(27, 1);
    for i = 1:Nbody
        idx_i = (i-1)*3 + (1:3);
        ri = R_vec(idx_i);
        for j = 1:Nbody
            if j ~= i
                idx_j = (j-1)*3 + (1:3);
                rj = R_vec(idx_j);
                rij = rj - ri;
                dist = norm(rij);
                acc(idx_i) = acc(idx_i) + G*m(j)*rij/dist^3;
            end
        end
    end
end

odefun = @(t, state) [state(28:54); compute_acc_nbody(state(1:27), m, G, Nbody)];

state0 = [Rvec0; Vvec0];
state_rk4 = zeros(Nt_rk4, 54);
state_rk4(1,:) = state0';

for n = 1:Nt_rk4-1
    t_curr = tspan_rk4(n);
    wn = state_rk4(n,:)';
    
    k1 = odefun(t_curr, wn);
    k2 = odefun(t_curr + h/2, wn + (h/2)*k1);
    k3 = odefun(t_curr + h/2, wn + (h/2)*k2);
    k4 = odefun(t_curr + h, wn + h*k3);
    
    state_rk4(n+1,:) = wn' + (h/6)*(k1' + 2*k2' + 2*k3' + k4');
end

% extragem pozitiile RK4
R_rk4 = state_rk4(:,1:27);
V_rk4 = state_rk4(:,28:54);

Rmat_rk4 = zeros(Nt_rk4,3,Nbody);
for k = 1:Nbody
    idx = (k-1)*3 + (1:3);
    Rmat_rk4(:,:,k) = R_rk4(:,idx);
end

% extragem prima saptamana din Simulink
idx_week = t <= Tsim_short;
Rmat_sim = Rmat(idx_week,:,:);
t_sim_week = t(idx_week);
t_rk4_days = tspan_rk4 / (24*3600);

% comparatie traiectorii pt planete interioare
figure('Position', [100, 100, 1200, 500]);

subplot(1,2,1);
hold on; grid on; axis equal;
colors = lines(4);
for k = 2:5  % Mercury, Venus, Earth, Mars
    plot(Rmat_sim(:,1,k), Rmat_sim(:,2,k), '-', ...
         'Color', colors(k-1,:), 'LineWidth', 2, ...
         'DisplayName', names(k));
end
xlabel('X [m]', 'FontSize', 11)
ylabel('Y [m]', 'FontSize', 11)
title('Simulink(ode45)', 'FontSize', 12)
legend('Location', 'best')
box on

subplot(1,2,2);
hold on; grid on; axis equal;
for k = 2:5
    plot(Rmat_rk4(:,1,k), Rmat_rk4(:,2,k), ...
         'Color', colors(k-1,:), 'LineWidth', 2, ...
         'DisplayName', names(k));
end
xlabel('X [m]', 'FontSize', 11)
ylabel('Y [m]', 'FontSize', 11)
title('RK4', 'FontSize', 12)
legend('Location', 'best')
box on

sgtitle('Comparație traiectorii planetare: Simulink(ode45) vs RK4 (7 zile)', 'FontSize', 14);

% suprapunere traiectorii pt planete interioare
figure('Position', [100, 100, 1200, 900]);

for k = 2:5  % Mercury, Venus, Earth, Mars
    subplot(2,2,k-1);
    hold on; grid on; axis equal;
    
    plot(Rmat_sim(:,1,k), Rmat_sim(:,2,k), 'b-', ...
         'LineWidth', 2, 'DisplayName', 'Simulink');
    plot(Rmat_rk4(:,1,k), Rmat_rk4(:,2,k), 'r--', ...
         'LineWidth', 1.5, 'DisplayName', 'RK4');
    
    xlabel('X [m]', 'FontSize', 10)
    ylabel('Y [m]', 'FontSize', 10)
    title(names(k), 'FontSize', 12)
    legend('Location', 'best')
    box on
end

sgtitle('Suprapunere traiectorii: Simulink(ode45) vs RK4', 'FontSize', 14);

%% 6
R_final_sim = R(end, :);

% extragem vitezele din Simulink (la fel ca pentru pozitii)
V = out.Vvec_out.Data;
V = squeeze(V).';

V_final_sim = V(end, :);

% reorganizam in format [Nbody x 3]
R_final_sim_mat = reshape(R_final_sim, 3, Nbody)';
V_final_sim_mat = reshape(V_final_sim, 3, Nbody)';

% date de referinta JPL Horizons
r_final_JPL_km = [ ...
 -3.605638405267068E+05, -8.190796097379777E+05,  1.776604463963280E+04; % Sun
 -1.706432930225717E+07, -6.848672591527940E+07, -3.980214156516876E+06; % Mercury
  4.538368658256619E+07,  9.691008179660912E+07, -1.278989735327207E+06; % Venus
 -1.455888651609805E+08, -3.667989275198931E+07,  2.109510861743800E+04; % Earth
  1.957397953599764E+08, -6.591694768876468E+07, -6.154983933567345E+06; % Mars
 -3.518022569631472E+08,  7.007621824162264E+08,  4.966389030585051E+06; % Jupiter
  1.413362346205410E+09,  1.150557851461577E+08, -5.827482552189734E+07; % Saturn
  1.429790914313633E+09,  2.537170895952241E+09, -9.100385135417342E+06; % Uranus
  4.467093983859947E+09,  1.207261788614958E+08, -1.054348698466234E+08  % Neptune
];

v_final_JPL_kms = [ ...
  1.199293831910961E-02,  1.892669331868789E-03, -2.435112793514965E-04; % Sun
  3.752771807753827E+01, -9.226156853173199E+00, -4.195245153231530E+00; % Mercury
 -3.182092260744652E+01,  1.468795661197712E+01,  2.038267750768406E+00; % Venus
  6.663042942415205E+00, -2.901968125557824E+01,  2.071260660716945E-03; % Earth
  8.573234536981886E+00,  2.506943136954045E+01,  3.151533144272669E-01; % Mars
 -1.183316338736374E+01, -5.244637847712607E+00,  2.865260689421798E-01; % Jupiter
 -1.317184210585850E+00,  9.606639902718586E+00, -1.144998290037549E-01; % Saturn
 -5.983255843404665E+00,  3.025999964018266E+00,  8.882683521432666E-02; % Uranus
 -1.820704834020314E-01,  5.465251353179370E+00, -1.090384448309889E-01  % Neptune
];

% conversie in SI
R_final_JPL_mat = r_final_JPL_km * 1000;
V_final_JPL_mat = v_final_JPL_kms * 1000;

fprintf('%-10s | %15s | %15s | %15s | %15s\n', ...
        'Planetă', 'Err poz [km]', 'Err poz [%]', 'Err vit [m/s]', 'Err vit [%]');
fprintf('%s\n', repmat('-', 1, 80));

err_pos_km = zeros(Nbody, 1);
err_pos_rel = zeros(Nbody, 1);
err_vel_ms = zeros(Nbody, 1);
err_vel_rel = zeros(Nbody, 1);

for k = 1:Nbody
    r_sim = R_final_sim_mat(k, :);
    v_sim = V_final_sim_mat(k, :);
    r_jpl = R_final_JPL_mat(k, :);
    v_jpl = V_final_JPL_mat(k, :);
    
    % erori absolute
    err_pos_km(k) = norm(r_sim - r_jpl) / 1000;      % km
    err_vel_ms(k) = norm(v_sim - v_jpl);             % m/s
    
    % erori relative
    err_pos_rel(k) = norm(r_sim - r_jpl) / norm(r_jpl) * 100;  % in procente
    err_vel_rel(k) = norm(v_sim - v_jpl) / norm(v_jpl) * 100;  % in procente
    
    fprintf('%-10s | %14.2f | %14.6f | %14.6f | %14.6f\n', ...
            names(k), err_pos_km(k), err_pos_rel(k), err_vel_ms(k), err_vel_rel(k));
end

% vizualizare erori
figure('Position', [100, 100, 700, 600]);

loglog(err_pos_km(2:end), err_vel_ms(2:end), 'o', ...
       'MarkerSize', 8, 'LineWidth', 2);
grid on;

text(err_pos_km(2:end)*1.1, err_vel_ms(2:end)*1.1, planet_names);

xlabel('Eroare poziție [km]');
ylabel('Eroare viteză [m/s]');
title('Corelația erorilor de integrare (tf = 88 zile)');
