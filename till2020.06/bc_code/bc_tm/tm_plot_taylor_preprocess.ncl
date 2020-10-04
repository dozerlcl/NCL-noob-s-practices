; ����BC�����MOD�����OBS�໥�Ƚϵ�taylorͼ
; ǰ�������֣��Ƚ���һЩ�����statsͳ�ƺ�����ʹ�ã�֮����taylor�н�����ͼ
; 3.16�޸�ΪRegCM�Ĵ���
; 3.26�޸�Ϊ�������ļ��Ľű����Ⱥ�����TM PRE
;   ʹ��modname ����·�����ļ�����
;   ��r_to_ncl �У���BC�����������ΪNC�ļ���

;**********************************
load "./offical_sample_script/download/taylor_diagram.ncl"
load "./offical_sample_script/download/taylor_stats.ncl"
load "./offical_sample_script/download/taylor_metrics_table.ncl"
;**********************************
begin
; ·����������
modname = "wrf"
modname2 = "WRF"
type    = "tm"
;>>>-------------------------------------------------read CN05.1 data  

  f_tm_mod_cat = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_"+modname2+"_step2"+".nc", "r")
    ; list_filevars(f_CN051_TM) 
    ; _catΪ�������ͼʱ��(2000-2001)������׺
    tm_cn051_cat = f_tm_mod_cat->$"tm_cn051_step2"$; 
    tm_wrf_cat = f_tm_mod_cat->$"tm_wrf_step2"$
    tm_CN051_time = cd_calendar(tm_cn051_cat&time, 2)
    it_s=20000101  ;��ʼ���� 1998(3287)
    it_e=20011231  ;��������
    rec_s = ind(it_s .eq. tm_CN051_time)      ;��ȡ��ʼʱ��ļ�¼�� 4017(2000)
    rec_e = ind(it_e .eq. tm_CN051_time)      ;��ȡ����ʱ��ļ�¼�� 4747(2001)
    ; ��ȡ�ļ� �� ���� �Ľ��


;>>>--------------------------------------------------bc��txt�ļ���R���

;###################################BC�ļ�λ�õĲ�������####################################
  ; bc_path = "./practice/bc_data/temporary_data/bc_tm/bc_step2_test.txt"
  bc_path = "./practice/bc_data/temporary_data/bc_"+type+"/r_to_ncl/bc_"+type+"_"+modname+".nc"
;#########################################################################################

;bc_tm_rΪ�ı�ά�Ⱥ��bc���
  ; bc_tm = asciiread(bc_path, (/731 ,163 , 283/), "float") 
  ; ע��R�Ĵ������������ݣ�������仯˳���R���෴��
  ; bc_tm!0 = "time"
  ; bc_tm&time = tm_cn051_cat&time
  ; bc_tm!2 = "lon"
  ; bc_tm&lon = tm_cn051_cat&lon
  ; bc_tm!1 = "lat"
  ; bc_tm&lat = tm_cn051_cat&lat
  ; bc_tm_r = bc_tm(time|:,lat|:,lon|:)
  ; copy_VarAtts(tm_cn051_cat, bc_tm_r)
  ; bc_tm_r@_FillValue = -9999.
  f_bc = addfile(bc_path, "r")
  bc_tm_r = f_bc->$"bc_tm"$
;>>>-------------------------------------------------������
  time_bc = cd_calendar(bc_tm_r&time, 0) ; time_bcΪ730 x 6 6��ʱ��ֱ���yy mm dd hh mm ss
  ; ������ȡDJF
  ind_DJF = ind(time_bc(:,1).eq.1.or.time_bc(:,1).eq.2.or.time_bc(:,1).eq.12)
  bc_tm_DJF  = bc_tm_r(ind_DJF,:,:)
  ind_MAM = ind(time_bc(:,1).eq.3.or.time_bc(:,1).eq.4.or.time_bc(:,1).eq.5)
  bc_tm_MAM  = bc_tm_r(ind_MAM,:,:)
  ind_JJA = ind(time_bc(:,1).eq.6.or.time_bc(:,1).eq.7.or.time_bc(:,1).eq.8)
  bc_tm_JJA  = bc_tm_r(ind_JJA,:,:)
  ind_SON = ind(time_bc(:,1).eq.9.or.time_bc(:,1).eq.10.or.time_bc(:,1).eq.11)
  bc_tm_SON  = bc_tm_r(ind_SON,:,:)
;>>>-------------------------------------------------����ͳ��Ҫ��
  ; �۲�ֵ�ļ���ƽ��
  tm_obs_ave_DJF = dim_avg_n(tm_cn051_cat(ind_DJF,:,:), 0)
  tm_obs_ave_MAM = dim_avg_n(tm_cn051_cat(ind_MAM,:,:), 0)
  tm_obs_ave_JJA = dim_avg_n(tm_cn051_cat(ind_JJA,:,:), 0)
  tm_obs_ave_SON = dim_avg_n(tm_cn051_cat(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_SON)
  ; ģʽֵ�ļ���ƽ��
  tm_mod_ave_DJF = dim_avg_n(tm_wrf_cat(ind_DJF,:,:), 0)
  tm_mod_ave_MAM = dim_avg_n(tm_wrf_cat(ind_MAM,:,:), 0)
  tm_mod_ave_JJA = dim_avg_n(tm_wrf_cat(ind_JJA,:,:), 0)
  tm_mod_ave_SON = dim_avg_n(tm_wrf_cat(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_SON)
  ; BC����ļ���ƽ��
  tm_bc_ave_DJF = dim_avg_n(bc_tm_r(ind_DJF,:,:), 0)
  tm_bc_ave_MAM = dim_avg_n(bc_tm_r(ind_MAM,:,:), 0)
  tm_bc_ave_JJA = dim_avg_n(bc_tm_r(ind_JJA,:,:), 0)
  tm_bc_ave_SON = dim_avg_n(bc_tm_r(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_SON)

;  function taylor_stats(t[*][*]:numeric, r[*][*]:numeric, w:numeric, opt[1]:integer)
  stats_mod_DJF = taylor_stats(tm_mod_ave_DJF,tm_obs_ave_DJF,1.0,1)
  stats_mod_MAM = taylor_stats(tm_mod_ave_MAM,tm_obs_ave_MAM,1.0,1)
  stats_mod_JJA = taylor_stats(tm_mod_ave_JJA,tm_obs_ave_JJA,1.0,1)
  stats_mod_SON = taylor_stats(tm_mod_ave_SON,tm_obs_ave_SON,1.0,1)

  stats_bc_DJF = taylor_stats(tm_bc_ave_DJF,tm_obs_ave_DJF,1.0,1)
  stats_bc_MAM = taylor_stats(tm_bc_ave_MAM,tm_obs_ave_MAM,1.0,1)
  stats_bc_JJA = taylor_stats(tm_bc_ave_JJA,tm_obs_ave_JJA,1.0,1)
  stats_bc_SON = taylor_stats(tm_bc_ave_SON,tm_obs_ave_SON,1.0,1)
  ; stats_res_mod1 = taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1)

;   stats_res_bc = taylor_stats(bc_tm_ave,tm_obs_ave,1.0,1)
;   stats_res_mod1 = taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1)
;   ; print(stats_res) ; 0-pattern_cor; 1-ratio; 2-bias (%); 3-tmean; 4-rmean; 5-tvar; 6-rvar; 7-rmse
;>>>--------------------------------------------------��� stats���
; ������� stats_res_bc ��Ϊmod1��ͳ�Ʒ������ stats_res_mod1 ��Ϊmod��
  path_out = "./practice/bc_data/temporary_data/bc_"+type+"/taylor/taylor_seasons_"+modname+".nc"
  system("rm -f "+path_out) ;ɾ��Ŀ¼�µ�ͬ���ļ�
  ncdf_out = addfile(path_out, "c") ; c��ʾ����netcdf�ļ�
  ncdf_out->stats_bc_DJF = stats_bc_DJF
  ncdf_out->stats_bc_MAM = stats_bc_MAM
  ncdf_out->stats_bc_JJA = stats_bc_JJA 
  ncdf_out->stats_bc_SON = stats_bc_SON

  ncdf_out->stats_mod_DJF = stats_mod_DJF
  ncdf_out->stats_mod_MAM = stats_mod_MAM
  ncdf_out->stats_mod_JJA = stats_mod_JJA
  ncdf_out->stats_mod_SON = stats_mod_SON
  delete(ncdf_out)


end